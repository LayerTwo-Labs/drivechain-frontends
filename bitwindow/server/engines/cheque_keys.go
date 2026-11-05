package engines

import (
	"context"
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"errors"
	"fmt"

	"github.com/btcsuite/btcd/btcutil/hdkeychain"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	orchwallet "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func (e *ChequeEngine) deriveChequePath(seedHex string, path []uint32) (*hdkeychain.ExtendedKey, error) {
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return nil, fmt.Errorf("decode seed: %w", err)
	}
	key, err := hdkeychain.NewMaster(seed, e.chainParams)
	if err != nil {
		return nil, fmt.Errorf("create master key: %w", err)
	}
	for _, index := range path {
		key, err = key.Derive(index)
		if err != nil {
			return nil, fmt.Errorf("derive cheque path: %w", err)
		}
	}
	return key, nil
}

func (e *ChequeEngine) chequeRoot(ctx context.Context, walletID, seedHex, scope string) (*hdkeychain.ExtendedKey, string, error) {
	if scope == "" {
		return nil, "", errors.New("cheque network is empty")
	}
	wallet, err := e.walletEngine.GetWalletInfo(ctx, walletID)
	if err != nil {
		return nil, "", err
	}
	path := wallet.DerivationPath
	if path == "" {
		purpose, ok := orchwallet.HotScriptKind(wallet.ScriptType).Purpose()
		if !ok {
			return nil, "", errors.New("wallet has no cheque account path")
		}
		path = fmt.Sprintf("m/%d'/%d'/%d'", purpose, e.chainParams.HDCoinType, wallet.AccountIndex)
	}
	account, err := orchwallet.ParseAccountPath(path)
	if err != nil {
		return nil, "", fmt.Errorf("read cheque account path: %w", err)
	}
	scopeHash := sha256.Sum256([]byte("bitwindow-cheque/v1\x00" + scope + "\x00" + account.String()))
	indices := []uint32{hdkeychain.HardenedKeyStart + 44, hdkeychain.HardenedKeyStart,
		hdkeychain.HardenedKeyStart + chequeAccount, hdkeychain.HardenedKeyStart + 1}
	for i := 0; i < len(scopeHash); i += 4 {
		indices = append(indices, binary.BigEndian.Uint32(scopeHash[i:i+4]))
	}
	root, err := e.deriveChequePath(seedHex, indices)
	if err != nil {
		return nil, "", err
	}
	pub, err := root.ECPubKey()
	if err != nil {
		return nil, "", fmt.Errorf("get cheque root public key: %w", err)
	}
	domain := sha256.Sum256(append(pub.SerializeCompressed(), root.ChainCode()...))
	return root, hex.EncodeToString(domain[:]), nil
}

func (e *ChequeEngine) CreateCheque(ctx context.Context, walletID string, amount uint64) (*cheques.Cheque, error) {
	e.issueMu.Lock()
	defer e.issueMu.Unlock()

	seed, err := e.walletEngine.GetWalletSeed(ctx, walletID)
	if err != nil {
		return nil, err
	}
	root, domain, err := e.chequeRoot(ctx, walletID, seed, e.network)
	if err != nil {
		return nil, err
	}
	index, err := cheques.GetNextDomainIndex(ctx, e.db, domain)
	if err != nil {
		return nil, err
	}
	key, err := root.Derive(index)
	if err != nil {
		return nil, fmt.Errorf("derive cheque key: %w", err)
	}
	address, err := e.chequeKeyAddress(key)
	if err != nil {
		return nil, err
	}
	id, err := cheques.CreateVersioned(ctx, e.db, walletID, index, amount, address, 1, domain, e.network)
	if err != nil {
		return nil, err
	}
	return cheques.Get(ctx, e.db, walletID, id)
}

func (e *ChequeEngine) ChequePrivateKey(ctx context.Context, cheque *cheques.Cheque) (string, error) {
	if cheque.KeyVersion == 0 {
		return e.DeriveChequePrivateKey(ctx, cheque.WalletID, cheque.DerivationIndex)
	}
	if cheque.KeyVersion != 1 {
		return "", fmt.Errorf("unsupported cheque key version %d", cheque.KeyVersion)
	}
	seed, err := e.walletEngine.GetWalletSeed(ctx, cheque.WalletID)
	if err != nil {
		return "", err
	}
	root, domain, err := e.chequeRoot(ctx, cheque.WalletID, seed, cheque.KeyScope)
	if err != nil {
		return "", err
	}
	if domain != cheque.KeyDomain {
		return "", errors.New("cheque key domain does not match the wallet and network")
	}
	key, err := root.Derive(cheque.DerivationIndex)
	if err != nil {
		return "", fmt.Errorf("derive cheque key: %w", err)
	}
	return e.chequeKeyWIF(key)
}
