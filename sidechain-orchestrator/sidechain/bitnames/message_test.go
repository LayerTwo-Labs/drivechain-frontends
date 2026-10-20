package bitnames

import (
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitnames/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/stretchr/testify/require"
	"net"
	"strconv"
	"testing"
)

func TestHandlerSendsTheMessage(t *testing.T) {
	server, params := recordParams(t, `null`)
	t.Cleanup(server.Close)
	host, port, err := net.SplitHostPort(server.Listener.Addr().String())
	require.NoError(t, err)
	portNum, err := strconv.Atoi(port)
	require.NoError(t, err)
	h := NewHandler(sidechain.NewJSONRPCProxy(host, portNum))
	_, err = h.EncryptMsg(t.Context(), &pb.EncryptMsgRequest{EncryptionPubkey: "key", Msg: "the message"})
	require.NoError(t, err)
	require.JSONEq(t, `["key","the message"]`, string(*params))
	_, err = h.SignArbitraryMsg(t.Context(), &pb.SignArbitraryMsgRequest{VerifyingKey: "key", Msg: "the message"})
	require.NoError(t, err)
	require.JSONEq(t, `["key","the message"]`, string(*params))
	_, err = h.SignArbitraryMsgAsAddr(t.Context(), &pb.SignArbitraryMsgAsAddrRequest{Address: "address", Msg: "the message"})
	require.NoError(t, err)
	require.JSONEq(t, `["address","the message"]`, string(*params))
}
