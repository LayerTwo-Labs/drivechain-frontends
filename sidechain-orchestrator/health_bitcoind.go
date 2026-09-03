package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"time"
)

// PresyncMessagePrefix is the prefix used in the synthesized startup error
// when bitcoind is in the BIP324 headers-presync phase. The connection
// monitor's startup-pattern list includes this prefix so the message is
// classified as startupError rather than connectionError and the UI shows
// "Pre-synchronizing blockheaders" instead of a frozen 0/0 connected state.
const PresyncMessagePrefix = "Pre-synchronizing blockheaders"

// BitcoindHealthCheck calls getblockchaininfo through the shared
// orchestrator → bitcoind RPC gate. When bitcoind is still in BIP324
// headers-presync the RPC reports blocks=0/headers=0 cleanly; a vanilla
// success signal would freeze the UI at 0/0, so the checker synthesises
// a presync startup error in that one case. One RPC only.
type BitcoindHealthCheck struct {
	URL         string
	User        string
	Password    string
	Credentials CredentialsFunc
	Timeout     time.Duration
}

func (h *BitcoindHealthCheck) Check(ctx context.Context) error {
	ctx, cancel := context.WithTimeout(ctx, h.Timeout)
	defer cancel()

	user, password, err := resolveCredentials(h.Credentials, h.User, h.Password)
	if err != nil {
		return fmt.Errorf("resolve credentials: %w", err)
	}

	raw, err := CallBitcoindRPC(ctx, h.URL, user, password, "getblockchaininfo", nil)
	if err != nil {
		return err
	}

	var info struct {
		Chain   string `json:"chain"`
		Blocks  int64  `json:"blocks"`
		Headers int64  `json:"headers"`
	}
	if err := json.Unmarshal(raw, &info); err != nil {
		return fmt.Errorf("decode getblockchaininfo: %w", err)
	}
	// BIP324 headers-presync only happens on networks where peers
	// exchange headers (mainnet, signet, testnet, ecash). Regtest has
	// no peers and never enters presync; a fresh regtest node sits at
	// blocks=0/headers=0 as steady state — and `initialblockdownload`
	// is no help here either, because Core sets IBD=true whenever the
	// tip's block time is older than 24h and regtest genesis dates to
	// 2011. So gate by chain instead.
	if info.Chain != "regtest" && info.Blocks == 0 && info.Headers == 0 {
		return fmt.Errorf("%s", PresyncMessagePrefix)
	}
	return nil
}
