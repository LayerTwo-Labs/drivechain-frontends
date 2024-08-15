package drivechaind

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"strings"

	"github.com/btcsuite/btcd/btcjson"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
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
		return nil, fmt.Errorf("get block count: %v", err)
	}

	log.Printf("successfully connected, at height: %d", count)

	return &Client{
		client: client,
	}, nil
}

type TransferType string

const (
	Sidechain TransferType = "sidechain"
	Mainchain TransferType = "mainchain"
)

func (c *Client) SendCoins(destination string, amount btcutil.Amount, transferType TransferType) (*chainhash.Hash, error) {

	switch transferType {
	case Mainchain:
		address, err := btcutil.DecodeAddress(destination, &chaincfg.MainNetParams)
		if err != nil {
			return nil, fmt.Errorf("could not decode address: %w", err)
		}

		tx, err := c.client.SendToAddress(address, amount)
		if err != nil {
			return nil, fmt.Errorf("could not send to address: %w", err)
		}
		return tx, nil

	case Sidechain:
		withoutS := strings.TrimPrefix(destination, "s")
		sidechainNum := strings.Split(withoutS, "_")[0]

		res, err := c.client.RawRequest("createsidechaindeposit", []json.RawMessage{
			json.RawMessage(sidechainNum),
			json.RawMessage(destination),
			json.RawMessage(fmt.Sprintf("%.8f", amount.ToBTC())),
			json.RawMessage("0.001"), // fixed fee
		})
		if err != nil {
			return nil, fmt.Errorf("create sidechaindeposit: %w", err)
		}

		var ress []byte
		if err := res.UnmarshalJSON(ress); err != nil {
			return nil, fmt.Errorf("unmarshal sidechaindeposit: %w", err)
		}

		return chainhash.NewHashFromStr(string(ress))
	}

	return nil, fmt.Errorf("received invalid transfer type %s", transferType)
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

func CheckValidDepositAddress(depositAddress string) error {
	parts := strings.Split(depositAddress, "_")
	if len(parts) != 3 {
		return errors.New("invalid address format")
	}

	sidechainNumStr := parts[0]
	address := parts[1]

	addrWithoutChecksum := fmt.Sprintf("%s_%s_", sidechainNumStr, address)

	hash := sha256.Sum256([]byte(addrWithoutChecksum))
	calculatedChecksum := hex.EncodeToString(hash[:3])

	checksum := parts[2]
	if checksum != calculatedChecksum {
		return errors.New("sidechain deopsit address invalid, checksums does not match")
	}

	return nil
}
