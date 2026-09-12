package bitnames

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/gowebpki/jcs"
	"lukechampine.com/blake3"
)

const commitTimeout = 10 * time.Second

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
	server := &Client{
		baseURL: "http://" + address,
		http:    &http.Client{Timeout: commitTimeout},
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
