// Package bitassets provides a JSON-RPC client for the Bitassets sidechain.
package bitassets

import (
	"encoding/hex"
	"fmt"
)

// BalanceResponse is the reply from the "balance" RPC.
type BalanceResponse struct {
	TotalSats     int64 `json:"total_sats"`
	AvailableSats int64 `json:"available_sats"`
}

// PeerInfo describes a connected peer.
type PeerInfo struct {
	Address string `json:"address"`
	Status  string `json:"status"`
}

type assetFields struct {
	SocketAddrV4     *string `json:"socket_addr_v4,omitempty"`
	SocketAddrV6     *string `json:"socket_addr_v6,omitempty"`
	EncryptionPubkey *string `json:"encryption_pubkey,omitempty"`
	SigningPubkey    *string `json:"signing_pubkey,omitempty"`
}

type assetData struct {
	assetFields
	Commitment *string `json:"commitment,omitempty"`
}

type nodeAssetData struct {
	assetFields
	Commitment *[32]byte `json:"commitment,omitempty"`
}

func (d assetData) toNode() (nodeAssetData, error) {
	node := nodeAssetData{assetFields: d.assetFields}
	if d.Commitment == nil {
		return node, nil
	}
	raw, err := hex.DecodeString(*d.Commitment)
	if err != nil {
		return nodeAssetData{}, fmt.Errorf("decode commitment: %w", err)
	}
	if len(raw) != 32 {
		return nodeAssetData{}, fmt.Errorf("commitment must be 32 bytes")
	}
	node.Commitment = (*[32]byte)(raw)
	return node, nil
}

func (d nodeAssetData) toClient() assetData {
	data := assetData{assetFields: d.assetFields}
	if d.Commitment != nil {
		digest := hex.EncodeToString(d.Commitment[:])
		data.Commitment = &digest
	}
	return data
}
