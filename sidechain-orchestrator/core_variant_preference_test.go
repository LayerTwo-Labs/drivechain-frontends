package orchestrator

import (
	"sort"
	"testing"
)

// TestPreferenceLess_KnotsAlwaysLast is the explicit regression guard: the
// fallback variant comparator was plain alphabetical ("knots" < "core"),
// which silently shipped users a bitcoinknots.org binary on signet whenever
// the persisted variant didn't apply. Knots must always sort last so the
// fallback prefers the drivechain-aware patched build.
func TestPreferenceLess_KnotsAlwaysLast(t *testing.T) {
	cases := []struct {
		input []string
		want  []string
	}{
		{
			input: []string{"knots", "core", "patched"},
			want:  []string{"patched", "core", "knots"},
		},
		{
			input: []string{"knots", "core"},
			want:  []string{"core", "knots"},
		},
		{
			input: []string{"knots", "patched"},
			want:  []string{"patched", "knots"},
		},
		{
			input: []string{"knots"},
			want:  []string{"knots"},
		},
		{
			input: []string{"patched", "core"},
			want:  []string{"patched", "core"},
		},
	}

	for _, tc := range cases {
		got := append([]string(nil), tc.input...)
		sort.Slice(got, func(i, j int) bool { return preferenceLess(got[i], got[j]) })
		for i := range got {
			if got[i] != tc.want[i] {
				t.Errorf("sort(%v) = %v, want %v", tc.input, got, tc.want)
				break
			}
		}
	}
}

// TestEmbeddedConfig_SignetFallbackPicksPatched closes the loop end-to-end:
// parse the embedded chains_config.json, filter Bitcoin Core variants for
// signet, sort with the preference rule, and assert the result is the
// drivechain-patched variant — not knots. If a future config edit drops
// the patched variant or removes signet from its available_networks, this
// fails loud instead of silently bringing back the knots-default bug.
func TestEmbeddedConfig_SignetFallbackPicksPatched(t *testing.T) {
	configs, err := parseConfigJSON(embeddedConfig)
	if err != nil {
		t.Fatalf("parse embedded: %v", err)
	}

	var core *BinaryConfig
	for i := range configs {
		if configs[i].IsBitcoinCore {
			core = &configs[i]
			break
		}
	}
	if core == nil {
		t.Fatal("no Bitcoin Core binary in embedded config")
	}

	available := FilterVariantsForNetwork(core.Variants, "signet")
	if len(available) == 0 {
		t.Fatal("no variants available on signet")
	}
	sort.Slice(available, func(i, j int) bool {
		return preferenceLess(available[i].ID, available[j].ID)
	})

	ids := make([]string, len(available))
	for i, v := range available {
		ids[i] = v.ID
	}

	if available[0].ID == "knots" {
		t.Fatalf("signet fallback picked knots; want core/patched first. order=%v", ids)
	}
	if available[0].ID != "patched" {
		t.Errorf("signet fallback picked %q, want %q. order=%v", available[0].ID, "patched", ids)
	}
	if last := available[len(available)-1]; last.ID != "knots" {
		t.Errorf("knots not last: %v", ids)
	}
}

// TestPreferenceLess_StrictWeakOrdering — sort.Slice requires a strict weak
// ordering. Catch transitivity / antisymmetry violations early.
func TestPreferenceLess_StrictWeakOrdering(t *testing.T) {
	ids := []string{"knots", "core", "patched"}
	for _, a := range ids {
		if preferenceLess(a, a) {
			t.Errorf("preferenceLess(%q, %q) = true, must be false (irreflexive)", a, a)
		}
		for _, b := range ids {
			if a == b {
				continue
			}
			ab := preferenceLess(a, b)
			ba := preferenceLess(b, a)
			if ab && ba {
				t.Errorf("preferenceLess(%q, %q) and preferenceLess(%q, %q) both true (asymmetry violated)", a, b, b, a)
			}
		}
	}
}
