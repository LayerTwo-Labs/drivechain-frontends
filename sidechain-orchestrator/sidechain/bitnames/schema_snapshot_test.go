package bitnames

import (
	"context"
	"encoding/json"
	"os"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestSchemaSnapshot validates the saved openapi_schema.json against a live
// BitNames node. The test is activated by setting BITNAMES_SCHEMA_VALIDATE=1
// and BITNAMES_RPC_PORT to the node's port. In normal `go test` runs it is
// skipped; in CI the dedicated workflow enables it after downloading the binary.
//
// To update the snapshot locally:
//
//	BITNAMES_SCHEMA_UPDATE=1 BITNAMES_RPC_PORT=6745 go test -run TestSchemaSnapshot ./sidechain/bitnames/
func TestSchemaSnapshot(t *testing.T) {
	if os.Getenv("BITNAMES_SCHEMA_VALIDATE") != "1" && os.Getenv("BITNAMES_SCHEMA_UPDATE") != "1" {
		t.Skip("BITNAMES_SCHEMA_VALIDATE or BITNAMES_SCHEMA_UPDATE not set; skipping live schema check")
	}

	port := os.Getenv("BITNAMES_RPC_PORT")
	if port == "" {
		t.Fatal("BITNAMES_RPC_PORT must be set for schema validation")
	}

	portNum, err := strconv.Atoi(port)
	if err != nil {
		t.Fatalf("invalid BITNAMES_RPC_PORT %q: %v", port, err)
	}

	c := NewClient("127.0.0.1", portNum)
	raw, err := c.OpenAPISchema(context.Background())
	require.NoError(t, err, "openapi_schema RPC failed — is the BitNames node running?")

	// Pretty-print for stable diffs.
	live, err := json.MarshalIndent(json.RawMessage(raw), "", "  ")
	require.NoError(t, err)

	snapshotPath := "testdata/openapi_schema.json"

	if os.Getenv("BITNAMES_SCHEMA_UPDATE") == "1" {
		require.NoError(t, os.MkdirAll("testdata", 0o755))
		require.NoError(t, os.WriteFile(snapshotPath, append(live, '\n'), 0o644))
		t.Log("snapshot updated")
		return
	}

	saved, err := os.ReadFile(snapshotPath)
	if os.IsNotExist(err) {
		t.Fatalf("snapshot %s does not exist — run with BITNAMES_SCHEMA_UPDATE=1 to create it", snapshotPath)
	}
	require.NoError(t, err)

	assert.JSONEq(t, string(saved), string(live),
		"openapi_schema diverged from snapshot; run with BITNAMES_SCHEMA_UPDATE=1 to refresh")
}
