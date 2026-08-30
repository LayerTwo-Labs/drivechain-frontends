package config

import (
	"fmt"
	"path/filepath"
	"strconv"
	"strings"
)

const bitcoinConfVersionCommentPrefix = "# bitwindow-bitcoin-conf-version="

// datadirSlotCommentPrefix is the special comment our serializer reads/writes
// to remember the inactive datadir-group's path. Format on disk:
//
//	# bitwindow-datadir-default=/path/for/default/group
//	# bitwindow-datadir-forknet=/path/for/forknet
//	# bitwindow-datadir-ecash=/path/for/ecash
//
// bitcoind ignores comment lines, so these are invisible to it but
// authoritative for the orchestrator on the next group swap.
const datadirSlotCommentPrefix = "# bitwindow-datadir-"

// multiValuedKeys are the options Bitcoin Core reads every occurrence of, so a
// section may legitimately carry several lines for them.
var multiValuedKeys = map[string]bool{
	"addnode":     true,
	"bind":        true,
	"connect":     true,
	"externalip":  true,
	"includeconf": true,
	"loadblock":   true,
	"onlynet":     true,
	"rpcallowip":  true,
	"rpcauth":     true,
	"rpcbind":     true,
	"seednode":    true,
	"wallet":      true,
	"whitebind":   true,
	"whitelist":   true,
}

// BitcoinConfig represents a parsed Bitcoin Core configuration file.
//
// Order matters: the conf editor and the user expect the on-disk order to be
// preserved across read/write round-trips. Go maps don't preserve insertion
// order, so we keep a parallel `*Order` slice for each settings map and walk
// it in Serialize.
type BitcoinConfig struct {
	GlobalSettings  map[string]string
	GlobalOrder     []string
	NetworkSettings map[string]map[string]string // "main", "test", "signet", "regtest"
	NetworkOrder    map[string][]string
	// GlobalMulti/NetworkMulti hold every value of a multiValuedKeys key, in
	// the order it was set. The settings maps above keep the first one.
	GlobalMulti   map[string][]string
	NetworkMulti  map[string]map[string][]string
	ConfigVersion int
	// DatadirSlots holds the per-group datadir snapshots read from / written
	// to # bitwindow-datadir-<group>= comment lines. Keyed by DatadirGroup
	// value ("default", "forknet"). Empty string = unset/cleared.
	DatadirSlots map[DatadirGroup]string
}

func NewBitcoinConfig() *BitcoinConfig {
	return &BitcoinConfig{
		GlobalSettings: make(map[string]string),
		GlobalOrder:    nil,
		NetworkSettings: map[string]map[string]string{
			"main":    {},
			"test":    {},
			"signet":  {},
			"regtest": {},
		},
		NetworkOrder: map[string][]string{
			"main":    nil,
			"test":    nil,
			"signet":  nil,
			"regtest": nil,
		},
		GlobalMulti: make(map[string][]string),
		NetworkMulti: map[string]map[string][]string{
			"main":    {},
			"test":    {},
			"signet":  {},
			"regtest": {},
		},
		ConfigVersion: 0,
		DatadirSlots:  map[DatadirGroup]string{},
	}
}

// ParseBitcoinConfig parses bitcoin.conf content into a BitcoinConfig.
func ParseBitcoinConfig(content string) *BitcoinConfig {
	config := NewBitcoinConfig()
	var currentSection string

	lines := strings.Split(content, "\n")
	for _, line := range lines {
		trimmed := strings.TrimSpace(line)

		// Parse version comment for migration system
		if strings.HasPrefix(trimmed, bitcoinConfVersionCommentPrefix) {
			vStr := strings.TrimSpace(trimmed[len(bitcoinConfVersionCommentPrefix):])
			if v, err := strconv.Atoi(vStr); err == nil && v >= 0 {
				config.ConfigVersion = v
			}
			continue
		}

		// Parse datadir-group slot comments: # bitwindow-datadir-<group>=<path>
		if strings.HasPrefix(trimmed, datadirSlotCommentPrefix) {
			rest := trimmed[len(datadirSlotCommentPrefix):]
			if eq := strings.Index(rest, "="); eq > 0 {
				group := DatadirGroup(strings.TrimSpace(rest[:eq]))
				// The eCash slot went out as "drynet". It is read, never
				// written: dropping it makes an upgraded install ask for a
				// directory it already holds a chain in.
				if group == legacyECashDatadirGroup {
					group = DatadirGroupECash
				}
				path := strings.TrimSpace(rest[eq+1:])
				if group == DatadirGroupDefault || group == DatadirGroupForknet || group == DatadirGroupECash {
					config.DatadirSlots[group] = path
				}
			}
			continue
		}

		// Skip empty lines and other comments
		if trimmed == "" || strings.HasPrefix(trimmed, "#") {
			continue
		}

		// Check for section header
		if strings.HasPrefix(trimmed, "[") && strings.HasSuffix(trimmed, "]") {
			section := trimmed[1 : len(trimmed)-1]
			if _, ok := config.NetworkSettings[section]; ok {
				currentSection = section
			}
			continue
		}

		// Parse key=value pairs
		eqIdx := strings.Index(trimmed, "=")
		if eqIdx > 0 {
			key := strings.TrimSpace(trimmed[:eqIdx])
			value := strings.TrimSpace(trimmed[eqIdx+1:])
			// Strip inline `# comment` so values like `chain=main # current
			// network` round-trip as just `main`.
			if hashIdx := strings.Index(value, "#"); hashIdx >= 0 {
				value = strings.TrimSpace(value[:hashIdx])
			}
			config.SetSetting(key, value, currentSection)
		}
	}

	return config
}

// Serialize writes the config back to file format, preserving the order in
// which keys were inserted (i.e. the order they appeared on disk for parsed
// configs, or insertion order for programmatically built configs).
func (c *BitcoinConfig) Serialize() string {
	var b strings.Builder

	if c.ConfigVersion > 0 {
		fmt.Fprintf(&b, "%s%d\n\n", bitcoinConfVersionCommentPrefix, c.ConfigVersion)
	}

	b.WriteString("# Generated by BitWindow Bitcoin Configuration Editor\n")
	b.WriteString("# Feel free to edit this file, changes will be applied.\n\n")

	// Emit datadir-group slot comments in a stable order so round-trips are
	// byte-stable. Always emit both groups when either has a value, to keep
	// hand-editing predictable.
	if len(c.DatadirSlots) > 0 {
		groupOrder := []DatadirGroup{DatadirGroupDefault, DatadirGroupForknet, DatadirGroupECash}
		anyEmitted := false
		for _, g := range groupOrder {
			if v, ok := c.DatadirSlots[g]; ok && v != "" {
				fmt.Fprintf(&b, "%s%s=%s\n", datadirSlotCommentPrefix, g, v)
				anyEmitted = true
			}
		}
		if anyEmitted {
			b.WriteString("\n")
		}
	}

	// Write global settings
	if len(c.GlobalSettings) > 0 {
		b.WriteString("# [common settings]\n")
		for _, key := range c.orderedKeys("") {
			for _, value := range c.values(key, "") {
				fmt.Fprintf(&b, "%s=%s\n", key, value)
			}
		}
		b.WriteString("\n")
	}

	// Write network-specific settings
	sectionNames := map[string]string{
		"main":    "[main]",
		"test":    "[test]",
		"signet":  "[signet]",
		"regtest": "[regtest]",
	}
	sectionOrder := []string{"main", "test", "signet", "regtest"}

	for _, network := range sectionOrder {
		settings := c.NetworkSettings[network]
		if len(settings) > 0 {
			label := network
			if network == "main" {
				label = "mainnet"
			}
			fmt.Fprintf(&b, "# Options for %s only\n", label)
			fmt.Fprintf(&b, "%s\n", sectionNames[network])
			for _, key := range c.orderedKeys(network) {
				for _, value := range c.values(key, network) {
					fmt.Fprintf(&b, "%s=%s\n", key, value)
				}
			}
			b.WriteString("\n")
		}
	}

	return b.String()
}

// orderedKeys returns keys for a section (or globals if section == ""), using
// the tracked insertion order. Any keys present in the map but missing from
// the order list (defensive: e.g. a caller wrote directly to the map) are
// appended in map-iteration order at the end.
func (c *BitcoinConfig) orderedKeys(section string) []string {
	var order []string
	var settings map[string]string
	if section == "" {
		order = c.GlobalOrder
		settings = c.GlobalSettings
	} else {
		order = c.NetworkOrder[section]
		settings = c.NetworkSettings[section]
	}

	seen := make(map[string]struct{}, len(order))
	out := make([]string, 0, len(settings))
	for _, k := range order {
		if _, ok := settings[k]; ok {
			out = append(out, k)
			seen[k] = struct{}{}
		}
	}
	for k := range settings {
		if _, ok := seen[k]; !ok {
			out = append(out, k)
		}
	}
	return out
}

// values returns every value stored for a key in a section (globals if
// section == ""), in the order it was set. Single-valued keys yield one.
func (c *BitcoinConfig) values(key, section string) []string {
	if section != "" {
		if vs := c.NetworkMulti[section][key]; len(vs) > 0 {
			return vs
		}
		if v, ok := c.NetworkSettings[section][key]; ok {
			return []string{v}
		}
		return nil
	}
	if vs := c.GlobalMulti[key]; len(vs) > 0 {
		return vs
	}
	if v, ok := c.GlobalSettings[key]; ok {
		return []string{v}
	}
	return nil
}

func (c *BitcoinConfig) GetSetting(key string, section ...string) string {
	if len(section) > 0 && section[0] != "" {
		if s, ok := c.NetworkSettings[section[0]]; ok {
			return s[key]
		}
		return ""
	}
	return c.GlobalSettings[key]
}

// GetEffectiveSetting returns the effective setting for a network (section overrides global).
func (c *BitcoinConfig) GetEffectiveSetting(key, network string) string {
	if s, ok := c.NetworkSettings[network]; ok {
		if v, exists := s[key]; exists {
			return v
		}
	}
	return c.GlobalSettings[key]
}

// GetSettings returns every value stored for a key, in order. A multi-valued
// key (see multiValuedKeys) may hold more than one.
func (c *BitcoinConfig) GetSettings(key string, section ...string) []string {
	if len(section) > 0 {
		return c.values(key, section[0])
	}
	return c.values(key, "")
}

// SetSetting sets a key's value. A multi-valued key keeps the values already
// set and appends this one, so a rewrite never drops a peer the user added;
// use ReplaceSetting to collapse such a key to a single value.
func (c *BitcoinConfig) SetSetting(key, value string, section ...string) {
	if len(section) > 0 && section[0] != "" {
		s := section[0]
		if _, ok := c.NetworkSettings[s]; !ok {
			c.NetworkSettings[s] = make(map[string]string)
		}
		if _, exists := c.NetworkSettings[s][key]; !exists {
			c.NetworkOrder[s] = append(c.NetworkOrder[s], key)
			c.NetworkSettings[s][key] = value
		} else if !multiValuedKeys[key] {
			c.NetworkSettings[s][key] = value
		}
	} else {
		if _, exists := c.GlobalSettings[key]; !exists {
			c.GlobalOrder = append(c.GlobalOrder, key)
			c.GlobalSettings[key] = value
		} else if !multiValuedKeys[key] {
			c.GlobalSettings[key] = value
		}
	}
	if multiValuedKeys[key] {
		c.appendValue(key, value, section...)
	}
}

// ReplaceSetting sets a key to exactly this value, dropping any other values a
// multi-valued key holds. Its position in the section is preserved.
func (c *BitcoinConfig) ReplaceSetting(key, value string, section ...string) {
	c.SetSetting(key, value, section...)
	if !multiValuedKeys[key] {
		return
	}
	if len(section) > 0 && section[0] != "" {
		s := section[0]
		c.NetworkSettings[s][key] = value
		c.NetworkMulti[s][key] = []string{value}
		return
	}
	c.GlobalSettings[key] = value
	c.GlobalMulti[key] = []string{value}
}

// appendValue records value in the key's value list, ignoring a duplicate.
func (c *BitcoinConfig) appendValue(key, value string, section ...string) {
	multi := c.GlobalMulti
	if len(section) > 0 && section[0] != "" {
		s := section[0]
		if c.NetworkMulti == nil {
			c.NetworkMulti = make(map[string]map[string][]string)
		}
		if _, ok := c.NetworkMulti[s]; !ok {
			c.NetworkMulti[s] = make(map[string][]string)
		}
		multi = c.NetworkMulti[s]
	} else if multi == nil {
		multi = make(map[string][]string)
		c.GlobalMulti = multi
	}
	for _, v := range multi[key] {
		if v == value {
			return
		}
	}
	multi[key] = append(multi[key], value)
}

func (c *BitcoinConfig) RemoveSetting(key string, section ...string) {
	if len(section) > 0 && section[0] != "" {
		s := section[0]
		if settings, ok := c.NetworkSettings[s]; ok {
			delete(settings, key)
			delete(c.NetworkMulti[s], key)
			c.NetworkOrder[s] = removeFromOrder(c.NetworkOrder[s], key)
		}
	} else {
		delete(c.GlobalSettings, key)
		delete(c.GlobalMulti, key)
		c.GlobalOrder = removeFromOrder(c.GlobalOrder, key)
	}
}

func (c *BitcoinConfig) HasSetting(key string, section ...string) bool {
	if len(section) > 0 && section[0] != "" {
		if s, ok := c.NetworkSettings[section[0]]; ok {
			_, exists := s[key]
			return exists
		}
		return false
	}
	_, exists := c.GlobalSettings[key]
	return exists
}

// GetGroupDatadir returns the recorded datadir for a group, or "" if unset.
func (c *BitcoinConfig) GetGroupDatadir(g DatadirGroup) string {
	if c.DatadirSlots == nil {
		return ""
	}
	return c.DatadirSlots[g]
}

// SetGroupDatadir records the datadir for a group. Empty path clears the slot.
func (c *BitcoinConfig) SetGroupDatadir(g DatadirGroup, path string) {
	if c.DatadirSlots == nil {
		c.DatadirSlots = map[DatadirGroup]string{}
	}
	if path == "" {
		delete(c.DatadirSlots, g)
		return
	}
	c.DatadirSlots[g] = path
}

// GroupDatadirForPick returns the datadir a group should use for a directory
// the user just chose. Non-default groups run on chain=main and would share
// mainnet's datadir root. Apply once, at the pick — slots on disk are already
// resolved and re-applying would redirect a live datadir.
func GroupDatadirForPick(g DatadirGroup, picked string) string {
	if g == DatadirGroupDefault || picked == "" {
		return picked
	}
	return filepath.Join(filepath.Clean(picked), string(g))
}

func removeFromOrder(order []string, key string) []string {
	for i, k := range order {
		if k == key {
			return append(order[:i], order[i+1:]...)
		}
	}
	return order
}
