package orchestrator

import (
	"encoding/json"
	"testing"
)

// TestMergeWithEmbedded_FillsInMissingFields is the regression guard for the
// "stale on-disk chains_config.json silently drops critical fields" bug.
//
// Symptom: a user's on-disk chains_config.json was seeded from a bundled
// asset before is_bitcoin_core / health_check were introduced. Without
// merging, the orch parsed only what was on disk, lost is_bitcoin_core,
// and routed bitcoind through the generic JSONRPCHealthCheck (no OnSync)
// instead of BitcoindHealthCheck. UI never received a single block height.
func TestMergeWithEmbedded_FillsInMissingFields(t *testing.T) {
	// Stale overlay: bitcoincore is named but missing is_bitcoin_core,
	// health_check, dependencies, startup_log_patterns.
	overlay := []byte(`{
		"version": 1,
		"binaries": {
			"bitcoincore": {
				"name": "Bitcoin Core",
				"port": 0,
				"hashes": {"macos": {"sha256": "user-customized"}}
			}
		}
	}`)

	merged, err := mergeWithEmbedded(overlay)
	if err != nil {
		t.Fatalf("mergeWithEmbedded: %v", err)
	}

	var got map[string]any
	if err := json.Unmarshal(merged, &got); err != nil {
		t.Fatalf("unmarshal merged: %v", err)
	}
	bins, _ := got["binaries"].(map[string]any)
	core, _ := bins["bitcoincore"].(map[string]any)
	if core == nil {
		t.Fatal("bitcoincore missing from merged config")
	}

	if isBC, _ := core["is_bitcoin_core"].(bool); !isBC {
		t.Error("is_bitcoin_core fell through as false; embedded default lost")
	}

	hc, _ := core["health_check"].(map[string]any)
	if hc == nil {
		t.Fatal("health_check fell through as missing; embedded default lost")
	}
	if hc["type"] != "jsonrpc" {
		t.Errorf("health_check.type = %v, want jsonrpc", hc["type"])
	}

	// User overrides must be preserved on top of embedded.
	hashes, _ := core["hashes"].(map[string]any)
	macos, _ := hashes["macos"].(map[string]any)
	if macos == nil || macos["sha256"] != "user-customized" {
		t.Errorf("user hash override lost in merge: hashes=%v", hashes)
	}
}

// TestMergeWithEmbedded_OverlayWinsForLeafScalars verifies that on-disk
// values for present keys actually override embedded defaults — not just
// fill-in semantics. A user editing port should still take effect.
func TestMergeWithEmbedded_OverlayWinsForLeafScalars(t *testing.T) {
	overlay := []byte(`{
		"binaries": {
			"bitcoincore": {"port": 12345}
		}
	}`)

	merged, err := mergeWithEmbedded(overlay)
	if err != nil {
		t.Fatalf("mergeWithEmbedded: %v", err)
	}
	var got map[string]any
	_ = json.Unmarshal(merged, &got)
	core := got["binaries"].(map[string]any)["bitcoincore"].(map[string]any)
	if core["port"].(float64) != 12345 {
		t.Errorf("port = %v, want 12345 (overlay should win)", core["port"])
	}
	// And embedded defaults still fill in.
	if isBC, _ := core["is_bitcoin_core"].(bool); !isBC {
		t.Error("is_bitcoin_core fell through as false")
	}
}

// TestMergeWithEmbedded_ProducesBitcoindHealthCheck closes the loop end
// to end: a stale overlay merged + parsed must produce a BinaryConfig
// where IsBitcoinCore is true and HealthCheckType routes through the
// branch that wires OnSync.
func TestMergeWithEmbedded_ProducesBitcoindHealthCheck(t *testing.T) {
	overlay := []byte(`{
		"version": 1,
		"binaries": {
			"bitcoincore": {"name": "Bitcoin Core", "port": 0}
		}
	}`)
	merged, err := mergeWithEmbedded(overlay)
	if err != nil {
		t.Fatalf("merge: %v", err)
	}
	configs, err := parseConfigJSON(merged)
	if err != nil {
		t.Fatalf("parse: %v", err)
	}

	var core *BinaryConfig
	for i := range configs {
		if configs[i].Name == "bitcoind" {
			core = &configs[i]
			break
		}
	}
	if core == nil {
		t.Fatal("bitcoind config missing after merge")
	}
	if !core.IsBitcoinCore {
		t.Error("IsBitcoinCore false after merge — BitcoindHealthCheck branch will be skipped, blockchain_sync will never stream")
	}
	if core.HealthCheckType != HealthCheckJSONRPC {
		t.Errorf("HealthCheckType = %v, want HealthCheckJSONRPC", core.HealthCheckType)
	}
}
