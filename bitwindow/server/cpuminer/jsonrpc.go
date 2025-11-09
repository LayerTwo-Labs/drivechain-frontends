/*
 * Copyright 2010 Jeff Garzik
 * Copyright 2012-2017 pooler
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.  See COPYING for more details.
 */

package cpuminer

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/rs/zerolog"
)

// jsonRpcCall performs a JSON-RPC call
func (m *Miner) jsonRpcCall(
	ctx context.Context, method string, params []any,
) (json.RawMessage, error) {
	start := time.Now()

	body, err := json.Marshal(map[string]any{
		"jsonrpc": "2.0",
		"method":  method,
		"params":  params,
		"id":      1,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal JSON-RPC request body: %w", err)
	}

	req, err := http.NewRequestWithContext(
		ctx, http.MethodPost, m.rpcURL, bytes.NewReader(body),
	)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("User-Agent", "bitwindow-cpuminer")

	if m.rpcUser != "" || m.rpcPass != "" {
		req.SetBasicAuth(m.rpcUser, m.rpcPass)
	}

	resp, err := m.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("RPC call failed: %w", err)
	}
	//nolint:errcheck
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HTTP error: %d %s", resp.StatusCode, resp.Status)
	}

	readBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response: %w", err)
	}

	zerolog.Ctx(ctx).Trace().
		Msgf("JSON-RPC %q response in %s: %s", method, time.Since(start), string(readBody))

	var val struct {
		Result json.RawMessage `json:"result"`
		Error  json.RawMessage `json:"error"`
	}
	if err := json.Unmarshal(readBody, &val); err != nil {
		return nil, fmt.Errorf("JSON decode failed: %v", err)
	}

	// Check for error
	if val.Error != nil {
		return nil, fmt.Errorf("JSON-RPC call failed: %s", string(val.Error))
	}

	// Check for result
	if len(val.Result) == 0 {
		return nil, fmt.Errorf("JSON-RPC call failed: no result")
	}

	return val.Result, nil
}

// Submit work. Nil means accepted block, non-nil means rejected block with error message.
func (m *Miner) submitUpstreamWork(ctx context.Context, work *Work) (*string, error) {
	if work.Txs == "" {
		return nil, fmt.Errorf("no transactions to submit")
	}

	header := work.blockHeader()

	var headerBytes bytes.Buffer
	if err := header.Serialize(&headerBytes); err != nil {
		return nil, fmt.Errorf("serialize block header: %w", err)
	}

	params := []any{
		hex.EncodeToString(headerBytes.Bytes()) + work.Txs,
	}

	if work.WorkID != "" {
		params = append(params, map[string]string{"workid": work.WorkID})
	}

	zerolog.Ctx(ctx).Debug().
		Msgf("Submitting work with nonce %d: %s", header.Nonce, params[0])

	val, err := m.jsonRpcCall(ctx, "submitblock", params)
	if err != nil {
		return nil, err
	}

	// Result is a string (error message)
	if len(val) > 0 && string(val) != "null" {
		var reason string
		if err := json.Unmarshal(val, &reason); err != nil {
			return nil, fmt.Errorf("unmarshal submitblock response: %w", err)
		}
		return &reason, nil
	}

	zerolog.Ctx(ctx).Info().Msg("Block accepted!")
	select {
	case m.acceptedBlocks <- header.BlockHash():
	default:
		zerolog.Ctx(ctx).Warn().Msg("Block accepted, but channel is full")
	}

	_, err = m.getNewWork(ctx)
	if err != nil {
		return nil, fmt.Errorf("fetch new work post block accepted: %w", err)
	}

	return nil, nil
}
