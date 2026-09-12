package bitnames

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"time"

	"github.com/gowebpki/jcs"
	"lukechampine.com/blake3"
)

const (
	commitTimeout = 10 * time.Second
	// A BitName holder picks this address, so the answer stays untrusted.
	commitMaxBody = 1 << 20
)

// checkGlobalAddress refuses an address that points back at the machine or at
// a private network. A BitName holder chooses it, so it can aim anywhere.
func checkGlobalAddress(address string) error {
	host, port, err := net.SplitHostPort(address)
	if err != nil {
		return fmt.Errorf("address %q is not host:port: %w", address, err)
	}
	if host == "" || port == "" {
		return fmt.Errorf("address %q is not host:port", address)
	}

	ips, err := net.LookupIP(host)
	if err != nil {
		return fmt.Errorf("resolve %q: %w", host, err)
	}
	if len(ips) == 0 {
		return fmt.Errorf("%q resolves to no address", host)
	}

	for _, ip := range ips {
		if !ip.IsGlobalUnicast() || ip.IsPrivate() || ip.IsLinkLocalUnicast() {
			return fmt.Errorf("%q resolves to the non-public address %s", host, ip)
		}
	}

	return nil
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

// FetchCommitment calls bitname_commit on the data server at address, and
// returns the JSON object it served with the digest that object commits to.
func FetchCommitment(ctx context.Context, address string) (json.RawMessage, string, error) {
	if err := checkGlobalAddress(address); err != nil {
		return nil, "", err
	}

	return fetchCommitmentFrom(ctx, address)
}

// fetchCommitmentFrom dials address without the public-address check. Only
// FetchCommitment and a test reach it.
func fetchCommitmentFrom(ctx context.Context, address string) (json.RawMessage, string, error) {
	server := &Client{
		baseURL: "http://" + address,
		http: &http.Client{
			Timeout: commitTimeout,
			// A redirect can aim at a private address the check above refused.
			CheckRedirect: func(req *http.Request, via []*http.Request) error {
				return fmt.Errorf("%s redirects, which this client refuses", address)
			},
		},
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
