package bitnames

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestResolveGlobalAddressRejectsNonPublic(t *testing.T) {
	// A BitName holder picks this address, so it can aim at the victim's own
	// machine or network.
	for _, address := range []string{
		"127.0.0.1:6002",
		"localhost:6002",
		"10.0.0.1:6002",
		"192.168.1.1:6002",
		"172.16.0.1:6002",
		"169.254.1.1:6002",
		"[::1]:6002",
		// Go calls these global unicast, and they still reach a carrier or a lab.
		"100.64.0.1:6002",
		"198.18.0.1:6002",
		"192.0.0.8:6002",
		"203.0.113.7:6002",
		"198.51.100.1:6002",
		"192.0.2.1:6002",
		"240.0.0.1:6002",
		"[2001:db8::1]:6002",
		"[fc00::1]:6002",
		// A translator carries these to an address the check refuses.
		"[::ffff:0:10.0.0.1]:6002",
		"[::ffff:10.0.0.1]:6002",
		"[64:ff9b::10.0.0.1]:6002",
		// The IPv6 twins of the IPv4 ranges above.
		"[2001:2::1]:6002",
		"[2001::1]:6002",
		"[2001:20::1]:6002",
		"[2002::1]:6002",
		"[3fff::1]:6002",
		"[5f00::1]:6002",
	} {
		_, _, err := resolveGlobalAddress(context.Background(), address)
		require.Error(t, err, "address %s must not pass", address)
	}
}

func TestResolveGlobalAddressRejectsMalformed(t *testing.T) {
	for _, address := range []string{"", "psztorc.com", "psztorc.com:", ":6002"} {
		_, _, err := resolveGlobalAddress(context.Background(), address)
		require.Error(t, err, "address %q must not pass", address)
	}
}

func TestResolveGlobalAddressAcceptsPublic(t *testing.T) {
	// A literal address skips DNS, so this test needs no network.
	addrs, port, err := resolveGlobalAddress(context.Background(), "8.8.8.8:6002")
	require.NoError(t, err)
	assert.Equal(t, "6002", port)
	assert.Equal(t, []netip.Addr{netip.MustParseAddr("8.8.8.8")}, addrs)

	_, _, err = resolveGlobalAddress(context.Background(), "[2606:4700:4700::1111]:6002")
	require.NoError(t, err)
}

func TestPinnedDialerIgnoresTheAddressItGets(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{"bitname_commit": map[string]string{"a": "b"}})
	defer srv.Close()

	host, port, err := net.SplitHostPort(strings.TrimPrefix(srv.URL, "http://"))
	require.NoError(t, err)
	pinned, err := netip.ParseAddr(host)
	require.NoError(t, err)

	// A rebinding answer gives the name a private address after the check. The
	// dialer holds the checked address, so the second answer reaches nothing.
	conn, err := pinnedDialer([]netip.Addr{pinned}, port, nil)(context.Background(), "tcp", "10.0.0.1:6002")
	require.NoError(t, err)
	defer func() { _ = conn.Close() }()

	assert.Equal(t, srv.Listener.Addr().String(), conn.RemoteAddr().String())
}

func TestFetchCommitmentRefusesLoopback(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{"bitname_commit": map[string]string{"a": "b"}})
	defer srv.Close()

	// The test server listens on loopback, which is exactly what the guard stops.
	_, _, err := FetchCommitment(context.Background(), strings.TrimPrefix(srv.URL, "http://"))
	require.Error(t, err)
	assert.Contains(t, err.Error(), "non-public")
}

func TestCallRefusesAnswerOverTheCap(t *testing.T) {
	big := strings.Repeat("x", 4096)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		body, err := json.Marshal(rpcResponse{Result: json.RawMessage(`"` + big + `"`)})
		require.NoError(t, err)
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write(body)
	}))
	defer srv.Close()

	capped := &Client{baseURL: srv.URL, http: srv.Client(), maxBody: 512}
	_, err := capped.call(context.Background(), "bitname_commit", nil)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "larger than 512 bytes")

	uncapped := &Client{baseURL: srv.URL, http: srv.Client()}
	_, err = uncapped.call(context.Background(), "bitname_commit", nil)
	require.NoError(t, err)
}

// A host with an A record and an AAAA record leaves one of them unreachable on
// many networks. The first address must not take the whole deadline.
func TestPinnedDialerSplitsTheDeadline(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{"bitname_commit": map[string]string{"a": "b"}})
	defer srv.Close()

	host, port, err := net.SplitHostPort(strings.TrimPrefix(srv.URL, "http://"))
	require.NoError(t, err)
	live, err := netip.ParseAddr(host)
	require.NoError(t, err)

	// 203.0.113.7 is TEST-NET-3, which drops every packet, so the first dial
	// runs to its own deadline instead of the whole request deadline.
	dead := netip.MustParseAddr("203.0.113.7")

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	start := time.Now()
	var served servedAddress
	conn, err := pinnedDialer([]netip.Addr{dead, live}, port, &served)(ctx, "tcp", "ignored:0")
	require.NoError(t, err, "the dialer must reach the second address")
	defer func() { _ = conn.Close() }()

	assert.Less(t, time.Since(start), 2*time.Second)
	assert.Equal(t, srv.Listener.Addr().String(), conn.RemoteAddr().String())

	// A BitName must hold the address that answered, not the first record.
	resolved := served.resolved()
	assert.Equal(t, srv.Listener.Addr().String(), resolved.V4)
	assert.Empty(t, resolved.V6)
}

func TestDialTimeoutSplitsTheTimeLeft(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	assert.InDelta(t, float64(5*time.Second), float64(dialTimeout(ctx, 2)), float64(100*time.Millisecond))
	assert.InDelta(t, float64(10*time.Second), float64(dialTimeout(ctx, 0)), float64(100*time.Millisecond))

	past, cancelPast := context.WithTimeout(context.Background(), -time.Second)
	defer cancelPast()
	assert.Equal(t, time.Nanosecond, dialTimeout(past, 2))
}

// ReadCommitment gives the caller the address it registers, so an empty answer
// leaves the form with nothing to send.
func TestFetchCommitmentAtReportsTheServedAddress(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{"bitname_commit": map[string]string{"site": "psztorc.com"}})
	defer srv.Close()

	raw, digest, served, err := FetchCommitmentAt(context.Background(), strings.TrimPrefix(srv.URL, "http://"))
	require.Error(t, err, "the test server listens on loopback, which the guard refuses")
	assert.Nil(t, raw)
	assert.Empty(t, digest)
	assert.Empty(t, served.V4)

	var recorded servedAddress
	recorded.set(netip.MustParseAddrPort("203.0.113.7:6002"))
	assert.Equal(t, "203.0.113.7:6002", recorded.resolved().V4)
	assert.Empty(t, recorded.resolved().V6)

	var six servedAddress
	six.set(netip.MustParseAddrPort("[2606:4700::1111]:6002"))
	assert.Equal(t, "[2606:4700::1111]:6002", six.resolved().V6)
	assert.Empty(t, six.resolved().V4)
}

// A service name has no port number, and the chain cannot hold ":0".
func TestResolveGlobalAddressRefusesANamedPort(t *testing.T) {
	for _, address := range []string{"psztorc.com:http", "psztorc.com:0", "8.8.8.8:https"} {
		_, _, err := resolveGlobalAddress(context.Background(), address)
		require.Error(t, err, "address %s must not pass", address)
	}
}

// A BitName holds one address of each family. The dial proves one, and the
// other passed the same guard, so both belong on the chain.
func TestServedAddressFillsBothFamilies(t *testing.T) {
	var served servedAddress
	served.offer([]netip.Addr{
		netip.MustParseAddr("203.0.113.7"),
		netip.MustParseAddr("2606:4700::1111"),
	}, "6002")
	served.set(netip.MustParseAddrPort("[2606:4700::1111]:6002"))

	resolved := served.resolved()
	assert.Equal(t, "[2606:4700::1111]:6002", resolved.V6, "the dial proved this one")
	assert.Equal(t, "203.0.113.7:6002", resolved.V4, "the guard accepted this one")
}

// No dial means no address to register.
func TestServedAddressStaysEmptyWithoutADial(t *testing.T) {
	var served servedAddress
	served.offer([]netip.Addr{netip.MustParseAddr("203.0.113.7")}, "6002")
	assert.Empty(t, served.resolved().V4)
	assert.Empty(t, served.resolved().V6)
}

func TestCommitmentOmitsTheFailedAddress(t *testing.T) {
	listener, err := net.Listen("tcp6", "[::1]:0")
	require.NoError(t, err)
	server := httptest.NewUnstartedServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		err := json.NewEncoder(w).Encode(rpcResponse{Result: json.RawMessage(`{"site":"example.org"}`)})
		assert.NoError(t, err)
	}))
	require.NoError(t, server.Listener.Close())
	server.Listener = listener
	server.Start()
	t.Cleanup(server.Close)

	_, port, err := net.SplitHostPort(listener.Addr().String())
	require.NoError(t, err)
	addrs := []netip.Addr{netip.MustParseAddr("127.0.0.1"), netip.MustParseAddr("::1")}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	resolve := func(context.Context, string) ([]netip.Addr, string, error) {
		return addrs, port, nil
	}
	_, digest, resolved, err := fetchCommitmentAt(ctx, "example.org:"+port, resolve)
	require.NoError(t, err)
	require.NotEmpty(t, digest)
	assert.Empty(t, resolved.V4)
	assert.Equal(t, listener.Addr().String(), resolved.V6)
	address, err := dataServerAddress(BitNameData{SocketAddrV4: &resolved.V4, SocketAddrV6: &resolved.V6})
	require.NoError(t, err)
	assert.Equal(t, listener.Addr().String(), address)
}

func TestCommitmentUsesNumericHost(t *testing.T) {
	const domain = "example.org:6002"
	const numericData = `{"site":"numeric"}`
	hosts := make(chan string, 4)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		hosts <- r.Host
		data := json.RawMessage(numericData)
		if r.Host == domain {
			data = json.RawMessage(`{"site":"domain"}`)
		}
		w.Header().Set("Content-Type", "application/json")
		assert.NoError(t, json.NewEncoder(w).Encode(rpcResponse{Result: data}))
	}))
	t.Cleanup(server.Close)
	endpoint := netip.MustParseAddrPort(server.Listener.Addr().String())
	resolve := func(_ context.Context, address string) ([]netip.Addr, string, error) {
		require.Equal(t, domain, address)
		_, port, err := net.SplitHostPort(server.Listener.Addr().String())
		return []netip.Addr{endpoint.Addr()}, port, err
	}

	raw, digest, served, err := fetchCommitmentAt(context.Background(), domain, resolve)
	require.NoError(t, err)
	assert.JSONEq(t, numericData, string(raw))
	want, err := CommitmentFor(json.RawMessage(numericData))
	require.NoError(t, err)
	assert.Equal(t, want, digest)
	assert.Equal(t, endpoint.String(), served.V4)
	require.Len(t, hosts, 1)
	assert.Equal(t, endpoint.String(), <-hosts)

	t.Run("stored domain", func(t *testing.T) {
		raw, digest, err := fetchCommitment(context.Background(), domain, resolve)
		require.NoError(t, err)
		const domainData = `{"site":"domain"}`
		assert.JSONEq(t, domainData, string(raw))
		want, err := CommitmentFor(json.RawMessage(domainData))
		require.NoError(t, err)
		assert.Equal(t, want, digest)
		require.Len(t, hosts, 1)
		assert.Equal(t, domain, <-hosts)
	})
}

func TestCommitmentTriesNextAddressAfterRequestTimeout(t *testing.T) {
	slow := httptest.NewServer(http.HandlerFunc(func(_ http.ResponseWriter, r *http.Request) {
		var request rpcRequest
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			t.Error(err)
			return
		}
		<-r.Context().Done()
	}))
	t.Cleanup(slow.Close)
	_, port, err := net.SplitHostPort(slow.Listener.Addr().String())
	require.NoError(t, err)
	listener, err := net.Listen("tcp6", "[::1]:"+port)
	require.NoError(t, err)
	server := httptest.NewUnstartedServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, listener.Addr().String(), r.Host)
		w.Header().Set("Content-Type", "application/json")
		assert.NoError(t, json.NewEncoder(w).Encode(rpcResponse{Result: json.RawMessage(`{"site":"numeric"}`)}))
	}))
	require.NoError(t, server.Listener.Close())
	server.Listener = listener
	server.Start()
	t.Cleanup(server.Close)
	resolve := func(context.Context, string) ([]netip.Addr, string, error) {
		return []netip.Addr{netip.MustParseAddr("127.0.0.1"), netip.MustParseAddr("::1")}, port, nil
	}
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	raw, _, served, err := fetchCommitmentAt(ctx, "example.org:"+port, resolve)
	require.NoError(t, err)
	assert.NoError(t, ctx.Err())
	assert.JSONEq(t, `{"site":"numeric"}`, string(raw))
	assert.Empty(t, served.V4)
	assert.Equal(t, listener.Addr().String(), served.V6)
}
