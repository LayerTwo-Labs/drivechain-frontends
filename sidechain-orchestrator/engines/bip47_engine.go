// Package engines hosts long-running background workers driven by the
// orchestrator. Engines hold no critical state of their own — they observe
// chain/wallet state, mutate persisted stores, and drive Core RPC.
package engines

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47state"
)

const (
	bip47TickInterval    = 10 * time.Second
	bip47ListTxBatchSize = 100
	// bip47GapLimit is the forward window of per-payment addresses imported
	// into Core for each known sender, per extension.
	bip47GapLimit = 20
	// bip47TrailingBuffer is how many unused trailing addresses we keep ahead
	// of the most recently used per-payment address before extending the
	// imported window further. BIP44-style gap-limit semantics: we only grow
	// when usage approaches the tail. The probe is the address at index
	// (ImportedThroughIndex - bip47TrailingBuffer); if Core says it has
	// received coins, we extend, otherwise we wait.
	bip47TrailingBuffer = 3
)

// BIP47Engine watches Bitcoin Core wallets for incoming BIP47 notification
// transactions. When one is found it decodes the OP_RETURN payload to recover
// the sender's payment code, derives a window of per-payment receive addresses
// for that sender via ECDH, and imports those addresses as descriptors into
// the wallet's Core wallet so future payments are spendable.
//
// Send side is wired in api/bip47_send.go and is unaffected by this engine.
type BIP47Engine struct {
	log     zerolog.Logger
	svc     *wallet.Service
	engine  *wallet.WalletEngine
	inbound *bip47state.InboundStore
}

func NewBIP47Engine(log zerolog.Logger, svc *wallet.Service, walletEngine *wallet.WalletEngine, inbound *bip47state.InboundStore) *BIP47Engine {
	return &BIP47Engine{
		log:     log.With().Str("component", "bip47").Logger(),
		svc:     svc,
		engine:  walletEngine,
		inbound: inbound,
	}
}

// Run loops until ctx is cancelled. Errors from a single tick are logged and
// the loop continues — a transient Core RPC failure shouldn't stop the engine.
func (e *BIP47Engine) Run(ctx context.Context) error {
	ticker := time.NewTicker(bip47TickInterval)
	defer ticker.Stop()
	e.log.Info().Dur("interval", bip47TickInterval).Msg("bip47 engine started")
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			e.tick(ctx)
		}
	}
}

func (e *BIP47Engine) tick(ctx context.Context) {
	net := e.engine.Network()
	if net == nil {
		// BIP47 isn't supported on this network.
		return
	}
	wallets := e.svc.GetAllWallets()
	for i := range wallets {
		w := &wallets[i]
		if w.WalletType != "bitcoinCore" {
			continue
		}
		seedHex := w.Master.SeedHex
		if seedHex == "" {
			continue
		}
		if _, err := e.engine.Provider().Ensure(ctx, w.ID); err != nil {
			// Wallet may still be warming up on the backend; retry next tick.
			continue
		}
		if err := e.scanWallet(ctx, w.ID, seedHex, net); err != nil {
			e.log.Warn().Err(err).Str("wallet", w.ID).Msg("scan failed")
		}
		if err := e.extendImports(ctx, w.ID, seedHex, net); err != nil {
			e.log.Warn().Err(err).Str("wallet", w.ID).Msg("extend imports failed")
		}
	}
}

// scanWallet walks listtransactions forward from the persisted cursor looking
// for receives at this wallet's BIP47 notification address. For each one, it
// fetches the full tx, extracts the OP_RETURN payload + first input's pubkey,
// decodes the sender's payment code, and records the inbound notification.
func (e *BIP47Engine) scanWallet(ctx context.Context, walletID, seedHex string, net *chaincfg.Params) error {
	notifPriv, notifAddr, err := bip47.DeriveOwnNotificationKey(seedHex, net)
	if err != nil {
		return fmt.Errorf("derive own notification key: %w", err)
	}
	wantAddr := notifAddr.EncodeAddress()

	cursor, err := e.inbound.ScanCursor(walletID)
	if err != nil {
		return fmt.Errorf("read scan cursor: %w", err)
	}

	for {
		batch, err := e.engine.Provider().ListTransactionsRange(ctx, walletID, bip47ListTxBatchSize, cursor)
		if err != nil {
			return fmt.Errorf("listtransactions: %w", err)
		}
		if len(batch) == 0 {
			break
		}
		for _, tx := range batch {
			if tx.Category != "receive" || tx.Address != wantAddr {
				continue
			}
			senderCode, blockTime, err := e.decodeNotificationTx(ctx, tx.TxID, notifPriv)
			if err != nil {
				e.log.Debug().Err(err).Str("txid", tx.TxID).Msg("skip non-bip47 receive at notification address")
				continue
			}
			height := int32(0)
			if tx.Confirmations > 0 {
				// listtransactions doesn't include height directly; leave as 0.
				// Block time below is enough to time-bound the per-payment
				// descriptor rescan; height is only used as a "confirmed" marker.
				height = 1
			}
			if err := e.inbound.RecordInbound(walletID, senderCode, tx.TxID, height, blockTime); err != nil {
				e.log.Warn().Err(err).Str("txid", tx.TxID).Msg("record inbound failed")
				continue
			}
			e.log.Info().
				Str("wallet", walletID).
				Str("sender", senderCode).
				Str("txid", tx.TxID).
				Msg("recorded inbound bip47 notification")
		}
		cursor += len(batch)
		if err := e.inbound.SetScanCursor(walletID, cursor); err != nil {
			return fmt.Errorf("save scan cursor: %w", err)
		}
		if len(batch) < bip47ListTxBatchSize {
			break
		}
	}
	return nil
}

// decodeNotificationTx fetches the full notification transaction, finds its
// OP_RETURN payload and the first input's pubkey + outpoint, and decodes the
// blinded payload using the receiver's notification privkey. Returns the
// sender's payment code base58 and the block time (0 if unconfirmed).
func (e *BIP47Engine) decodeNotificationTx(ctx context.Context, txid string, notifPriv *btcec.PrivateKey) (string, int64, error) {
	raw, err := e.engine.Provider().Chain().GetRawTransaction(ctx, txid)
	if err != nil {
		return "", 0, fmt.Errorf("getrawtransaction: %w", err)
	}
	if len(raw.Vin) == 0 {
		return "", 0, errors.New("notification tx has no inputs")
	}
	// BIP47: the designated input is the first input exposing a recoverable
	// secp256k1 pubkey. Walk vin until one yields a pubkey + parseable
	// outpoint; tolerate inputs we can't crack (multisig/P2SH with no plain
	// pubkey, coinbase, etc.).
	var senderPub *btcec.PublicKey
	var outpoint wire.OutPoint
	for _, in := range raw.Vin {
		if in.Coinbase != "" {
			continue
		}
		pub, err := extractInputPubKey(in.Witness, in.ScriptSig)
		if err != nil {
			continue
		}
		prevHash, err := chainhash.NewHashFromStr(in.TxID)
		if err != nil {
			continue
		}
		senderPub = pub
		outpoint = wire.OutPoint{Hash: *prevHash, Index: uint32(in.Vout)}
		break
	}
	if senderPub == nil {
		return "", 0, errors.New("no designated input with recoverable pubkey")
	}

	var payload []byte
	for _, out := range raw.Vout {
		if out.ScriptPubKey.Type != "nulldata" {
			continue
		}
		scriptBytes, err := hex.DecodeString(out.ScriptPubKey.Hex)
		if err != nil {
			continue
		}
		data, err := parseOpReturnPayload(scriptBytes)
		if err != nil {
			continue
		}
		if len(data) == bip47.PaymentCodeLength {
			payload = data
			break
		}
	}
	if payload == nil {
		return "", 0, errors.New("no 80-byte OP_RETURN payload found")
	}

	var blinded [bip47.PaymentCodeLength]byte
	copy(blinded[:], payload)
	decoded, err := bip47.DecodeBlindedPayload(notifPriv, senderPub, outpoint, blinded)
	if err != nil {
		return "", 0, fmt.Errorf("decode blinded payload: %w", err)
	}
	return decoded.Base58(), raw.BlockTime, nil
}

// extendImports walks every known inbound sender for this wallet. For each
// one, it imports the first gapLimit per-payment addresses on the very first
// pass, and afterwards only extends the window further once the trailing
// probe address (see bip47TrailingBuffer) has received coins. Core ignores
// already-known descriptors.
func (e *BIP47Engine) extendImports(ctx context.Context, walletID, seedHex string, net *chaincfg.Params) error {
	inbound, err := e.inbound.ListByWallet(walletID)
	if err != nil {
		return err
	}
	if len(inbound) == 0 {
		return nil
	}
	received, err := e.engine.Provider().ListReceivedByAddress(ctx, walletID)
	if err != nil {
		return fmt.Errorf("listreceivedbyaddress: %w", err)
	}
	usedAddrs := make(map[string]bool, len(received))
	for _, r := range received {
		if r.Amount > 0 {
			usedAddrs[r.Address] = true
		}
	}
	for _, n := range inbound {
		if err := e.extendImportsForSender(ctx, walletID, seedHex, n, net, usedAddrs); err != nil {
			e.log.Warn().Err(err).Str("wallet", walletID).Str("sender", n.SenderPaymentCode).Msg("extend imports for sender failed")
		}
	}
	return nil
}

func (e *BIP47Engine) extendImportsForSender(ctx context.Context, walletID, seedHex string, n *bip47state.InboundNotification, net *chaincfg.Params, usedAddrs map[string]bool) error {
	sender, err := bip47.ParsePaymentCode(n.SenderPaymentCode)
	if err != nil {
		return fmt.Errorf("parse sender payment code: %w", err)
	}
	senderNotifPub, err := sender.NotificationPubKey()
	if err != nil {
		return fmt.Errorf("recover sender notification pubkey: %w", err)
	}

	// After the initial gapLimit bootstrap, only extend when the trailing
	// probe address (ImportedThroughIndex - bip47TrailingBuffer) has received
	// coins. Otherwise the window grows forever at every tick.
	if n.ImportedThroughIndex >= bip47TrailingBuffer {
		probeIdx := n.ImportedThroughIndex - bip47TrailingBuffer
		probeAddr, _, err := bip47.DeriveReceivedPaymentAddress(seedHex, senderNotifPub, probeIdx, net, bip47.AddressP2PKH)
		if err != nil {
			return fmt.Errorf("derive probe address at index %d: %w", probeIdx, err)
		}
		if !usedAddrs[probeAddr.EncodeAddress()] {
			return nil
		}
	}

	start := n.ImportedThroughIndex
	end := start + bip47GapLimit
	keys := make([]wallet.WatchKey, 0, end-start)
	for i := start; i < end; i++ {
		_, priv, err := bip47.DeriveReceivedPaymentAddress(seedHex, senderNotifPub, i, net, bip47.AddressP2PKH)
		if err != nil {
			// Shouldn't happen for non-pathological keys; log and skip.
			e.log.Warn().Err(err).Uint32("index", i).Msg("derive received payment address failed")
			continue
		}
		wif, err := btcutil.NewWIF(priv, net, true)
		if err != nil {
			return fmt.Errorf("encode wif index %d: %w", i, err)
		}
		// If we know the notification block time the provider only scans
		// forward from there (tight, fast); 0 requests a full rescan so the
		// eventual payment to an unconfirmed notification is picked up.
		keys = append(keys, wallet.WatchKey{
			WIF:        wif.String(),
			RescanFrom: n.FirstSeenBlockTime,
		})
	}
	if len(keys) == 0 {
		return nil
	}
	if err := e.engine.Provider().WatchKeys(ctx, walletID, keys); err != nil {
		return fmt.Errorf("watch keys: %w", err)
	}
	if err := e.inbound.BumpImportedIndex(walletID, n.SenderPaymentCode, end); err != nil {
		return fmt.Errorf("bump imported index: %w", err)
	}
	e.log.Info().
		Str("wallet", walletID).
		Str("sender", n.SenderPaymentCode).
		Uint32("from", start).
		Uint32("to", end).
		Msg("imported per-payment descriptors")
	return nil
}

// extractInputPubKey recovers the spending pubkey from a transaction input.
// For P2WPKH (segwit v0) the witness stack is [signature, pubkey] — return the
// last element. For P2PKH the scriptSig is "<sig> <pubkey>" pushed sequentially
// — return the last data push. Other input shapes (multisig, P2SH, taproot)
// are not valid BIP47 designated inputs per the spec and return an error.
func extractInputPubKey(witness []string, scriptSig *wallet.ScriptSig) (*btcec.PublicKey, error) {
	if len(witness) >= 2 {
		// Witness stack: signature, pubkey. P2WPKH.
		pubHex := witness[len(witness)-1]
		pubBytes, err := hex.DecodeString(pubHex)
		if err != nil {
			return nil, fmt.Errorf("decode witness pubkey hex: %w", err)
		}
		return btcec.ParsePubKey(pubBytes)
	}
	if scriptSig != nil && scriptSig.Hex != "" {
		scriptBytes, err := hex.DecodeString(scriptSig.Hex)
		if err != nil {
			return nil, fmt.Errorf("decode scriptSig hex: %w", err)
		}
		pushes, err := pushedDataItems(scriptBytes)
		if err != nil {
			return nil, fmt.Errorf("parse scriptSig pushes: %w", err)
		}
		if len(pushes) < 2 {
			return nil, errors.New("scriptSig has fewer than 2 pushes; not a P2PKH input")
		}
		return btcec.ParsePubKey(pushes[len(pushes)-1])
	}
	return nil, errors.New("input has neither witness nor scriptSig data")
}

// parseOpReturnPayload extracts the bytes pushed after a leading OP_RETURN
// opcode. Handles the direct (1..75), OP_PUSHDATA1 (0x4c) and OP_PUSHDATA2
// (0x4d) push variants. OP_PUSHDATA4 would never appear in practice for a
// standard 80-byte BIP47 payload — reject.
func parseOpReturnPayload(script []byte) ([]byte, error) {
	if len(script) < 2 || script[0] != 0x6a {
		return nil, errors.New("not OP_RETURN")
	}
	body := script[1:]
	if len(body) == 0 {
		return nil, errors.New("empty OP_RETURN body")
	}
	op := body[0]
	body = body[1:]
	var size int
	switch {
	case op >= 0x01 && op <= 0x4b:
		size = int(op)
	case op == 0x4c:
		if len(body) < 1 {
			return nil, errors.New("truncated OP_PUSHDATA1")
		}
		size = int(body[0])
		body = body[1:]
	case op == 0x4d:
		if len(body) < 2 {
			return nil, errors.New("truncated OP_PUSHDATA2")
		}
		size = int(body[0]) | int(body[1])<<8
		body = body[2:]
	default:
		return nil, fmt.Errorf("unsupported push opcode 0x%02x", op)
	}
	if len(body) < size {
		return nil, fmt.Errorf("OP_RETURN script truncated: want %d bytes, have %d", size, len(body))
	}
	return body[:size], nil
}

// pushedDataItems returns the data pushed by a Bitcoin script, walking each
// push opcode in order. Non-push opcodes are skipped. Returns an error on
// malformed scripts.
func pushedDataItems(script []byte) ([][]byte, error) {
	var out [][]byte
	i := 0
	for i < len(script) {
		op := script[i]
		i++
		var size int
		switch {
		case op >= 0x01 && op <= 0x4b:
			size = int(op)
		case op == 0x4c:
			if i >= len(script) {
				return nil, errors.New("truncated OP_PUSHDATA1")
			}
			size = int(script[i])
			i++
		case op == 0x4d:
			if i+2 > len(script) {
				return nil, errors.New("truncated OP_PUSHDATA2")
			}
			size = int(script[i]) | int(script[i+1])<<8
			i += 2
		default:
			// Non-push opcode (sig hashtypes appear inside the sig push, not
			// here at top level). Just skip.
			continue
		}
		if i+size > len(script) {
			return nil, errors.New("script truncated")
		}
		out = append(out, script[i:i+size])
		i += size
	}
	return out, nil
}
