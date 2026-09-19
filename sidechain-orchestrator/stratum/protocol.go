package stratum

import (
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math"
	"strconv"
)

// Stratum v1 error codes.
const (
	codeOther        = 20
	codeJobNotFound  = 21
	codeDuplicate    = 22
	codeLowDiff      = 23
	codeUnauthorized = 24
	codeNotSubscribe = 25
)

type message struct {
	ID     json.RawMessage `json:"id"`
	Method string          `json:"method,omitempty"`
	Params json.RawMessage `json:"params,omitempty"`
	Result json.RawMessage `json:"result,omitempty"`
	Error  json.RawMessage `json:"error,omitempty"`
}

type stratumError struct {
	code int
	msg  string
}

func (e *stratumError) Error() string { return fmt.Sprintf("stratum error %d: %s", e.code, e.msg) }

func rejectf(code int, format string, args ...any) *stratumError {
	return &stratumError{code: code, msg: fmt.Sprintf(format, args...)}
}

func encodeLine(v any) ([]byte, error) {
	b, err := json.Marshal(v)
	if err != nil {
		return nil, err
	}
	return append(b, '\n'), nil
}

func responseLine(id json.RawMessage, result any, rpcErr *stratumError) ([]byte, error) {
	if len(id) == 0 {
		id = json.RawMessage("null")
	}
	resp := map[string]any{"id": id, "result": result, "error": nil}
	if rpcErr != nil {
		resp["result"] = nil
		resp["error"] = []any{rpcErr.code, rpcErr.msg, nil}
	}
	return encodeLine(resp)
}

func notificationLine(method string, params []any) ([]byte, error) {
	return encodeLine(map[string]any{"id": nil, "method": method, "params": params})
}

// replyError reads the error member of a reply. Pools send it as
// [code, message, traceback], as an object, or as a string.
func replyError(raw json.RawMessage) error {
	if len(raw) == 0 || string(raw) == "null" {
		return nil
	}
	var list []any
	if err := json.Unmarshal(raw, &list); err == nil && len(list) >= 2 {
		code, _ := list[0].(float64)
		msg, _ := list[1].(string)
		return rejectf(int(code), "%s", msg)
	}
	var obj struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	}
	if err := json.Unmarshal(raw, &obj); err == nil && obj.Message != "" {
		return rejectf(obj.Code, "%s", obj.Message)
	}
	return rejectf(codeOther, "%s", string(raw))
}

func notifyParams(id string, w *Work, clean bool) []any {
	branch := make([]string, len(w.Branch))
	for i, h := range w.Branch {
		branch[i] = hex.EncodeToString(h[:])
	}
	return []any{
		id,
		hex.EncodeToString(stratumPrevHash(w.PrevHash)),
		hex.EncodeToString(w.Coinb1),
		hex.EncodeToString(w.Coinb2),
		branch,
		fmt.Sprintf("%08x", uint32(w.Version)),
		fmt.Sprintf("%08x", w.Bits),
		fmt.Sprintf("%08x", w.Time),
		clean,
	}
}

// parseHex32 reads a big-endian 32-bit hex field such as ntime or nonce.
func parseHex32(s string) (uint32, error) {
	b, err := hex.DecodeString(s)
	if err != nil || len(b) != 4 {
		return 0, fmt.Errorf("%q is not 8 hex digits", s)
	}
	return binary.BigEndian.Uint32(b), nil
}

func stringParams(raw json.RawMessage) ([]string, error) {
	var list []json.RawMessage
	if err := json.Unmarshal(raw, &list); err != nil {
		return nil, fmt.Errorf("params are not a list: %w", err)
	}
	out := make([]string, len(list))
	for i, item := range list {
		var s string
		if err := json.Unmarshal(item, &s); err != nil {
			var n json.Number
			if err := json.Unmarshal(item, &n); err != nil {
				return nil, fmt.Errorf("param %d is not a string", i)
			}
			s = n.String()
		}
		out[i] = s
	}
	return out, nil
}

func parseDifficulty(raw json.RawMessage) (float64, error) {
	var list []json.RawMessage
	if err := json.Unmarshal(raw, &list); err != nil || len(list) == 0 {
		return 0, fmt.Errorf("difficulty params %s", raw)
	}
	var d float64
	if err := json.Unmarshal(list[0], &d); err != nil {
		var s string
		if err := json.Unmarshal(list[0], &s); err != nil {
			return 0, fmt.Errorf("difficulty %s is not a number", list[0])
		}
		parsed, err := strconv.ParseFloat(s, 64)
		if err != nil {
			return 0, fmt.Errorf("difficulty %q: %w", s, err)
		}
		d = parsed
	}
	if math.IsNaN(d) || math.IsInf(d, 0) || d <= 0 {
		return 0, fmt.Errorf("difficulty %v is not a positive number", d)
	}
	return d, nil
}
