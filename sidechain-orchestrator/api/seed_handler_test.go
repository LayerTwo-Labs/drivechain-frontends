package api

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

const seedHandlerMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

func newSeedHandler(t *testing.T, net *chaincfg.Params) *WalletHandler {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	h := NewWalletHandler(svc)
	h.SetEngine(wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, nil), wallet.StaticParams(net), log))
	return h
}

func TestExploreSeedUsesTheEngineNetwork(t *testing.T) {
	h := newSeedHandler(t, &chaincfg.SigNetParams)

	out, err := h.ExploreSeed(context.Background(), &pb.ExploreSeedRequest{
		Mnemonic: seedHandlerMnemonic, BasePath: "m/84'/1'/0'/1", StartIndex: 0, Count: 2,
	})
	require.NoError(t, err)
	require.Len(t, out.Keys, 2)
	require.Equal(t, "m/84'/1'/0'/1/0", out.Keys[0].Path)
	require.Equal(t, "tb1q9u62588spffmq4dzjxsr5l297znf3z6j5p2688", out.Keys[0].Address)
	require.Equal(t, "cQ5TcujvBuw5bZfEVJmXZw5Ac1mQ6ryAjHeDrJcmn6oDyhfva5by", out.Keys[0].Wif)
	require.Regexp(t, "^tprv", out.Xprv)
	require.Regexp(t, "^tpub", out.Xpub)
	require.NotEmpty(t, out.SeedHex)
	require.NotEmpty(t, out.Bip47PaymentCode)
}

func TestExploreSeedRejectsAnInvalidMnemonic(t *testing.T) {
	h := newSeedHandler(t, &chaincfg.MainNetParams)

	_, err := h.ExploreSeed(context.Background(), &pb.ExploreSeedRequest{
		Mnemonic: "abandon abandon", BasePath: "m/84'/0'/0'/0", Count: 1,
	})
	require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestGenerateMnemonicGivesTwelveValidWords(t *testing.T) {
	h := newSeedHandler(t, &chaincfg.MainNetParams)

	first, err := h.GenerateMnemonic(context.Background(), &pb.GenerateMnemonicRequest{})
	require.NoError(t, err)
	second, err := h.GenerateMnemonic(context.Background(), &pb.GenerateMnemonicRequest{})
	require.NoError(t, err)

	normal, err := wallet.ParseMnemonic(first.Mnemonic)
	require.NoError(t, err)
	require.Equal(t, first.Mnemonic, normal)
	require.Len(t, strings.Fields(first.Mnemonic), 12)
	require.NotEqual(t, first.Mnemonic, second.Mnemonic)
}

func TestSeedRPCsOverTheWire(t *testing.T) {
	h := newSeedHandler(t, &chaincfg.MainNetParams)
	mux := http.NewServeMux()
	srv := connect.NewServer()
	rpc.RegisterWalletManagerServiceHandler(srv, h)
	connecthttp.Mount(mux, srv, connecthttp.WithReadMaxBytes(0))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)
	client := rpc.NewWalletManagerServiceClient(connect.NewClient(connecthttp.NewTransport(server.Client(), server.URL, connecthttp.WithReadMaxBytes(0))))
	ctx := context.Background()

	out, err := client.ExploreSeed(ctx, &pb.ExploreSeedRequest{
		Mnemonic: seedHandlerMnemonic, BasePath: "m/86'/0'/0'/0", StartIndex: 0, Count: 1,
	})
	require.NoError(t, err)
	require.Equal(t, "xprv9s21ZrQH143K3GJpoapnV8SFfukcVBSfeCficPSGfubmSFDxo1kuHnLisriDvSnRRuL2Qrg5ggqHKNVpxR86QEC8w35uxmGoggxtQTPvfUu", out.Xprv)
	require.Equal(t, "PD1mf1yi3BKbwH935QwrB1CvhugkodvBtusgCsEVtJrucpMK52841", out.Bip47PaymentCode)
	require.Len(t, out.Keys, 1)
	require.Equal(t, &pb.ExploredKey{
		Path:      "m/86'/0'/0'/0/0",
		Address:   "bc1p5cyxnuxmeuwuvkwfem96lqzszd02n6xdcjrs20cac6yqjjwudpxqkedrcr",
		PublicKey: "03cc8a4bc64d897bddc5fbc2f670f7a8ba0b386779106cf1223c6fc5d7cd6fc115",
		Wif:       "KyRv5iFPHG7iB5E4CqvMzH3WFJVhbfYK4VY7XAedd9Ys69mEsPLQ",
	}, &pb.ExploredKey{Path: out.Keys[0].Path, Address: out.Keys[0].Address, PublicKey: out.Keys[0].PublicKey, Wif: out.Keys[0].Wif})

	_, err = client.ExploreSeed(ctx, &pb.ExploreSeedRequest{Mnemonic: "abandon abandon", BasePath: "m/84'/0'/0'/0", Count: 1})
	require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

	generated, err := client.GenerateMnemonic(ctx, &pb.GenerateMnemonicRequest{})
	require.NoError(t, err)
	require.Len(t, strings.Fields(generated.Mnemonic), 12)
}

func TestValidateMnemonicNamesTheKind(t *testing.T) {
	h := newSeedHandler(t, &chaincfg.MainNetParams)
	for phrase, want := range map[string]pb.MnemonicKind{
		seedHandlerMnemonic: pb.MnemonicKind_MNEMONIC_KIND_BIP39,
		"  Abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon ABOUT ": pb.MnemonicKind_MNEMONIC_KIND_BIP39,
		strings.Replace(seedHandlerMnemonic, "about", "zebra", 1):                                          pb.MnemonicKind_MNEMONIC_KIND_INVALID,
		"bitter grass shiver impose acquire brush forget axis eager alone wine silver":                     pb.MnemonicKind_MNEMONIC_KIND_ELECTRUM,
		"": pb.MnemonicKind_MNEMONIC_KIND_INVALID,
	} {
		got, err := h.ValidateMnemonic(context.Background(), &pb.ValidateMnemonicRequest{Mnemonic: phrase})
		require.NoError(t, err)
		require.Equal(t, want, got.Kind, phrase)
	}
}
