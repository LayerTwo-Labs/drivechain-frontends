package drivechaind

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"

	"github.com/btcsuite/btcd/btcjson"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/rpcclient"
)

type Client struct {
	client *rpcclient.Client
}

func NewClient(host, user, password string) (*Client, error) {
	client, err := rpcclient.New(
		&rpcclient.ConnConfig{
			Host:              host,
			User:              user,
			Pass:              password,
			DisableTLS:        true,
			HTTPPostMode:      true,
			EnableBCInfoHacks: false,
		}, nil)
	if err != nil {
		return nil, fmt.Errorf("create rpc client: %v", err)
	}

	// test connection by getting the block count
	count, err := client.GetBlockCount()
	if err != nil {
		fmt.Errorf("get block count: %v", err)
	}

	fmt.Printf("successfully connected, at height: %d\n", count)

	return &Client{
		client: client,
	}, nil
}

func (c *Client) SendCoins(address btcutil.Address, amount btcutil.Amount) (*chainhash.Hash, error) {
	tx, err := c.client.SendToAddress(address, amount)
	if err != nil {
		return nil, err
	}

	return tx, nil
}

func (c *Client) ListTransactions() ([]btcjson.ListTransactionsResult, error) {
	txs, err := c.client.ListTransactionsCount("*", 1000)
	if err != nil {
		return nil, err
	}

	return txs, nil
}

func (c *Client) Ping() (int64, error) {
	count, err := c.client.GetBlockCount()
	if err != nil {
		return 0, err
	}

	return count, nil
}

func (c *Client) Disconnect() {
	c.client.Shutdown()
}

func CheckValidDepositAddress(depositAddress string) (bool, error) {
	parts := strings.Split(depositAddress, "_")
	if len(parts) != 3 {
		return false, errors.New("invalid address format")
	}

	sidechainNumStr := parts[0]
	address := parts[1]

	addrWithoutChecksum := fmt.Sprintf("%s_%s_", sidechainNumStr, address)

	hash := sha256.Sum256([]byte(addrWithoutChecksum))
	calculatedChecksum := hex.EncodeToString(hash[:3])

	checksum := parts[2]
	if checksum != calculatedChecksum {
		return false, errors.New("sidechain deopsit address invalid, checksums does not match")
	}

	return true, nil
}
