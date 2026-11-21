package bitwindowd

import (
	mempoolrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/mempool/v1/mempoolv1connect"
)

// SetMempool sets the drivechaind mempool that ListRecentTransactions reads.
func (s *Server) SetMempool(client mempoolrpc.MempoolServiceClient) {
	s.mempool = client
}
