package truthcoin

import (
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/truthcoin/v1"
	"github.com/stretchr/testify/require"
	"testing"
)

func TestHandlerSendsTheMessage(t *testing.T) {
	h, params := capturingRPC(t, `null`)
	_, err := h.EncryptMsg(t.Context(), &pb.EncryptMsgRequest{EncryptionPubkey: "key", Msg: "the message"})
	require.NoError(t, err)
	require.JSONEq(t, `["key","the message"]`, string((*params)[0]))
	_, err = h.SignArbitraryMsg(t.Context(), &pb.SignArbitraryMsgRequest{VerifyingKey: "key", Msg: "the message"})
	require.NoError(t, err)
	require.JSONEq(t, `["key","the message"]`, string((*params)[1]))
	_, err = h.SignArbitraryMsgAsAddr(t.Context(), &pb.SignArbitraryMsgAsAddrRequest{Address: "address", Msg: "the message"})
	require.NoError(t, err)
	require.JSONEq(t, `["address","the message"]`, string((*params)[2]))
}
