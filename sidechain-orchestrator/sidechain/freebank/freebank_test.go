package freebank

import (
	"context"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// fakeHost answers what the orchestrator would, so a test states one mainchain
// and reads the command line the chain asks for. FreeBank reads the mainchain
// over REST and the enforcer, never over Core's RPC, so the embedded Host
// answers the mainchain RPC methods with a panic.
type fakeHost struct {
	sidechain.Host
	backendOnly bool
	rest        string
	forkHeight  int
	hash        string
	hashErr     error
	tools       map[string]string
}

func (h fakeHost) BackendOnly() bool     { return h.backendOnly }
func (h fakeHost) MainchainREST() string { return h.rest }
func (h fakeHost) ForkHeight() int       { return h.forkHeight }

func (h fakeHost) MainchainBlockHash(context.Context, int) (string, error) {
	return h.hash, h.hashErr
}

func (h fakeHost) ToolPath(name string) string { return h.tools[name] }

func onECash() fakeHost {
	return fakeHost{
		rest:       "127.0.0.1:18302",
		forkHeight: 967680, // what the network catalog publishes for betanet
		hash:       "00000000000000030101ba5cfea54b22becc79f95dc6040beb76e01dd9d04042",
	}
}

func TestArgsPinTheForkBlock(t *testing.T) {
	args, err := NewClient("127.0.0.1", 8454, "").Args(context.Background(), onECash())
	require.NoError(t, err)
	assert.Equal(t, []string{
		"-mainchaintransport=enforcer",
		"-mainchainrest=127.0.0.1:18302",
		"-mainchainchain=main",
		"-mainchainblockpin=967680:00000000000000030101ba5cfea54b22becc79f95dc6040beb76e01dd9d04042",
	}, args)
}

// The node looks for grpcurl on PATH when the orchestrator holds none, so an
// absent one is not a refusal.
func TestArgsNameGrpcurlOnlyWhenItIsDownloaded(t *testing.T) {
	host := onECash()
	host.tools = map[string]string{"grpcurl": "/tmp/bin/grpcurl"}
	args, err := NewClient("127.0.0.1", 8454, "").Args(context.Background(), host)
	require.NoError(t, err)
	assert.Contains(t, args, "-grpcurlbin=/tmp/bin/grpcurl")
}

// A network with no published fork height gets a message, not a daemon that
// starts and exits.
func TestArgsRefuseANetworkWithNoForkHeight(t *testing.T) {
	host := onECash()
	host.forkHeight = 0
	_, err := NewClient("127.0.0.1", 8454, "").Args(context.Background(), host)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "fork height")
}

func TestArgsRefuseWithoutTheMainchainRestPort(t *testing.T) {
	host := onECash()
	host.rest = ""
	_, err := NewClient("127.0.0.1", 8454, "").Args(context.Background(), host)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "REST port")
}

// A mainchain that has not reached the fork height yet names the height it
// waits for.
func TestArgsReportAMainchainBehindTheFork(t *testing.T) {
	host := onECash()
	host.hashErr = fmt.Errorf("block height out of range")
	_, err := NewClient("127.0.0.1", 8454, "").Args(context.Background(), host)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "967680")
}

// The BMM engine drives FreeBank blocks, but FreeBank settles withdrawals on its
// own paths, so the orchestrator reads that from the type.
func TestFreeBankDrivesBmmButProposesNoBundle(t *testing.T) {
	var node sidechain.Node = NewClient("127.0.0.1", 8454, "")

	_, drivesBMM := node.(sidechain.BMMNode)
	assert.True(t, drivesBMM)

	_, proposesBundles := node.(sidechain.WithdrawalNode)
	assert.False(t, proposesBundles)
}
