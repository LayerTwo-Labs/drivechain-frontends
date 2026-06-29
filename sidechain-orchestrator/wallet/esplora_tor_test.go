package wallet

import (
	"context"
	"encoding/binary"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"sync/atomic"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// stubSOCKS5 is a minimal SOCKS5 proxy: it performs the no-auth handshake, reads
// the CONNECT request, dials the requested target, and pipes bytes both ways. It
// records how many connections it brokered so a test can assert traffic actually
// went through the proxy.
type stubSOCKS5 struct {
	ln       net.Listener
	conns    int32
	lastHost string
}

func newStubSOCKS5(t *testing.T) *stubSOCKS5 {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	s := &stubSOCKS5{ln: ln}
	go s.serve()
	t.Cleanup(func() { _ = ln.Close() })
	return s
}

func (s *stubSOCKS5) addr() string { return s.ln.Addr().String() }

func (s *stubSOCKS5) serve() {
	for {
		c, err := s.ln.Accept()
		if err != nil {
			return
		}
		go s.handle(c)
	}
}

func (s *stubSOCKS5) handle(c net.Conn) {
	defer func() { _ = c.Close() }()

	// Greeting: version, nmethods, methods.
	hdr := make([]byte, 2)
	if _, err := io.ReadFull(c, hdr); err != nil {
		return
	}
	methods := make([]byte, int(hdr[1]))
	if _, err := io.ReadFull(c, methods); err != nil {
		return
	}
	// Select "no authentication".
	if _, err := c.Write([]byte{0x05, 0x00}); err != nil {
		return
	}

	// Request: ver, cmd, rsv, atyp.
	req := make([]byte, 4)
	if _, err := io.ReadFull(c, req); err != nil {
		return
	}
	var host string
	switch req[3] {
	case 0x01: // IPv4
		b := make([]byte, 4)
		if _, err := io.ReadFull(c, b); err != nil {
			return
		}
		host = net.IP(b).String()
	case 0x03: // domain
		l := make([]byte, 1)
		if _, err := io.ReadFull(c, l); err != nil {
			return
		}
		b := make([]byte, int(l[0]))
		if _, err := io.ReadFull(c, b); err != nil {
			return
		}
		host = string(b)
	default:
		return
	}
	pb := make([]byte, 2)
	if _, err := io.ReadFull(c, pb); err != nil {
		return
	}
	port := binary.BigEndian.Uint16(pb)
	target := net.JoinHostPort(host, strconv.Itoa(int(port)))

	atomic.AddInt32(&s.conns, 1)
	s.lastHost = host

	upstream, err := net.Dial("tcp", target)
	if err != nil {
		_, _ = c.Write([]byte{0x05, 0x01, 0x00, 0x01, 0, 0, 0, 0, 0, 0})
		return
	}
	defer func() { _ = upstream.Close() }()
	// Success reply with a dummy bind address.
	if _, err := c.Write([]byte{0x05, 0x00, 0x00, 0x01, 0, 0, 0, 0, 0, 0}); err != nil {
		return
	}

	done := make(chan struct{}, 2)
	go func() { _, _ = io.Copy(upstream, c); done <- struct{}{} }()
	go func() { _, _ = io.Copy(c, upstream); done <- struct{}{} }()
	<-done
}

// TestEsploraClientRoutesThroughSOCKS5 asserts that with Tor enabled the Esplora
// HTTP client dials the backend through the configured SOCKS5 proxy.
func TestEsploraClientRoutesThroughSOCKS5(t *testing.T) {
	backend := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/blocks/tip/height" {
			_, _ = io.WriteString(w, "654321")
			return
		}
		http.Error(w, "unexpected path "+r.URL.Path, http.StatusNotFound)
	}))
	defer backend.Close()

	proxy := newStubSOCKS5(t)

	client := NewEsploraClient([]string{backend.URL}, zerolog.Nop())
	require.NoError(t, client.SetProxy(true, proxy.addr()))

	enabled, addr := client.ProxyConfig()
	assert.True(t, enabled)
	assert.Equal(t, proxy.addr(), addr)

	tip, err := client.TipHeight(context.Background())
	require.NoError(t, err)
	assert.Equal(t, 654321, tip)
	assert.GreaterOrEqual(t, atomic.LoadInt32(&proxy.conns), int32(1), "request must traverse the SOCKS5 proxy")
}

// TestEsploraClientDirectWhenDisabled confirms disabling Tor reverts to a direct
// transport that does not touch the proxy.
func TestEsploraClientDirectWhenDisabled(t *testing.T) {
	backend := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = io.WriteString(w, "100")
	}))
	defer backend.Close()

	proxy := newStubSOCKS5(t)

	client := NewEsploraClient([]string{backend.URL}, zerolog.Nop())
	require.NoError(t, client.SetProxy(true, proxy.addr()))
	require.NoError(t, client.SetProxy(false, proxy.addr()))

	enabled, _ := client.ProxyConfig()
	assert.False(t, enabled)

	_, err := client.TipHeight(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int32(0), atomic.LoadInt32(&proxy.conns), "direct transport must not use the proxy")
}

func TestSetTorConfigValidEnables(t *testing.T) {
	p, fake := newSwitchableElectrumBackend(t, "https://original.example/api")
	fake.tip = 321

	tip, err := p.SetTorConfig(context.Background(), true, "127.0.0.1:9050")
	require.NoError(t, err)
	assert.Equal(t, 321, tip)
	enabled, proxyAddr := p.TorConfig()
	assert.True(t, enabled)
	assert.Equal(t, "127.0.0.1:9050", proxyAddr)
}

func TestSetTorConfigUnreachableKeepsPrevious(t *testing.T) {
	p, fake := newSwitchableElectrumBackend(t, "https://original.example/api")
	require.NoError(t, fake.SetProxy(true, "127.0.0.1:9050"))
	fake.torEnabled = true
	fake.torProxy = "127.0.0.1:9050"
	fake.badProxies["127.0.0.1:9999"] = true

	_, err := p.SetTorConfig(context.Background(), true, "127.0.0.1:9999")
	require.Error(t, err)
	enabled, proxyAddr := p.TorConfig()
	assert.True(t, enabled)
	assert.Equal(t, "127.0.0.1:9050", proxyAddr)
}

func TestSetTorConfigRejectsMalformedProxy(t *testing.T) {
	p, _ := newSwitchableElectrumBackend(t, "https://original.example/api")

	for _, bad := range []string{"", "   ", "noport", "127.0.0.1:", "127.0.0.1:abc", "127.0.0.1:70000", ":9050"} {
		_, err := p.SetTorConfig(context.Background(), true, bad)
		require.Errorf(t, err, "expected error for %q", bad)
		enabled, _ := p.TorConfig()
		assert.False(t, enabled)
	}
}

func TestNormalizeProxyAddr(t *testing.T) {
	got, err := normalizeProxyAddr("  127.0.0.1:9150  ")
	require.NoError(t, err)
	assert.Equal(t, "127.0.0.1:9150", got)
	assert.True(t, strings.HasPrefix(got, "127.0.0.1"))
}
