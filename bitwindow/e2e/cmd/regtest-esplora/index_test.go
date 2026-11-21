package main

import (
	"encoding/json"
	"testing"
)

const (
	alice = "bcrt1qalice"
	bob   = "bcrt1qbob"
)

func coreTxJSON(t *testing.T, raw string) coreTx {
	t.Helper()
	var ct coreTx
	if err := json.Unmarshal([]byte(raw), &ct); err != nil {
		t.Fatal(err)
	}
	return ct
}

func TestSatsReadsCoreAmounts(t *testing.T) {
	for in, want := range map[string]int64{"50.00000000": 5_000_000_000, "0.0002": 20_000, "1": 100_000_000, "-0.00000141": -141, "": 0} {
		got, err := sats(json.Number(in))
		if err != nil || got != want {
			t.Errorf("sats(%q) = %d, %v; want %d", in, got, err, want)
		}
	}
	for _, bad := range []string{"0.000000001", "1e8"} {
		if _, err := sats(json.Number(bad)); err == nil {
			t.Errorf("sats(%q) took a bad amount", bad)
		}
	}
}

func TestIndexTracksFundsAndSpends(t *testing.T) {
	coinbase := coreTxJSON(t, `{"txid":"aa","vin":[{"coinbase":"51"}],
		"vout":[{"value":50,"n":0,"scriptPubKey":{"hex":"0014a1","type":"witness_v0_keyhash","address":"`+alice+`"}}]}`)
	pay := coreTxJSON(t, `{"txid":"bb","fee":0.00000141,"vin":[{"txid":"aa","vout":0,
		"prevout":{"value":50,"scriptPubKey":{"hex":"0014a1","type":"witness_v0_keyhash","address":"`+alice+`"}}}],
		"vout":[{"value":1.5,"n":0,"scriptPubKey":{"hex":"0014b0","type":"witness_v0_keyhash","address":"`+bob+`"}},
		        {"value":48.49999859,"n":1,"scriptPubKey":{"hex":"0014a1","type":"witness_v0_keyhash","address":"`+alice+`"}}]}`)

	st := emptyState()
	if err := st.addBlock(coreBlock{Hash: "h0", Height: 0, Time: 100, Tx: []coreTx{coinbase}}); err != nil {
		t.Fatal(err)
	}
	unconfirmed, err := convertTx(pay)
	if err != nil {
		t.Fatal(err)
	}
	st.add(unconfirmed)

	chainStats, mempoolStats := st.addressStats(alice)
	if chainStats.FundedTxoSum != 5_000_000_000 || chainStats.TxCount != 1 {
		t.Errorf("alice chain stats = %+v", chainStats)
	}
	if mempoolStats.SpentTxoSum != 5_000_000_000 || mempoolStats.FundedTxoSum != 4_849_999_859 || mempoolStats.TxCount != 1 {
		t.Errorf("alice mempool stats = %+v", mempoolStats)
	}
	utxos := st.addressUTXOs(alice)
	if len(utxos) != 1 || utxos[0].TxID != "bb" || utxos[0].Vout != 1 || utxos[0].Status.Confirmed {
		t.Errorf("alice utxos = %+v, want only the unconfirmed change", utxos)
	}
	mempool, chain := st.addressTxs(alice)
	if len(mempool) != 1 || mempool[0].TxID != "bb" || len(chain) != 1 || chain[0].TxID != "aa" {
		t.Errorf("alice history: mempool %v, chain %v", mempool, chain)
	}
	if got := st.txs["bb"]; got.Fee != 141 || got.Vin[0].Prevout.ScriptPubKeyType != "v0_p2wpkh" {
		t.Errorf("pay tx = %+v", got)
	}
	if !st.txs["aa"].Vin[0].IsCoinbase {
		t.Error("the coinbase input must read as a coinbase")
	}
	if spentBy := outspend(st, st.txs["aa"], 0); spentBy["txid"] != "bb" {
		t.Errorf("outspend = %v", spentBy)
	}
}

func TestMempoolPrevoutsComeFromTheIndex(t *testing.T) {
	coinbase := coreTxJSON(t, `{"txid":"aa","vin":[{"coinbase":"51"}],
		"vout":[{"value":50,"n":0,"scriptPubKey":{"hex":"0014a1","type":"witness_v0_keyhash","address":"`+alice+`"}}]}`)
	st := emptyState()
	if err := st.addBlock(coreBlock{Hash: "h0", Height: 0, Tx: []coreTx{coinbase}}); err != nil {
		t.Fatal(err)
	}
	parent, err := convertTx(coreTxJSON(t, `{"txid":"bb","vin":[{"txid":"aa","vout":0}],
		"vout":[{"value":49.9999,"n":0,"scriptPubKey":{"hex":"0014b0","type":"witness_v0_keyhash","address":"`+bob+`"}}]}`))
	if err != nil {
		t.Fatal(err)
	}
	child, err := convertTx(coreTxJSON(t, `{"txid":"cc","vin":[{"txid":"bb","vout":0}],
		"vout":[{"value":49.9998,"n":0,"scriptPubKey":{"hex":"0014a1","type":"witness_v0_keyhash","address":"`+alice+`"}}]}`))
	if err != nil {
		t.Fatal(err)
	}

	if err := fillPrevouts(st, []*tx{child, parent}); err != nil {
		t.Fatal(err)
	}

	if parent.Fee != 10_000 || parent.Vin[0].Prevout.ScriptPubKeyAddress != alice {
		t.Errorf("parent = fee %d, prevout %+v", parent.Fee, parent.Vin[0].Prevout)
	}
	if child.Fee != 10_000 || child.Vin[0].Prevout.ScriptPubKeyAddress != bob {
		t.Errorf("child = fee %d, prevout %+v", child.Fee, child.Vin[0].Prevout)
	}
	orphan, err := convertTx(coreTxJSON(t, `{"txid":"dd","vin":[{"txid":"ff","vout":0}],"vout":[]}`))
	if err != nil {
		t.Fatal(err)
	}
	if err := fillPrevouts(st, []*tx{orphan}); err == nil {
		t.Error("a spend of an unknown output must fail")
	}
}
