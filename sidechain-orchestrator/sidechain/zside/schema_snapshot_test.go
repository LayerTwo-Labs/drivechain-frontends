package zside

import (
	"context"
	"encoding/json"
	"os"
	"reflect"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestSchemaSnapshot validates the saved openapi_schema.json against a
// freshly-generated schema. There are two ways to obtain the "live" schema:
//
//  1. CLI file (CI path): set ZSIDE_SCHEMA_VALIDATE_CLI=1 and
//     ZSIDE_CLI_SCHEMA to the path of a schema produced by
//     `zside-cli openapi-schema`. This avoids needing a full mainchain
//     stack just to validate the snapshot.
//
//  2. Live RPC (local-dev path): set ZSIDE_SCHEMA_VALIDATE=1 and
//     ZSIDE_RPC_PORT to the port of a running zside node.
//
// To update the snapshot from a live node:
//
//	ZSIDE_SCHEMA_UPDATE=1 ZSIDE_RPC_PORT=6002 go test -run TestSchemaSnapshot ./sidechain/zside/
//
// To update the snapshot from the CLI binary:
//
//	ZSIDE_SCHEMA_UPDATE_CLI=1 ZSIDE_CLI_SCHEMA=/path/to/schema.json go test -run TestSchemaSnapshot ./sidechain/zside/
func TestSchemaSnapshot(t *testing.T) {
	cliValidate := os.Getenv("ZSIDE_SCHEMA_VALIDATE_CLI") == "1"
	cliUpdate := os.Getenv("ZSIDE_SCHEMA_UPDATE_CLI") == "1"
	rpcValidate := os.Getenv("ZSIDE_SCHEMA_VALIDATE") == "1"
	rpcUpdate := os.Getenv("ZSIDE_SCHEMA_UPDATE") == "1"

	if !cliValidate && !cliUpdate && !rpcValidate && !rpcUpdate {
		t.Skip("no ZSIDE_SCHEMA_* env set; skipping live schema check")
	}

	var live []byte

	switch {
	case cliValidate || cliUpdate:
		schemaPath := os.Getenv("ZSIDE_CLI_SCHEMA")
		if schemaPath == "" {
			t.Fatal("ZSIDE_CLI_SCHEMA must point to the schema file produced by zside-cli")
		}
		raw, err := os.ReadFile(schemaPath)
		require.NoError(t, err, "reading CLI schema file")
		// Pretty-print for stable diffs.
		var buf json.RawMessage
		require.NoError(t, json.Unmarshal(raw, &buf))
		live, err = json.MarshalIndent(buf, "", "  ")
		require.NoError(t, err)

	case rpcValidate || rpcUpdate:
		port := os.Getenv("ZSIDE_RPC_PORT")
		if port == "" {
			t.Fatal("ZSIDE_RPC_PORT must be set for RPC schema validation")
		}
		portNum, err := strconv.Atoi(port)
		if err != nil {
			t.Fatalf("invalid ZSIDE_RPC_PORT %q: %v", port, err)
		}
		c := NewClient("127.0.0.1", portNum)
		raw, err := c.OpenAPISchema(context.Background())
		require.NoError(t, err, "openapi_schema RPC failed — is the zside node running?")
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
		t.Fatalf("snapshot %s does not exist — run with ZSIDE_SCHEMA_UPDATE=1 to create it", snapshotPath)
	}
	require.NoError(t, err)

	assert.JSONEq(t, string(saved), string(live),
		"openapi_schema diverged from snapshot; run with ZSIDE_SCHEMA_UPDATE_CLI=1 or ZSIDE_SCHEMA_UPDATE=1 to refresh")
}

// Every method the orchestrator sends to zSide must be one the snapshot node
// serves, or the call fails at run time with method not found.
func TestCalledMethodsAreInTheSnapshot(t *testing.T) {
	saved, err := os.ReadFile("testdata/openapi_schema.json")
	require.NoError(t, err)
	var schema struct {
		Paths map[string]json.RawMessage `json:"paths"`
	}
	require.NoError(t, json.Unmarshal(saved, &schema))
	require.NotEmpty(t, schema.Paths)

	handler, calls := recordingHandler(t, nil)
	ctx := context.Background()
	value := reflect.ValueOf(handler)
	for i := range value.NumMethod() {
		method := value.Type().Method(i)
		if method.Name == "CallRaw" || method.Type.NumIn() != 3 {
			continue
		}
		request := reflect.New(method.Type.In(2).Elem())
		msg := request.Elem().FieldByName("Msg")
		msg.Set(reflect.New(msg.Type().Elem()))
		out := value.Method(i).Call([]reflect.Value{reflect.ValueOf(ctx), request})
		require.Nil(t, out[1].Interface(), method.Name)
	}

	node := &Node{JSONRPCProxy: handler.proxy}
	_, _, err = node.GetBalance(ctx)
	require.NoError(t, err)
	_, err = node.WalletAddressList(ctx)
	require.NoError(t, err)
	_, err = node.GetBlockTemplate(ctx)
	require.NoError(t, err)
	_, err = node.ConnectBlock(ctx, json.RawMessage(`{}`), "aa")
	require.NoError(t, err)
	_, err = node.GetBmmInclusions(ctx, "aa")
	require.NoError(t, err)
	_, err = node.ChainHolds(ctx, "aa", 1)
	require.NoError(t, err)
	_, err = node.TemplateOnTip(ctx, json.RawMessage(`{}`))
	require.NoError(t, err)
	_, err = node.GetPendingWithdrawalBundle(ctx)
	require.NoError(t, err)
	_, err = node.GetLatestFailedWithdrawalBundleHeight(ctx)
	require.NoError(t, err)

	require.NotEmpty(t, *calls)
	for _, call := range *calls {
		name := call.Method
		// The schema names sidechain_wealth after its Rust function.
		if name == "sidechain_wealth" {
			name = "sidechain_wealth_sats"
		}
		assert.Contains(t, schema.Paths, name, "zSide serves no method %s", call.Method)
	}
}
