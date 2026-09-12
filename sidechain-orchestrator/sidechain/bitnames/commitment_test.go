package bitnames

import (
	"context"
	"encoding/json"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestCommitmentForIgnoresKeyOrderAndWhitespace(t *testing.T) {
	// RFC 8785 canonicalization is the point: a server that reorders keys or
	// reformats must still produce the digest the chain holds.
	a := json.RawMessage(`{"email":"bo@bb.no","pgp":"ABCD1234"}`)
	b := json.RawMessage("{\n  \"pgp\" : \"ABCD1234\",\n  \"email\" : \"bo@bb.no\"\n}")

	got, err := CommitmentFor(a)
	require.NoError(t, err)

	other, err := CommitmentFor(b)
	require.NoError(t, err)

	assert.Equal(t, got, other)
	assert.Len(t, got, 64)
}

func TestCommitmentForChangesWithData(t *testing.T) {
	original, err := CommitmentFor(json.RawMessage(`{"email":"bo@bb.no"}`))
	require.NoError(t, err)

	changed, err := CommitmentFor(json.RawMessage(`{"email":"someone@bb.no"}`))
	require.NoError(t, err)

	assert.NotEqual(t, original, changed)
}

func TestCommitmentForEmptyObject(t *testing.T) {
	got, err := CommitmentFor(json.RawMessage(`{}`))
	require.NoError(t, err)
	assert.Len(t, got, 64)
}

func TestCommitmentForRejectsInvalidJSON(t *testing.T) {
	_, err := CommitmentFor(json.RawMessage(`{"email":`))
	require.Error(t, err)
}

func TestFetchCommitmentReturnsDataAndDigest(t *testing.T) {
	answer := map[string]string{"email": "bo@bb.no", "pgp": "ABCD1234"}
	srv := fakeRPC(t, map[string]interface{}{"bitname_commit": answer})
	defer srv.Close()

	raw, digest, err := FetchCommitment(context.Background(), strings.TrimPrefix(srv.URL, "http://"))
	require.NoError(t, err)

	want, err := CommitmentFor(raw)
	require.NoError(t, err)

	assert.Equal(t, want, digest)
	assert.Contains(t, string(raw), "bo@bb.no")
}

func TestFetchCommitmentErrorsWhenServerIsDown(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{"bitname_commit": map[string]string{}})
	address := strings.TrimPrefix(srv.URL, "http://")
	srv.Close()

	_, _, err := FetchCommitment(context.Background(), address)
	require.Error(t, err)
}
