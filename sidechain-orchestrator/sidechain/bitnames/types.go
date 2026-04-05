// Package bitnames provides a JSON-RPC client for the BitNames sidechain.
package bitnames

import "encoding/json"

// BalanceResponse is the reply from the "balance" RPC.
type BalanceResponse struct {
	TotalSats     int64 `json:"total_sats"`
	AvailableSats int64 `json:"available_sats"`
}

// BitNameData holds optional metadata fields attached to a BitName.
type BitNameData struct {
	Commitment      *string `json:"commitment,omitempty"`
	EncryptionPubkey *string `json:"encryption_pubkey,omitempty"`
	PaymailFeeSats  *int64  `json:"paymail_fee_sats,omitempty"`
	SigningPubkey    *string `json:"signing_pubkey,omitempty"`
	SocketAddrV4    *string `json:"socket_addr_v4,omitempty"`
	SocketAddrV6    *string `json:"socket_addr_v6,omitempty"`
}

// BitnameDetails describes the on-chain state of a registered BitName.
type BitnameDetails struct {
	SeqID            string  `json:"seq_id"`
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
	HashLastMainBlock     string  `json:"hash_last_main_block"`
	BmmBlockCreated       *string `json:"bmm_block_created,omitempty"`
	BmmBlockSubmitted     *string `json:"bmm_block_submitted,omitempty"`
	BmmBlockSubmittedBlind *string `json:"bmm_block_submitted_blind,omitempty"`
	Ntxn                  int     `json:"ntxn"`
	Nfees                 int     `json:"nfees"`
	Txid                  string  `json:"txid"`
	Error                 *string `json:"error,omitempty"`
}
