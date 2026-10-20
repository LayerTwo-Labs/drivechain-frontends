package bitassets

import (
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1"
	"github.com/stretchr/testify/require"
	"testing"
)

func TestHandlerSendsTheMessage(t *testing.T) {
	proxy, params := paramsNode(t, `null`)
	h := NewHandler(proxy)
	_, err := h.EncryptMsg(t.Context(), &pb.EncryptMsgRequest{EncryptionPubkey: "key", Msg: "the message"})
	require.NoError(t, err)
	require.Equal(t, []any{"key", "the message"}, *params)
	_, err = h.SignArbitraryMsg(t.Context(), &pb.SignArbitraryMsgRequest{VerifyingKey: "key", Msg: "the message"})
	require.NoError(t, err)
	require.Equal(t, []any{"key", "the message"}, *params)
	_, err = h.SignArbitraryMsgAsAddr(t.Context(), &pb.SignArbitraryMsgAsAddrRequest{Address: "address", Msg: "the message"})
	require.NoError(t, err)
	require.Equal(t, []any{"address", "the message"}, *params)
}
