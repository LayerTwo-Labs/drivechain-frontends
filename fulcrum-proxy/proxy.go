package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strconv"
	"strings"
)

const (
	ecashPrefix    = "/eCash "
	maxRequestBody = 64 << 20
)

type networkInfoKey struct{}

// newProxy forwards every call to target. It rewrites only the reply to a
// getnetworkinfo call, so block replies stream through untouched.
func newProxy(target *url.URL) http.Handler {
	proxy := &httputil.ReverseProxy{
		Rewrite: func(r *httputil.ProxyRequest) {
			r.SetURL(target)
		},
		ModifyResponse: func(resp *http.Response) error {
			if resp.Request.Context().Value(networkInfoKey{}) == nil {
				return nil
			}
			body, err := io.ReadAll(resp.Body)
			if err != nil {
				return fmt.Errorf("read getnetworkinfo reply: %w", err)
			}
			if err := resp.Body.Close(); err != nil {
				return fmt.Errorf("close getnetworkinfo reply: %w", err)
			}
			rewritten, err := rewriteSubversion(body)
			if err != nil {
				return err
			}
			resp.Body = io.NopCloser(bytes.NewReader(rewritten))
			resp.ContentLength = int64(len(rewritten))
			resp.Header.Set("Content-Length", strconv.Itoa(len(rewritten)))
			return nil
		},
	}

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		body, err := io.ReadAll(io.LimitReader(r.Body, maxRequestBody))
		if err != nil {
			http.Error(w, fmt.Sprintf("read request: %v", err), http.StatusBadRequest)
			return
		}
		r.Body = io.NopCloser(bytes.NewReader(body))
		if bytes.Contains(body, []byte(`"getnetworkinfo"`)) {
			r = r.WithContext(context.WithValue(r.Context(), networkInfoKey{}, true))
		}
		proxy.ServeHTTP(w, r)
	})
}

// rewriteSubversion turns "/eCash Satoshi:31.1.0/" into "/Satoshi:31.1.0/" in a
// JSON-RPC reply or a batch of replies. A reply with no eCash user agent comes
// back unchanged.
func rewriteSubversion(body []byte) ([]byte, error) {
	trimmed := bytes.TrimSpace(body)
	if len(trimmed) > 0 && trimmed[0] == '[' {
		var replies []map[string]json.RawMessage
		if err := json.Unmarshal(trimmed, &replies); err != nil {
			return nil, fmt.Errorf("decode batch reply: %w", err)
		}
		changed := false
		for _, reply := range replies {
			ok, err := rewriteReply(reply)
			if err != nil {
				return nil, err
			}
			changed = changed || ok
		}
		if !changed {
			return body, nil
		}
		return json.Marshal(replies)
	}

	var reply map[string]json.RawMessage
	if err := json.Unmarshal(trimmed, &reply); err != nil {
		return nil, fmt.Errorf("decode reply: %w", err)
	}
	changed, err := rewriteReply(reply)
	if err != nil || !changed {
		return body, err
	}
	return json.Marshal(reply)
}

func rewriteReply(reply map[string]json.RawMessage) (bool, error) {
	raw := bytes.TrimSpace(reply["result"])
	if len(raw) == 0 || raw[0] != '{' {
		return false, nil
	}
	var result map[string]json.RawMessage
	if err := json.Unmarshal(raw, &result); err != nil {
		return false, fmt.Errorf("decode result: %w", err)
	}
	var subversion string
	if err := json.Unmarshal(result["subversion"], &subversion); err != nil || !strings.HasPrefix(subversion, ecashPrefix) {
		return false, nil
	}
	encoded, err := json.Marshal("/" + strings.TrimPrefix(subversion, ecashPrefix))
	if err != nil {
		return false, fmt.Errorf("encode subversion: %w", err)
	}
	result["subversion"] = encoded
	rewritten, err := json.Marshal(result)
	if err != nil {
		return false, fmt.Errorf("encode result: %w", err)
	}
	reply["result"] = rewritten
	return true, nil
}
