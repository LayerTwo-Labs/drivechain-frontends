package bitassets

import (
	"context"
	"encoding/json"
	"os"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestSchemaSnapshot validates the saved openapi_schema.json against a
// freshly-generated schema. There are two ways to obtain the "live" schema:
//
//  1. CLI file (CI path): set BITASSETS_SCHEMA_VALIDATE_CLI=1 and
//     BITASSETS_CLI_SCHEMA to the path of a schema produced by
//     `bitassets-cli openapi-schema`. This avoids needing a full mainchain
//     stack just to validate the snapshot.
//
//  2. Live RPC (local-dev path): set BITASSETS_SCHEMA_VALIDATE=1 and
//     BITASSETS_RPC_PORT to the port of a running bitassets node.
//
// To update the snapshot from a live node:
//
//	BITASSETS_SCHEMA_UPDATE=1 BITASSETS_RPC_PORT=6002 go test -run TestSchemaSnapshot ./sidechain/bitassets/
//
// To update the snapshot from the CLI binary:
//
//	BITASSETS_SCHEMA_UPDATE_CLI=1 BITASSETS_CLI_SCHEMA=/path/to/schema.json go test -run TestSchemaSnapshot ./sidechain/bitassets/
func TestSchemaSnapshot(t *testing.T) {
	cliValidate := os.Getenv("BITASSETS_SCHEMA_VALIDATE_CLI") == "1"
	cliUpdate := os.Getenv("BITASSETS_SCHEMA_UPDATE_CLI") == "1"
	rpcValidate := os.Getenv("BITASSETS_SCHEMA_VALIDATE") == "1"
	rpcUpdate := os.Getenv("BITASSETS_SCHEMA_UPDATE") == "1"

	if !cliValidate && !cliUpdate && !rpcValidate && !rpcUpdate {
		t.Skip("no BITASSETS_SCHEMA_* env set; skipping live schema check")
	}

	var live []byte

	switch {
	case cliValidate || cliUpdate:
		schemaPath := os.Getenv("BITASSETS_CLI_SCHEMA")
		if schemaPath == "" {
			t.Fatal("BITASSETS_CLI_SCHEMA must point to the schema file produced by bitassets-cli")
		}
		raw, err := os.ReadFile(schemaPath)
		require.NoError(t, err, "reading CLI schema file")
		// Pretty-print for stable diffs.
		var buf json.RawMessage
		require.NoError(t, json.Unmarshal(raw, &buf))
		live, err = json.MarshalIndent(buf, "", "  ")
		require.NoError(t, err)

	case rpcValidate || rpcUpdate:
		port := os.Getenv("BITASSETS_RPC_PORT")
		if port == "" {
			t.Fatal("BITASSETS_RPC_PORT must be set for RPC schema validation")
		}
		portNum, err := strconv.Atoi(port)
		if err != nil {
			t.Fatalf("invalid BITASSETS_RPC_PORT %q: %v", port, err)
		}
		c := NewClient("127.0.0.1", portNum)
		raw, err := c.OpenAPISchema(context.Background())
		require.NoError(t, err, "openapi_schema RPC failed — is the bitassets node running?")
		live, err = json.MarshalIndent(json.RawMessage(raw), "", "  ")
		require.NoError(t, err)
	}

	snapshotPath := "testdata/openapi_schema.json"

	if cliUpdate || rpcUpdate {
		require.NoError(t, os.MkdirAll("testdata", 0o755))
		require.NoError(t, os.WriteFile(snapshotPath, append(live, '\n'), 0o644))
		t.Log("snapshot updated")
		return
	}

	saved, err := os.ReadFile(snapshotPath)
	if os.IsNotExist(err) {
		t.Fatalf("snapshot %s does not exist — run with BITASSETS_SCHEMA_UPDATE=1 to create it", snapshotPath)
	}
	require.NoError(t, err)

	assert.JSONEq(t, string(saved), string(live),
		"openapi_schema diverged from snapshot; run with BITASSETS_SCHEMA_UPDATE_CLI=1 or BITASSETS_SCHEMA_UPDATE=1 to refresh")
}
