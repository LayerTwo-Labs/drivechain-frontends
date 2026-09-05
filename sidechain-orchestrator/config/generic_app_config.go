package config

import (
	"fmt"
	"strings"
)

// GenericAppConfig is a simple key-value config for sidechain apps.
type GenericAppConfig struct {
	Settings map[string]string
}

func NewGenericAppConfig() *GenericAppConfig {
	return &GenericAppConfig{Settings: make(map[string]string)}
}

func ParseGenericAppConfig(content string) *GenericAppConfig {
	c := NewGenericAppConfig()
	for _, line := range strings.Split(content, "\n") {
		trimmed := strings.TrimSpace(line)
		if trimmed == "" || strings.HasPrefix(trimmed, "#") {
			continue
		}
		if eqIdx := strings.Index(trimmed, "="); eqIdx > 0 {
			key := strings.TrimSpace(trimmed[:eqIdx])
			value := strings.TrimSpace(trimmed[eqIdx+1:])
			c.Settings[key] = value
		}
	}
	return c
}

func (c *GenericAppConfig) Serialize() string {
	var b strings.Builder
	for key, value := range c.Settings {
		fmt.Fprintf(&b, "%s=%s\n", key, value)
	}
	return b.String()
}

func (c *GenericAppConfig) GetSetting(key string) string {
	return c.Settings[key]
}

func (c *GenericAppConfig) SetSetting(key, value string) {
	c.Settings[key] = value
}

func (c *GenericAppConfig) RemoveSetting(key string) {
	delete(c.Settings, key)
}
