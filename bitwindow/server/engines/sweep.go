package engines

import (
	"context"
	"fmt"
	"time"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

// SweepAddressKind is the script kind of an address a private key controls.
type SweepAddressKind int

const (
	SweepAddressUnknown SweepAddressKind = iota
	SweepAddressP2WPKH
	SweepAddressP2PKH
)

func (k SweepAddressKind) String() string {
	switch k {
	case SweepAddressP2WPKH:
		return "p2wpkh"
	case SweepAddressP2PKH:
		return "p2pkh"
	case SweepAddressUnknown:
		return "unknown"
	default:
		return "unknown"
	}
}

const (
	p2wpkhInputVbytes   = 68
	p2pkhInputVbytes    = 148
	sweepOutputVbytes   = 31
	sweepOverheadVbytes = 11
)

// SweepCandidate is one address a private key can spend from.
type SweepCandidate struct {
	Address string
	Kind    SweepAddressKind
}

// SweepSource is the address a sweep spends from, and what it holds.
type SweepSource struct {
	Address string
	Kind    SweepAddressKind
	UTXOs   []ChequeUTXO
}

// TotalSats is the value of every output the source holds.
func (s SweepSource) TotalSats() uint64 {
	var total uint64
	for _, utxo := range s.UTXOs {
		total += uint64(utxo.ValueSats)
	}
	return total
}

// SweepCandidates derives every address a private key controls, best first.
// A key that encodes an uncompressed public key has no segwit address.
func SweepCandidates(wif *btcutil.WIF, params *chaincfg.Params) ([]SweepCandidate, error) {
	pubKey := wif.PrivKey.PubKey()

	serialized := pubKey.SerializeUncompressed()
	if wif.CompressPubKey {
		serialized = pubKey.SerializeCompressed()
	}

	candidates := make([]SweepCandidate, 0, 2)

	if wif.CompressPubKey {
		witness, err := btcutil.NewAddressWitnessPubKeyHash(btcutil.Hash160(serialized), params)
		if err != nil {
			return nil, fmt.Errorf("derive p2wpkh address: %w", err)
		}
		candidates = append(candidates, SweepCandidate{Address: witness.EncodeAddress(), Kind: SweepAddressP2WPKH})
	}

	legacy, err := btcutil.NewAddressPubKeyHash(btcutil.Hash160(serialized), params)
	if err != nil {
		return nil, fmt.Errorf("derive p2pkh address: %w", err)
	}
	candidates = append(candidates, SweepCandidate{Address: legacy.EncodeAddress(), Kind: SweepAddressP2PKH})

	return candidates, nil
}

// ResolveSweepSource finds which address of a private key holds coins, and
// falls back to the first candidate so the caller can report what it checked.
func ResolveSweepSource(
	ctx context.Context,
	chain ChequeChain,
	wif *btcutil.WIF,
	params *chaincfg.Params,
) (SweepSource, error) {
	candidates, err := SweepCandidates(wif, params)
	if err != nil {
		return SweepSource{}, err
	}

	for _, candidate := range candidates {
		// An arbitrary key can hold coins older than the wallet itself.
		utxos, err := chain.AddressUnspent(ctx, candidate.Address, time.Unix(0, 0))
		if err != nil {
			return SweepSource{}, fmt.Errorf("query %s utxos: %w", candidate.Kind, err)
		}
		if len(utxos) > 0 {
			return SweepSource{Address: candidate.Address, Kind: candidate.Kind, UTXOs: utxos}, nil
		}
	}

	return SweepSource{Address: candidates[0].Address, Kind: candidates[0].Kind}, nil
}

// SweepVbytes is the size of a sweep that spends inputs of one kind into a
// single output.
func SweepVbytes(kind SweepAddressKind, inputs int) uint64 {
	perInput := p2wpkhInputVbytes
	if kind == SweepAddressP2PKH {
		perInput = p2pkhInputVbytes
	}
	return uint64(inputs*perInput + sweepOutputVbytes + sweepOverheadVbytes)
}

// SweepFeeSats is what a sweep of the source costs at the given rate.
func SweepFeeSats(source SweepSource, feeSatPerVbyte uint64) uint64 {
	return SweepVbytes(source.Kind, len(source.UTXOs)) * feeSatPerVbyte
}

// BuildSweepTx builds the unsigned sweep, paying everything the source holds
// minus the fee to one destination.
func BuildSweepTx(
	source SweepSource,
	destAddress string,
	feeSatPerVbyte uint64,
	params *chaincfg.Params,
) (*wire.MsgTx, error) {
	totalSats := source.TotalSats()
	feeSats := SweepFeeSats(source, feeSatPerVbyte)
	if totalSats <= feeSats {
		return nil, fmt.Errorf("insufficient funds: total %d sats, fee %d sats", totalSats, feeSats)
	}

	destAddr, err := btcutil.DecodeAddress(destAddress, params)
	if err != nil {
		return nil, fmt.Errorf("decode destination address: %w", err)
	}
	if !destAddr.IsForNet(params) {
		return nil, fmt.Errorf("destination address is for another network")
	}

	pkScript, err := txscript.PayToAddrScript(destAddr)
	if err != nil {
		return nil, fmt.Errorf("create output script: %w", err)
	}

	tx := wire.NewMsgTx(wire.TxVersion)
	for _, utxo := range source.UTXOs {
		txHash, err := chainhash.NewHashFromStr(utxo.TxID)
		if err != nil {
			return nil, fmt.Errorf("parse txid: %w", err)
		}
		tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(txHash, uint32(utxo.Vout)), nil, nil))
	}
	tx.AddTxOut(wire.NewTxOut(int64(totalSats-feeSats), pkScript))

	return tx, nil
}

// SignSweepTx signs every input with the key that controls the source address.
func SignSweepTx(
	tx *wire.MsgTx,
	source SweepSource,
	wif *btcutil.WIF,
	params *chaincfg.Params,
) (*wire.MsgTx, error) {
	sourceAddr, err := btcutil.DecodeAddress(source.Address, params)
	if err != nil {
		return nil, fmt.Errorf("decode source address: %w", err)
	}
	sourcePkScript, err := txscript.PayToAddrScript(sourceAddr)
	if err != nil {
		return nil, fmt.Errorf("create source script: %w", err)
	}

	for i, utxo := range source.UTXOs {
		switch source.Kind {
		case SweepAddressP2WPKH:
			witness, err := txscript.WitnessSignature(
				tx,
				txscript.NewTxSigHashes(tx, txscript.NewCannedPrevOutputFetcher(sourcePkScript, utxo.ValueSats)),
				i,
				utxo.ValueSats,
				sourcePkScript,
				txscript.SigHashAll,
				wif.PrivKey,
				wif.CompressPubKey,
			)
			if err != nil {
				return nil, fmt.Errorf("sign witness input %d: %w", i, err)
			}
			tx.TxIn[i].Witness = witness

		case SweepAddressP2PKH:
			sigScript, err := txscript.SignatureScript(
				tx,
				i,
				sourcePkScript,
				txscript.SigHashAll,
				wif.PrivKey,
				wif.CompressPubKey,
			)
			if err != nil {
				return nil, fmt.Errorf("sign input %d: %w", i, err)
			}
			tx.TxIn[i].SignatureScript = sigScript

		case SweepAddressUnknown:
			return nil, fmt.Errorf("cannot sign %s input", source.Kind)

		default:
			return nil, fmt.Errorf("cannot sign %s input", source.Kind)
		}
	}

	return tx, nil
}
