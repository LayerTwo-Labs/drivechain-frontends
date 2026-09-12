package bitnames

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"net/netip"
	"slices"
	"strconv"
	"sync"
	"time"

	"github.com/gowebpki/jcs"
	"lukechampine.com/blake3"
)

const (
	commitTimeout = 10 * time.Second
	// A BitName holder picks this address, so the answer stays untrusted.
	commitMaxBody = 1 << 20
)

// resolveGlobalAddress refuses an address that points back at the machine or at
// a private network. A BitName holder chooses it, so it can aim anywhere.
func resolveGlobalAddress(ctx context.Context, address string) ([]netip.Addr, string, error) {
	host, port, err := net.SplitHostPort(address)
	if err != nil {
		return nil, "", fmt.Errorf("address %q is not host:port: %w", address, err)
	}
	if host == "" || port == "" {
		return nil, "", fmt.Errorf("address %q is not host:port", address)
	}

	// A stalled authoritative server holds a lookup that carries no deadline.
	if _, err := portNumber(port); err != nil {
		return nil, "", fmt.Errorf("address %q: %w", address, err)
	}

	ips, err := net.DefaultResolver.LookupIP(ctx, "ip", host)
	if err != nil {
		return nil, "", fmt.Errorf("resolve %q: %w", host, err)
	}
	if len(ips) == 0 {
		return nil, "", fmt.Errorf("%q resolves to no address", host)
	}

	addrs := make([]netip.Addr, 0, len(ips))
	for _, ip := range ips {
		addr, ok := netip.AddrFromSlice(ip)
		if !ok || !ip.IsGlobalUnicast() || isSpecialUse(ip) {
			return nil, "", fmt.Errorf("%q resolves to the non-public address %s", host, ip)
		}
		addrs = append(addrs, addr.Unmap())
	}

	return addrs, port, nil
}

// specialUsePrefixes holds the ranges that Go reports as global unicast, and
// that still reach a carrier, a lab, or the machine itself.
var specialUsePrefixes = []netip.Prefix{
	netip.MustParsePrefix("0.0.0.0/8"),
	netip.MustParsePrefix("10.0.0.0/8"),
	netip.MustParsePrefix("100.64.0.0/10"),
	netip.MustParsePrefix("127.0.0.0/8"),
	netip.MustParsePrefix("169.254.0.0/16"),
	netip.MustParsePrefix("172.16.0.0/12"),
	netip.MustParsePrefix("192.0.0.0/24"),
	netip.MustParsePrefix("192.0.2.0/24"),
	netip.MustParsePrefix("192.88.99.0/24"),
	netip.MustParsePrefix("192.168.0.0/16"),
	netip.MustParsePrefix("198.18.0.0/15"),
	netip.MustParsePrefix("198.51.100.0/24"),
	netip.MustParsePrefix("203.0.113.0/24"),
	netip.MustParsePrefix("224.0.0.0/4"),
	netip.MustParsePrefix("240.0.0.0/4"),
	netip.MustParsePrefix("::/128"),
	netip.MustParsePrefix("::1/128"),
	netip.MustParsePrefix("::ffff:0:0:0/96"),
	netip.MustParsePrefix("64:ff9b::/96"),
	netip.MustParsePrefix("64:ff9b:1::/48"),
	netip.MustParsePrefix("100::/64"),
	netip.MustParsePrefix("2001::/23"),
	netip.MustParsePrefix("2001:db8::/32"),
	netip.MustParsePrefix("2002::/16"),
	netip.MustParsePrefix("3fff::/20"),
	netip.MustParsePrefix("5f00::/16"),
	netip.MustParsePrefix("fc00::/7"),
	netip.MustParsePrefix("fe80::/10"),
	netip.MustParsePrefix("ff00::/8"),
}

func isSpecialUse(ip net.IP) bool {
	addr, ok := netip.AddrFromSlice(ip)
	if !ok {
		return true
	}
	addr = addr.Unmap()

	for _, prefix := range specialUsePrefixes {
		if prefix.Contains(addr) {
			return true
		}
	}

	return false
}

// CommitmentFor returns the hex BLAKE3-256 digest of raw in its RFC 8785
// canonical form. This is the digest a BitName data commitment holds.
func CommitmentFor(raw json.RawMessage) (string, error) {
	canonical, err := jcs.Transform(raw)
	if err != nil {
		return "", fmt.Errorf("canonicalize commitment data: %w", err)
	}

	sum := blake3.Sum256(canonical)
	return hex.EncodeToString(sum[:]), nil
}

// FetchCommitment reads bitname_commit with the supplied HTTP Host and returns its data and digest.
func FetchCommitment(ctx context.Context, address string) (json.RawMessage, string, error) {
	return fetchCommitment(ctx, address, resolveGlobalAddress)
}

func fetchCommitment(
	ctx context.Context, address string,
	resolve func(context.Context, string) ([]netip.Addr, string, error),
) (json.RawMessage, string, error) {
	ctx, cancel := context.WithTimeout(ctx, commitTimeout)
	defer cancel()

	addrs, port, err := resolve(ctx, address)
	if err != nil {
		return nil, "", err
	}
	return fetchCommitmentFrom(ctx, address, pinnedDialer(addrs, port, nil))
}

// FetchCommitmentAt reads bitname_commit from a public IP and returns its data, digest, and socket addresses.
func FetchCommitmentAt(
	ctx context.Context, address string,
) (json.RawMessage, string, ResolvedAddresses, error) {
	return fetchCommitmentAt(ctx, address, resolveGlobalAddress)
}

func fetchCommitmentAt(
	ctx context.Context, address string,
	resolve func(context.Context, string) ([]netip.Addr, string, error),
) (json.RawMessage, string, ResolvedAddresses, error) {
	ctx, cancel := context.WithTimeout(ctx, commitTimeout)
	defer cancel()

	addrs, port, err := resolve(ctx, address)
	if err != nil {
		return nil, "", ResolvedAddresses{}, err
	}
	number, err := portNumber(port)
	if err != nil {
		return nil, "", ResolvedAddresses{}, err
	}

	var served servedAddress
	served.offer(addrs, port)
	lastErr := fmt.Errorf("no address to read")
	for i, addr := range addrs {
		endpoint := netip.AddrPortFrom(addr, number)
		requestCtx, cancelRequest := context.WithTimeout(ctx, dialTimeout(ctx, len(addrs)-i))
		raw, digest, err := fetchCommitmentFrom(requestCtx, endpoint.String(), pinnedDialer([]netip.Addr{addr}, port, nil))
		cancelRequest()
		if err == nil {
			served.set(endpoint)
			return raw, digest, served.resolved(), nil
		}
		served.reject(addr)
		lastErr = err
	}
	return nil, "", ResolvedAddresses{}, lastErr
}

// servedAddress records the address the dialer reached. A host with several
// records can answer on a later one, and a BitName must hold the address that
// served the commitment, not the first record DNS returned.
type servedAddress struct {
	mu       sync.Mutex
	addr     netip.AddrPort
	verified []netip.AddrPort
}

// offer records every address the guard accepted. The dial proves one of them,
// and the chain holds one of each family.
func (s *servedAddress) offer(addrs []netip.Addr, port string) {
	number, err := portNumber(port)
	if err != nil {
		return
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, addr := range addrs {
		s.verified = append(s.verified, netip.AddrPortFrom(addr, number))
	}
}

func (s *servedAddress) set(addr netip.AddrPort) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if !s.addr.IsValid() {
		s.addr = addr
	}
}

func (s *servedAddress) reject(addr netip.Addr) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.verified = slices.DeleteFunc(s.verified, func(candidate netip.AddrPort) bool {
		return candidate.Addr() == addr
	})
}

func (s *servedAddress) resolved() ResolvedAddresses {
	s.mu.Lock()
	defer s.mu.Unlock()
	if !s.addr.IsValid() {
		return ResolvedAddresses{}
	}

	var resolved ResolvedAddresses
	if s.addr.Addr().Is4() {
		resolved.V4 = s.addr.String()
	} else {
		resolved.V6 = s.addr.String()
	}

	// The dial proves one family. The other one passed the same guard, and a
	// resolver reads the ipv4 address first, so both belong on the chain.
	for _, candidate := range s.verified {
		if candidate.Addr().Is4() && resolved.V4 == "" {
			resolved.V4 = candidate.String()
		}
		if !candidate.Addr().Is4() && resolved.V6 == "" {
			resolved.V6 = candidate.String()
		}
	}
	return resolved
}

// ResolvedAddresses holds the socket addresses a host resolves to, as
// host:port. A BitName holds one of each.
type ResolvedAddresses struct {
	V4 string
	V6 string
}

func portNumber(port string) (uint16, error) {
	parsed, err := strconv.ParseUint(port, 10, 16)
	if err != nil {
		return 0, fmt.Errorf("port %q is not a number", port)
	}
	if parsed == 0 {
		return 0, fmt.Errorf("port 0 reaches nothing")
	}
	return uint16(parsed), nil
}

// pinnedDialer dials only the addresses that resolveGlobalAddress accepts. A
// second lookup can answer with a private address that the check never sees.
func pinnedDialer(
	addrs []netip.Addr, port string, served *servedAddress,
) func(context.Context, string, string) (net.Conn, error) {
	var dialer net.Dialer

	return func(ctx context.Context, network, _ string) (net.Conn, error) {
		var lastErr error
		// A host with both an A record and an AAAA record leaves one of them
		// unreachable on many networks. A share of the deadline for each
		// address keeps the first one from taking all of it.
		share := dialTimeout(ctx, len(addrs))
		for _, addr := range addrs {
			attempt, cancel := context.WithTimeout(ctx, share)
			conn, err := dialer.DialContext(attempt, network, net.JoinHostPort(addr.String(), port))
			cancel()
			if err == nil {
				if served != nil {
					if number, numberErr := portNumber(port); numberErr == nil {
						served.set(netip.AddrPortFrom(addr, number))
					}
				}
				return conn, nil
			}
			if served != nil {
				served.reject(addr)
			}
			lastErr = err
		}
		if lastErr == nil {
			lastErr = fmt.Errorf("no address to dial")
		}

		return nil, lastErr
	}
}

// dialTimeout splits the time left between the addresses still to try.
func dialTimeout(ctx context.Context, addrs int) time.Duration {
	if addrs < 1 {
		addrs = 1
	}
	deadline, ok := ctx.Deadline()
	if !ok {
		return commitTimeout / time.Duration(addrs)
	}
	left := time.Until(deadline)
	if left <= 0 {
		return time.Nanosecond
	}
	return left / time.Duration(addrs)
}

// fetchCommitmentFrom dials address without the public-address check. Only
// FetchCommitment and a test reach it.
func fetchCommitmentFrom(
	ctx context.Context,
	address string,
	dial func(context.Context, string, string) (net.Conn, error),
) (json.RawMessage, string, error) {
	client := &http.Client{
		Timeout: commitTimeout,
		// A redirect can aim at a private address the check above refuses.
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return fmt.Errorf("%s redirects, which this client refuses", address)
		},
	}
	if dial != nil {
		transport := &http.Transport{DialContext: dial}
		// This transport serves one call, so its idle connection and the read
		// goroutine of that connection stay for the life of the process.
		defer transport.CloseIdleConnections()
		client.Transport = transport
	}

	server := &Client{
		baseURL: "http://" + address,
		http:    client,
		maxBody: commitMaxBody,
	}

	// The protocol omits the bytes argument on the first call to an address.
	raw, err := server.call(ctx, "bitname_commit", []any{nil})
	if err != nil {
		return nil, "", fmt.Errorf("read bitname_commit from %s: %w", address, err)
	}

	digest, err := CommitmentFor(raw)
	if err != nil {
		return nil, "", err
	}

	return raw, digest, nil
}
