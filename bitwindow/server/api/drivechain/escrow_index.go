package api_drivechain

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
)

// escrowReadTimeout bounds one read of the hosted index. A light install shows
// a page rather than waiting, so this stays short.
const escrowReadTimeout = 8 * time.Second

// escrowIndex reads the BIP300 escrow from a hosted Esplora index.
//
// A light install runs no enforcer, and the index reads one on its behalf. It
// answers the same state the enforcer holds: which slots activated, how they
// were voted in, and what each treasury holds.
type escrowIndex struct {
	baseURL string
	http    *http.Client
}

func newEscrowIndex(baseURL string) *escrowIndex {
	return &escrowIndex{
		baseURL: strings.TrimRight(baseURL, "/"),
		http:    &http.Client{Timeout: escrowReadTimeout},
	}
}

// Sidechains reads every activated slot the index knows.
func (i *escrowIndex) Sidechains(ctx context.Context) ([]*pb.ListSidechainsResponse_Sidechain, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet,
		i.baseURL+"/sidechains", nil)
	if err != nil {
		return nil, fmt.Errorf("build the escrow request: %w", err)
	}

	resp, err := i.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("read the escrow from %s: %w", i.baseURL, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read the escrow answer: %w", err)
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("the index answered %d: %s", resp.StatusCode,
			strings.TrimSpace(string(body)))
	}

	var rows []struct {
		Slot             uint32 `json:"slot"`
		Title            string `json:"title"`
		Description      string `json:"description"`
		VoteCount        uint32 `json:"vote_count"`
		ProposalHeight   uint32 `json:"proposal_height"`
		ActivationHeight uint32 `json:"activation_height"`
		// A slot with no treasury answers null, which is not the same as one
		// holding zero sats.
		Treasury *struct {
			Txid      string `json:"txid"`
			Vout      uint32 `json:"vout"`
			ValueSats int64  `json:"value_sats"`
		} `json:"treasury"`
	}
	if err := json.Unmarshal(body, &rows); err != nil {
		return nil, fmt.Errorf("decode the escrow answer: %w", err)
	}

	out := make([]*pb.ListSidechainsResponse_Sidechain, 0, len(rows))
	for _, r := range rows {
		chain := &pb.ListSidechainsResponse_Sidechain{
			Slot:             r.Slot,
			Title:            r.Title,
			Description:      r.Description,
			VoteCount:        r.VoteCount,
			ProposalHeight:   r.ProposalHeight,
			ActivationHeight: r.ActivationHeight,
		}
		if r.Treasury != nil {
			chain.BalanceSatoshi = r.Treasury.ValueSats
			chain.ChaintipTxid = r.Treasury.Txid
			chain.ChaintipVout = r.Treasury.Vout
		}
		out = append(out, chain)
	}
	return out, nil
}
