// Package bitnames provides a JSON-RPC client for the BitNames sidechain.
package bitnames

import (
	"encoding/hex"
	"encoding/json"
	"fmt"
)

// BalanceResponse is the reply from the "balance" RPC.
type BalanceResponse struct {
	TotalSats     int64 `json:"total_sats"`
	AvailableSats int64 `json:"available_sats"`
}

// BitNameData holds optional metadata fields attached to a BitName.
type BitNameData struct {
	Commitment       *string `json:"commitment,omitempty"`
	SocketAddrHost   *string `json:"socket_addr_host,omitempty"`
	EncryptionPubkey *string `json:"encryption_pubkey,omitempty"`
	PaymailFeeSats   *int64  `json:"paymail_fee_sats,omitempty"`
	SigningPubkey    *string `json:"signing_pubkey,omitempty"`
	SocketAddrV4     *string `json:"socket_addr_v4,omitempty"`
	SocketAddrV6     *string `json:"socket_addr_v6,omitempty"`
}

// BitnameDetails describes the on-chain state of a registered BitName.
type BitnameDetails struct {
	SeqID            string  `json:"seq_id"`
	SocketAddrHost   *string `json:"socket_addr_host,omitempty"`
	Commitment       *string `json:"commitment,omitempty"`
	SocketAddrV4     *string `json:"socket_addr_v4,omitempty"`
	SocketAddrV6     *string `json:"socket_addr_v6,omitempty"`
	EncryptionPubkey *string `json:"encryption_pubkey,omitempty"`
	SigningPubkey    *string `json:"signing_pubkey,omitempty"`
	PaymailFeeSats   *int64  `json:"paymail_fee_sats,omitempty"`
}

// BitnameEntry is a [hash, details] pair returned by the "bitnames" RPC.
type BitnameEntry struct {
	Hash    string
	Details BitnameDetails
}

// UnmarshalJSON decodes the [hash, details] tuple that the node returns.
func (e *BitnameEntry) UnmarshalJSON(data []byte) error {
	var raw [2]json.RawMessage
	if err := json.Unmarshal(data, &raw); err != nil {
		return err
	}
	if err := json.Unmarshal(raw[0], &e.Hash); err != nil {
		return err
	}
	return json.Unmarshal(raw[1], &e.Details)
}

// MarshalJSON encodes as the [hash, details] tuple the node expects.
func (e BitnameEntry) MarshalJSON() ([]byte, error) {
	return json.Marshal([2]interface{}{e.Hash, e.Details})
}

// PeerInfo describes a connected peer.
type PeerInfo struct {
	Address string `json:"address"`
	Status  string `json:"status"`
}

// SignatureResponse is returned by "sign_arbitrary_msg_as_addr".
type SignatureResponse struct {
	VerifyingKey string `json:"verifying_key"`
	Signature    string `json:"signature"`
}

// BmmResult is the response from the "mine" RPC.
type BmmResult struct {
	HashLastMainBlock      string  `json:"hash_last_main_block"`
	BmmBlockCreated        *string `json:"bmm_block_created,omitempty"`
	BmmBlockSubmitted      *string `json:"bmm_block_submitted,omitempty"`
	BmmBlockSubmittedBlind *string `json:"bmm_block_submitted_blind,omitempty"`
	Ntxn                   int     `json:"ntxn"`
	Nfees                  int     `json:"nfees"`
	Txid                   string  `json:"txid"`
	Error                  *string `json:"error,omitempty"`
}

// Commitment is the BLAKE3 digest a BitName holds. The node carries it as a
// 32-byte array, and every client shows it as hex.
type Commitment [32]byte

// Hex returns the digest in lower case hexadecimal.
func (c Commitment) Hex() string { return hex.EncodeToString(c[:]) }

// ParseCommitment reads the hex form, in either case.
func ParseCommitment(digest string) (Commitment, error) {
	raw, err := hex.DecodeString(digest)
	if err != nil {
		return Commitment{}, fmt.Errorf("commitment %q is not hexadecimal: %w", digest, err)
	}
	if len(raw) != len(Commitment{}) {
		return Commitment{}, fmt.Errorf("commitment %q is %d bytes, and the chain holds 32", digest, len(raw))
	}
	var parsed Commitment
	copy(parsed[:], raw)
	return parsed, nil
}

// nodeBitNameData is the form the node reads and writes. Its OpenAPI schema
// calls commitment a string, and serde carries a 32-byte array.
type nodeBitNameData struct {
	Commitment *Commitment `json:"commitment,omitempty"`
	// A BitName registered elsewhere can hold a host. This client never writes
	// one, and a resolver still has to reach that server.
	SocketAddrHost   *string `json:"socket_addr_host,omitempty"`
	EncryptionPubkey *string `json:"encryption_pubkey,omitempty"`
	PaymailFeeSats   *int64  `json:"paymail_fee_sats,omitempty"`
	SigningPubkey    *string `json:"signing_pubkey,omitempty"`
	SocketAddrV4     *string `json:"socket_addr_v4,omitempty"`
	SocketAddrV6     *string `json:"socket_addr_v6,omitempty"`
}

// nodeBitnameDetails adds the sequence id the node returns on a read.
type nodeBitnameDetails struct {
	nodeBitNameData
	SeqID string `json:"seq_id"`
}

func (d BitNameData) toNode() (nodeBitNameData, error) {
	// SocketAddrHost stays unset. The chain holds an ipv4 and an ipv6 address.
	node := nodeBitNameData{
		EncryptionPubkey: d.EncryptionPubkey,
		PaymailFeeSats:   d.PaymailFeeSats,
		SigningPubkey:    d.SigningPubkey,
		SocketAddrV4:     d.SocketAddrV4,
		SocketAddrV6:     d.SocketAddrV6,
	}
	if d.Commitment == nil || *d.Commitment == "" {
		return node, nil
	}
	parsed, err := ParseCommitment(*d.Commitment)
	if err != nil {
		return nodeBitNameData{}, err
	}
	node.Commitment = &parsed
	return node, nil
}

func (n nodeBitNameData) toClient() BitNameData {
	data := BitNameData{
		SocketAddrHost:   n.SocketAddrHost,
		EncryptionPubkey: n.EncryptionPubkey,
		PaymailFeeSats:   n.PaymailFeeSats,
		SigningPubkey:    n.SigningPubkey,
		SocketAddrV4:     n.SocketAddrV4,
		SocketAddrV6:     n.SocketAddrV6,
	}
	if n.Commitment != nil {
		digest := n.Commitment.Hex()
		data.Commitment = &digest
	}
	return data
}

func (n nodeBitnameDetails) toClient() BitnameDetails {
	data := n.nodeBitNameData.toClient()
	return BitnameDetails{
		SeqID:            n.SeqID,
		SocketAddrHost:   data.SocketAddrHost,
		Commitment:       data.Commitment,
		SocketAddrV4:     data.SocketAddrV4,
		SocketAddrV6:     data.SocketAddrV6,
		EncryptionPubkey: data.EncryptionPubkey,
		SigningPubkey:    data.SigningPubkey,
		PaymailFeeSats:   data.PaymailFeeSats,
	}
}

// nodeBitnameEntry is the [hash, details] tuple the "bitnames" RPC returns.
type nodeBitnameEntry struct {
	Hash    string
	Details nodeBitnameDetails
}

func (e *nodeBitnameEntry) UnmarshalJSON(data []byte) error {
	var raw [2]json.RawMessage
	if err := json.Unmarshal(data, &raw); err != nil {
		return err
	}
	if err := json.Unmarshal(raw[0], &e.Hash); err != nil {
		return err
	}
	return json.Unmarshal(raw[1], &e.Details)
}
