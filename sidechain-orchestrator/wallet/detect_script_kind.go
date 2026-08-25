package wallet

import (
	"context"
	"strings"
)

// detectScriptKinds are the single-sig kinds a bare extended key could be,
// most common first.
var detectScriptKinds = []ScriptKind{ScriptNativeSegwit, ScriptNestedSegwit, ScriptLegacy, ScriptTaproot}

// detectScanDepth is how many addresses of each branch every kind is probed at.
// Each index costs one lookup per kind per branch, so the walk stays shallow.
const detectScanDepth = 6

// BareKeyWithoutKind reports whether s is a bare extended key that states no
// script kind: no script wrapper, no SLIP-0132 header, and no origin path with
// a standard BIP purpose.
func BareKeyWithoutKind(s string) bool {
	body, err := stripDescriptorChecksum(s)
	if err != nil {
		return false
	}
	body = strings.TrimSpace(body)
	if body == "" || strings.Contains(body, "(") {
		return false
	}
	key, _, hasKind, err := parseKeyExprKind(body)
	if err != nil || hasKind {
		return false
	}
	return originScriptKind(key.Origin, ScriptUnknown) == ScriptUnknown
}

// DetectScriptKind probes the chain under each single-sig script kind and
// returns the one kind that shows history. It walks index-major: every kind at
// index 0, then every kind at index 1. Both branches are probed, because a key
// whose only history sits on a change address is still a used key.
//
// It returns false unless exactly one kind carries history, and the caller then
// keeps the kind it already had. Two kinds carrying history place nothing — a
// dusted address under a second wrapper must not overrule a stated choice — and
// a lookup that fails leaves the walk incomplete rather than proving the key
// was never used. Both cases reach the log.
func (p *ElectrumBackend) DetectScriptKind(ctx context.Context, xpubOrDescriptor string) (ScriptKind, bool) {
	net := p.params()
	if net == nil || p.client == nil {
		return ScriptUnknown, false
	}

	descs := make(map[ScriptKind]*Descriptor, len(detectScriptKinds))
	for _, kind := range detectScriptKinds {
		d, err := ParseDescriptorAs(xpubOrDescriptor, kind)
		if err != nil || d.Kind != kind {
			continue
		}
		descs[kind] = d
	}

	var unread int
	used := make(map[ScriptKind]bool, len(detectScriptKinds))
	for i := 0; i < detectScanDepth; i++ {
		for _, kind := range detectScriptKinds {
			d, ok := descs[kind]
			if !ok || used[kind] {
				continue
			}
			if err := ctx.Err(); err != nil {
				return ScriptUnknown, false
			}
			for _, change := range []bool{false, true} {
				ds, _, err := d.DeriveScript(change, uint32(i), net)
				if err != nil {
					continue
				}
				stats, err := p.client.AddressStats(ctx, ds.address.EncodeAddress())
				if err != nil {
					unread++
					continue
				}
				if !stats.Used() {
					continue
				}
				used[kind] = true
				if len(used) > 1 {
					p.log.Warn().
						Msg("watch-only import kept its chosen script type; more than one kind carries history")
					return ScriptUnknown, false
				}
				break
			}
		}
	}
	if unread > 0 {
		p.log.Warn().
			Int("unread", unread).
			Msg("watch-only import kept its chosen script type; some address lookups failed")
	}
	if len(used) != 1 {
		return ScriptUnknown, false
	}
	for kind := range used {
		p.log.Info().
			Str("script_type", kind.String()).
			Msg("watch-only import placed by its on-chain history")
		return kind, true
	}
	return ScriptUnknown, false
}
