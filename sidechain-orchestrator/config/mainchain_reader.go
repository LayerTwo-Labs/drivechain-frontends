package config

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// MainchainReaderUser is the Core RPC user a sidechain reads the mainchain as.
const MainchainReaderUser = "sidechain-reader"

// MainchainReaderRPCs are the only Core RPCs the reader user may call.
var MainchainReaderRPCs = []string{
	"getbestblockhash",
	"getblock",
	"getblockchaininfo",
	"getblockcount",
	"getblockhash",
	"getblockheader",
	"getnetworkinfo",
	"getrawtransaction",
	"gettxout",
	"gettxoutproof",
}

const mainchainReaderCookieFile = "mainchain-reader.cookie"

// MainchainReaderCookie returns the reader's credential file in dir, in Core
// cookie format. It writes the file with a new password when absent.
func MainchainReaderCookie(dir string) (string, error) {
	path := filepath.Join(dir, mainchainReaderCookieFile)
	if _, _, err := ReadCookieFile(path); err == nil {
		return path, nil
	} else if !errors.Is(err, os.ErrNotExist) {
		return "", err
	}
	secret := make([]byte, 32)
	if _, err := rand.Read(secret); err != nil {
		return "", fmt.Errorf("mainchain reader password: %w", err)
	}
	if err := os.MkdirAll(dir, 0o700); err != nil {
		return "", err
	}
	content := MainchainReaderUser + ":" + hex.EncodeToString(secret)
	if err := os.WriteFile(path, []byte(content), 0o600); err != nil {
		return "", fmt.Errorf("write mainchain reader cookie: %w", err)
	}
	return path, nil
}

// MainchainReaderArgs returns the Core arguments that add the reader user.
// keepDefault leaves the whitelist default to the user's own conf.
func MainchainReaderArgs(cookiePath string, keepDefault bool) ([]string, error) {
	user, password, err := ReadCookieFile(cookiePath)
	if err != nil {
		return nil, err
	}
	salt := make([]byte, 16)
	if _, err := rand.Read(salt); err != nil {
		return nil, fmt.Errorf("mainchain reader salt: %w", err)
	}
	args := mainchainReaderArgs(user, password, hex.EncodeToString(salt))
	if !keepDefault {
		// Keeps full access for the cookie user and any rpcuser.
		args = append(args, "-rpcwhitelistdefault=0")
	}
	return args, nil
}

func mainchainReaderArgs(user, password, salt string) []string {
	mac := hmac.New(sha256.New, []byte(salt))
	mac.Write([]byte(password))
	return []string{
		fmt.Sprintf("-rpcauth=%s:%s$%s", user, salt, hex.EncodeToString(mac.Sum(nil))),
		fmt.Sprintf("-rpcwhitelist=%s:%s", user, strings.Join(MainchainReaderRPCs, ",")),
	}
}
