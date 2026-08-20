package orchestrator

import (
	"testing"
)

func ecashVariantConfig() BinaryConfig {
	return BinaryConfig{
		Name:          "bitcoind",
		IsBitcoinCore: true,
		ChainLayer:    1,
		Variants: map[string]CoreVariantSpec{
			"ecash": {
				ID:        "ecash",
				Subfolder: "{ecash}",
				BaseURL:   "https://releases.drivechain.info/",
				Files: map[string]string{
					"linux-x86_64": "L1-ecash-bitcoin-{ecash}-x86_64-unknown-linux-gnu.zip",
					"macos-arm64":  "L1-ecash-bitcoin-{ecash}-aarch64-apple-darwin.zip",
				},
			},
			"patched": {ID: "patched", Subfolder: "drivechain-patched", Files: map[string]string{"linux-x86_64": "patched.zip"}},
		},
	}
}

func TestExpandECashPlaceholder(t *testing.T) {
	got := expandECashPlaceholder(ecashVariantConfig(), "drynet3")

	v := got.Variants["ecash"]
	if v.Subfolder != "drynet3" {
		t.Errorf("subfolder = %q, want drynet3", v.Subfolder)
	}
	if want := "L1-ecash-bitcoin-drynet3-x86_64-unknown-linux-gnu.zip"; v.Files["linux-x86_64"] != want {
		t.Errorf("linux file = %q, want %q", v.Files["linux-x86_64"], want)
	}
	if want := "L1-ecash-bitcoin-drynet3-aarch64-apple-darwin.zip"; v.Files["macos-arm64"] != want {
		t.Errorf("macos file = %q, want %q", v.Files["macos-arm64"], want)
	}
	if p := got.Variants["patched"]; p.Subfolder != "drivechain-patched" || p.Files["linux-x86_64"] != "patched.zip" {
		t.Errorf("non-ecash variant must be untouched, got %+v", p)
	}
}

// An empty id means the catalog carried no generation. Leaving the placeholder
// in place makes the download fail loudly rather than fetching a wrong file.
func TestExpandECashPlaceholderEmptyIDLeavesConfig(t *testing.T) {
	got := expandECashPlaceholder(ecashVariantConfig(), "")
	if got.Variants["ecash"].Subfolder != "{ecash}" {
		t.Errorf("subfolder = %q, want the placeholder left alone", got.Variants["ecash"].Subfolder)
	}
}

// The chains_config.json watcher reinstates raw configs on every file change,
// so expansion has to survive a reload rather than happening once at boot.
func TestUpdateConfigsExpandsPlaceholder(t *testing.T) {
	o := &Orchestrator{configs: map[string]BinaryConfig{}, ecashID: "drynet3"}
	o.UpdateConfigs([]BinaryConfig{ecashVariantConfig()})

	if got := o.configs["bitcoind"].Variants["ecash"].Subfolder; got != "drynet3" {
		t.Errorf("subfolder after UpdateConfigs = %q, want drynet3", got)
	}
}
