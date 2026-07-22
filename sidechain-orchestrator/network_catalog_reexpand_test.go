package orchestrator

import "testing"

// Expansion is not reversible, so a second generation has to be applied to the
// pristine config. Expanding the already-expanded copy would pin the first
// generation forever.
func TestAdoptCatalogReExpandsFromRawConfig(t *testing.T) {
	raw := drynetVariantConfig()
	o := &Orchestrator{
		configs:    map[string]BinaryConfig{raw.Name: raw},
		rawConfigs: map[string]BinaryConfig{raw.Name: raw},
	}

	o.UpdateConfigs([]BinaryConfig{raw})
	o.drynetID = "drynet2"
	o.configs[raw.Name] = expandDrynetPlaceholder(o.rawConfigs[raw.Name], "drynet2")
	if got := o.configs[raw.Name].Variants["drynet"].Subfolder; got != "drynet2" {
		t.Fatalf("first expansion = %q, want drynet2", got)
	}

	// Now the catalog moves on.
	o.mu.Lock()
	for name, pristine := range o.rawConfigs {
		o.configs[name] = expandDrynetPlaceholder(pristine, "drynet3")
	}
	o.mu.Unlock()

	if got := o.configs[raw.Name].Variants["drynet"].Subfolder; got != "drynet3" {
		t.Errorf("subfolder after re-expansion = %q, want drynet3", got)
	}
	want := "L1-ecash-bitcoin-drynet3-x86_64-unknown-linux-gnu.zip"
	if got := o.configs[raw.Name].Variants["drynet"].Files["linux-x86_64"]; got != want {
		t.Errorf("filename after re-expansion = %q, want %q", got, want)
	}
}
