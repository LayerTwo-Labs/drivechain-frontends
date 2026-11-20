package config

import (
	"fmt"
	"net/url"
	"sync"
)

// RegtestEndpoints are the self-hosted servers that a regtest install reads in
// light mode. No public server exists for regtest.
type RegtestEndpoints struct {
	// EsploraURL is the Esplora REST API of the regtest chain.
	EsploraURL string
	// EnforcerURL is the gRPC URL of the regtest enforcer.
	EnforcerURL string
}

var (
	regtestMu        sync.RWMutex
	regtestEndpoints RegtestEndpoints
)

// SetRegtestEndpoints records the self-hosted regtest servers. An empty URL
// clears that server.
func SetRegtestEndpoints(e RegtestEndpoints) error {
	if err := checkServerURL(e.EsploraURL); err != nil {
		return fmt.Errorf("regtest Esplora URL: %w", err)
	}
	if err := checkServerURL(e.EnforcerURL); err != nil {
		return fmt.Errorf("regtest enforcer URL: %w", err)
	}
	regtestMu.Lock()
	defer regtestMu.Unlock()
	regtestEndpoints = e
	return nil
}

// CurrentRegtestEndpoints returns the self-hosted regtest servers.
func CurrentRegtestEndpoints() RegtestEndpoints {
	regtestMu.RLock()
	defer regtestMu.RUnlock()
	return regtestEndpoints
}

func checkServerURL(raw string) error {
	if raw == "" {
		return nil
	}
	u, err := url.Parse(raw)
	if err != nil {
		return fmt.Errorf("parse %q: %w", raw, err)
	}
	if (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" || u.User != nil {
		return fmt.Errorf("%q is not an http or https server URL", raw)
	}
	return nil
}
