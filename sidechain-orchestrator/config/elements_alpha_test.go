package config

import (
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestElementsAlphaNativeConfiguration(t *testing.T) {
	old := ECashNetworkID()
	SetECashNetworkID("alphanet")
	t.Cleanup(func() { SetECashNetworkID(old) })
	o := ElementsAlphaOptions{Network: NetworkECash, DataDir: t.TempDir(), ParentHost: "127.0.0.1", ParentPort: 18302, RPCPort: 7065, P2PPort: 7066, ParentCookie: filepath.Join(t.TempDir(), ".cookie")}
	text, err := o.Config()
	require.NoError(t, err)
	for _, line := range []string{"chain=elements", "daemon=0", "drivechainl1blocksync=0", "rpcbind=127.0.0.1", "mainchainrpccookiefile=" + o.ParentCookie} {
		require.Contains(t, strings.Split(text, "\n"), line)
	}
	require.NotContains(t, text, "rpcpassword")
	require.NotContains(t, text, "reward")
	require.Equal(t, filepath.Join(o.DataDir, "elements-v11", ".cookie"), o.CookiePath())
	for name, mutate := range map[string]func(*ElementsAlphaOptions){
		"wrong network":   func(v *ElementsAlphaOptions) { v.Network = NetworkSignet },
		"remote parent":   func(v *ElementsAlphaOptions) { v.ParentHost = "192.0.2.1" },
		"hostname":        func(v *ElementsAlphaOptions) { v.ParentHost = "localhost" },
		"relative cookie": func(v *ElementsAlphaOptions) { v.ParentCookie = ".cookie" },
		"injection":       func(v *ElementsAlphaOptions) { v.ParentCookie += "\ndrivechainl1blocksync=1" },
		"port collision":  func(v *ElementsAlphaOptions) { v.RPCPort = v.ParentPort },
		"invalid port":    func(v *ElementsAlphaOptions) { v.P2PPort = 65536 },
	} {
		t.Run(name, func(t *testing.T) { v := o; mutate(&v); _, err := v.Config(); require.Error(t, err) })
	}
	SetECashNetworkID("another-alpha")
	_, err = o.Config()
	require.Error(t, err)
}
