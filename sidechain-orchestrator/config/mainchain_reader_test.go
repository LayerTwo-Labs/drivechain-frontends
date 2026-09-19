package config

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMainchainReaderCookieKeepsItsPassword(t *testing.T) {
	dir := t.TempDir()
	path, err := MainchainReaderCookie(dir)
	require.NoError(t, err)
	user, password, err := ReadCookieFile(path)
	require.NoError(t, err)
	require.Equal(t, MainchainReaderUser, user)
	require.Len(t, password, 64)

	info, err := os.Stat(path)
	require.NoError(t, err)
	if filepath.Separator == '/' {
		require.Equal(t, os.FileMode(0o600), info.Mode().Perm())
	}

	again, err := MainchainReaderCookie(dir)
	require.NoError(t, err)
	_, same, err := ReadCookieFile(again)
	require.NoError(t, err)
	require.Equal(t, password, same)
}

func TestMainchainReaderCookieRefusesAMalformedFile(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(dir, mainchainReaderCookieFile), []byte("no separator"), 0o600))
	_, err := MainchainReaderCookie(dir)
	require.ErrorContains(t, err, "malformed")
}

// The expected hash is the output of the Core rpcauth.py algorithm.
func TestMainchainReaderArgsMatchRPCAuth(t *testing.T) {
	args := mainchainReaderArgs("sidechain-reader", "secret", "0123456789abcdef0123456789abcdef")
	require.Equal(t, []string{
		"-rpcauth=sidechain-reader:0123456789abcdef0123456789abcdef$0ad814968caefdecab8a6c0c55414688fdcad02f100ee7ac5def2352aaff36e5",
		"-rpcwhitelist=sidechain-reader:" + strings.Join(MainchainReaderRPCs, ","),
	}, args)
}

func TestMainchainReaderArgsKeepAUserWhitelist(t *testing.T) {
	path, err := MainchainReaderCookie(t.TempDir())
	require.NoError(t, err)
	open, err := MainchainReaderArgs(path, false)
	require.NoError(t, err)
	require.Contains(t, open, "-rpcwhitelistdefault=0")
	kept, err := MainchainReaderArgs(path, true)
	require.NoError(t, err)
	require.NotContains(t, kept, "-rpcwhitelistdefault=0")
	require.Len(t, kept, 2)
}
