package drivechaind

import (
	"context"
	"fmt"
	"log"
	"strings"

	"connectrpc.com/connect"
	bitcoindv1alpha "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	drivechaindv1 "github.com/barebitcoin/btc-buf/gen/bitcoin/drivechaind/v1"
	rpcclient "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/samber/lo"
)

type Client struct {
	client *rpcclient.Bitcoind
}

func NewClient(ctx context.Context, host, user, password string) (*Client, error) {
	client, err := rpcclient.NewBitcoind(
		ctx,
		host,
		user,
		password,
	)
	if err != nil {
		return nil, fmt.Errorf("create rpc client: %v", err)
	}

	// test connection by getting blockchain info
	res, err := client.GetBlockchainInfo(ctx, connect.NewRequest(&bitcoindv1alpha.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get blockchain info: %v", err)
	}

	log.Printf("successfully connected, at height: %d", res.Msg.Blocks)

	return &Client{
		client: client,
	}, nil
}

type TransferType string

const (
	Sidechain TransferType = "sidechain"
	Mainchain TransferType = "mainchain"
)

func (c *Client) SendCoins(ctx context.Context, destination string, amount btcutil.Amount) (*chainhash.Hash, error) {
	transferType := Mainchain
	if strings.Contains(destination, "_") {
		transferType = Sidechain
	}

	switch transferType {
	case Mainchain:
		_, err := btcutil.DecodeAddress(destination, &chaincfg.MainNetParams)
		if err != nil {
			return nil, fmt.Errorf("could not decode address: %w", err)
		}

		tx, err := c.client.SendToAddress(ctx, connect.NewRequest(&bitcoindv1alpha.SendToAddressRequest{
			Address: destination,
			Amount:  amount.ToBTC(),
		}))
		if err != nil {
			return nil, fmt.Errorf("could not send to address: %w", err)
		}

		return chainhash.NewHashFromStr(tx.Msg.Txid)

	case Sidechain:

		tx, err := c.client.CreateSidechainDeposit(ctx, connect.NewRequest(&drivechaindv1.CreateSidechainDepositRequest{
			Destination: destination,
			Amount:      amount.ToBTC(),
			Fee:         0.0001,
		}))
		if err != nil {
			return nil, fmt.Errorf("create sidechaindeposit: %w", err)
		}

		return chainhash.NewHashFromStr(tx.Msg.Txid)
	}

	return nil, fmt.Errorf("received invalid transfer type %s", transferType)
}

func (c *Client) ListTransactions(ctx context.Context) ([]*bitcoindv1alpha.GetTransactionResponse, error) {
	txs, err := c.client.ListTransactions(ctx, connect.NewRequest(&bitcoindv1alpha.ListTransactionsRequest{
		Wallet: "",
		Count:  1000,
	}))
	if err != nil {
		return nil, err
	}

	return lo.Filter(txs.Msg.Transactions, func(tx *bitcoindv1alpha.GetTransactionResponse, index int) bool {
		// we only want to show withdrawals going from our wallet
		return tx.Amount <= 0 &&
			// and avoid txs with negative confirmations
			tx.Confirmations >= 0
	}), nil
}

func (c *Client) Ping(ctx context.Context) (uint32, error) {
	count, err := c.client.GetBlockchainInfo(ctx, connect.NewRequest(&bitcoindv1alpha.GetBlockchainInfoRequest{}))
	if err != nil {
		return 0, err
	}

	return count.Msg.Blocks, nil
}

func (c *Client) Shutdown(ctx context.Context) {
	c.client.Shutdown(ctx)
}
