package main

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
)

const networkInfoReply = `{"result":{"version":310100,"subversion":"/eCash Satoshi:31.1.0/","protocolversion":70016},"error":null,"id":11}`

func subversionOf(t *testing.T, body []byte) string {
	t.Helper()
	var reply struct {
		Result struct {
			Subversion string `json:"subversion"`
		} `json:"result"`
	}
	if err := json.Unmarshal(body, &reply); err != nil {
		t.Fatalf("decode %s: %v", body, err)
	}
	return reply.Result.Subversion
}

func TestRewriteSubversion(t *testing.T) {
	got, err := rewriteSubversion([]byte(networkInfoReply))
	if err != nil {
		t.Fatal(err)
	}
	if sub := subversionOf(t, got); sub != "/Satoshi:31.1.0/" {
		t.Fatalf("subversion = %q, want /Satoshi:31.1.0/", sub)
	}
	if !strings.Contains(string(got), `"protocolversion":70016`) {
		t.Fatalf("lost a field: %s", got)
	}
}

func TestRewriteSubversionInABatch(t *testing.T) {
	got, err := rewriteSubversion([]byte(`[` + networkInfoReply + `,{"result":5,"error":null,"id":12}]`))
	if err != nil {
		t.Fatal(err)
	}
	var replies []json.RawMessage
	if err := json.Unmarshal(got, &replies); err != nil {
		t.Fatal(err)
	}
	if sub := subversionOf(t, replies[0]); sub != "/Satoshi:31.1.0/" {
		t.Fatalf("subversion = %q", sub)
	}
}

func TestRewriteSubversionKeepsOtherReplies(t *testing.T) {
	for _, body := range []string{
		`{"result":{"subversion":"/Satoshi:29.0.0/"},"error":null,"id":1}`,
		`{"result":null,"error":{"code":-32601,"message":"Method not found"},"id":1}`,
		`{"result":"00ab","error":null,"id":1}`,
		`{"result":{"blocks":5},"error":null,"id":1}`,
	} {
		got, err := rewriteSubversion([]byte(body))
		if err != nil {
			t.Fatalf("%s: %v", body, err)
		}
		if string(got) != body {
			t.Fatalf("changed %s to %s", body, got)
		}
	}
}

func TestProxyRewritesOnlyNetworkInfo(t *testing.T) {
	var gotAuth string
	node := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotAuth = r.Header.Get("Authorization")
		body, _ := io.ReadAll(r.Body)
		if strings.Contains(string(body), "getnetworkinfo") {
			_, _ = io.WriteString(w, networkInfoReply)
			return
		}
		_, _ = io.WriteString(w, `{"result":{"subversion":"/eCash Satoshi:31.1.0/"},"error":null,"id":2}`)
	}))
	defer node.Close()

	target, err := url.Parse(node.URL)
	if err != nil {
		t.Fatal(err)
	}
	proxy := httptest.NewServer(newProxy(target))
	defer proxy.Close()

	call := func(method string) []byte {
		t.Helper()
		req, err := http.NewRequest(http.MethodPost, proxy.URL, strings.NewReader(`{"method":"`+method+`","params":[],"id":1}`))
		if err != nil {
			t.Fatal(err)
		}
		req.SetBasicAuth("__cookie__", "secret")
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatal(err)
		}
		defer resp.Body.Close() //nolint:errcheck // test cleanup
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			t.Fatal(err)
		}
		return body
	}

	if sub := subversionOf(t, call("getnetworkinfo")); sub != "/Satoshi:31.1.0/" {
		t.Fatalf("getnetworkinfo subversion = %q", sub)
	}
	if gotAuth == "" {
		t.Fatal("the proxy dropped the Authorization header")
	}
	if sub := subversionOf(t, call("getpeerinfo")); sub != "/eCash Satoshi:31.1.0/" {
		t.Fatalf("getpeerinfo subversion = %q, want it untouched", sub)
	}
}
