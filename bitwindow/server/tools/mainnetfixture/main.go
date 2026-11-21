// Command mainnetfixture fills a regtest node with mainnet-sized blocks,
// wallet history and mempool, so BitWindow can be measured at that scale.
//
// It spends anyone-can-spend outputs, so it builds transactions with no keys
// and submits them in JSON-RPC batches.
package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"math/rand/v2"
	"os"
	"os/signal"
	"sort"
	"sync"
	"syscall"
	"time"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
)

const opTrueDescriptor = "raw(51)#8lvh9jxk"

var (
	witnessTrue = []byte{txscript.OP_TRUE}
	poolScript  = func() []byte {
		h := sha256.Sum256(witnessTrue)
		return append([]byte{txscript.OP_0, 0x20}, h[:]...)
	}()
)

type coin struct {
	op    wire.OutPoint
	value int64
	// bare is an OP_TRUE coinbase output. It spends with an empty script and no witness.
	bare bool
}

type payee struct {
	script []byte
	sats   int64
}

type fixture struct {
	rpc  *rpcClient
	rng  *rand.Rand
	pool []coin

	topics []codec.Topic
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: mainnetfixture build|mempool [flags]")
		os.Exit(2)
	}
	var err error
	switch os.Args[1] {
	case "build":
		err = runBuild(os.Args[2:])
	case "mempool":
		err = runMempool(os.Args[2:])
	default:
		err = fmt.Errorf("unknown command %q", os.Args[1])
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "mainnetfixture:", err)
		os.Exit(1)
	}
}

func commonFlags(fs *flag.FlagSet) (*string, *string, *uint64) {
	url := fs.String("rpc", "", "Core RPC URL, such as http://127.0.0.1:18443")
	cookie := fs.String("cookie", "", "Core .cookie file")
	seed := fs.Uint64("seed", 1, "random seed")
	return url, cookie, seed
}

func runBuild(args []string) error {
	fs := flag.NewFlagSet("build", flag.ExitOnError)
	url, cookie, seed := commonFlags(fs)
	rounds := fs.Int("blocks", 300, "blocks to fill")
	heavyShare := fs.Float64("heavy-share", 0.6, "share of blocks with 2000+ transactions")
	appWallet := fs.String("app-wallet", "", "Core wallet of the app wallet")
	secondWallet := fs.String("second-wallet", "", "Core wallet of the second app wallet")
	watchSource := fs.String("watch-source", "", "Core wallet whose addresses the watch-only wallet watches")
	_ = fs.Parse(args)
	if *appWallet == "" || *secondWallet == "" || *watchSource == "" {
		return errors.New("give -app-wallet, -second-wallet and -watch-source")
	}
	rpc, err := newRPCClient(*url, *cookie)
	if err != nil {
		return err
	}
	f := &fixture{rpc: rpc, rng: rand.New(rand.NewPCG(*seed, 7))}
	start := time.Now()

	appAddrs, err := f.newAddresses(*appWallet, 6000)
	if err != nil {
		return err
	}
	secondAddrs, err := f.newAddresses(*secondWallet, 400)
	if err != nil {
		return err
	}
	watchAddrs, err := f.newAddresses(*watchSource, 400)
	if err != nil {
		return err
	}

	if err := f.seedPool(20, 200); err != nil {
		return err
	}
	f.topics = make([]codec.Topic, 6)
	for i := range f.topics {
		copy(f.topics[i][:], fmt.Sprintf("fx%02d", i))
	}

	usedApp := 0
	for r := 0; r < *rounds; r++ {
		heavy := f.rng.Float64() < *heavyShare
		n := 60 + f.rng.IntN(240)
		if heavy {
			n = 2000 + f.rng.IntN(600)
		}
		receives := map[int]payee{}
		addReceive := func(k int, pick func() string) error {
			for range min(k, n-len(receives)) {
				script, err := addressScript(pick())
				if err != nil {
					return err
				}
				i := f.rng.IntN(n)
				for receives[i].script != nil {
					i = f.rng.IntN(n)
				}
				receives[i] = payee{script: script, sats: 20_000 + f.rng.Int64N(2_000_000)}
			}
			return nil
		}
		pickApp := func() string {
			if usedApp > 0 && f.rng.Float64() < 0.2 {
				return appAddrs[f.rng.IntN(usedApp)]
			}
			usedApp = min(usedApp+1, len(appAddrs))
			return appAddrs[usedApp-1]
		}
		if err := addReceive(18+f.rng.IntN(13), pickApp); err != nil {
			return err
		}
		if err := addReceive(2, func() string { return secondAddrs[f.rng.IntN(len(secondAddrs))] }); err != nil {
			return err
		}
		if err := addReceive(2, func() string { return watchAddrs[f.rng.IntN(len(watchAddrs))] }); err != nil {
			return err
		}

		txs, err := f.fillers(n, 0.11, receives, r == 0)
		if err != nil {
			return fmt.Errorf("round %d: %w", r, err)
		}
		if err := f.submit(txs); err != nil {
			return fmt.Errorf("round %d: %w", r, err)
		}
		if r > 0 {
			if err := f.walletSends(*appWallet, 2+f.rng.IntN(4)); err != nil {
				return fmt.Errorf("round %d: app sends: %w", r, err)
			}
			if err := f.walletSends(*secondWallet, 1); err != nil {
				return fmt.Errorf("round %d: second wallet sends: %w", r, err)
			}
		}
		if err := f.mineAll(); err != nil {
			return fmt.Errorf("round %d: %w", r, err)
		}
		if r%10 == 0 || r == *rounds-1 {
			fmt.Printf("block %d/%d: %d txs, pool %d coins, %s\n", r+1, *rounds, len(txs), len(f.pool), time.Since(start).Round(time.Second))
		}
	}
	return nil
}

func runMempool(args []string) error {
	fs := flag.NewFlagSet("mempool", flag.ExitOnError)
	url, cookie, seed := commonFlags(fs)
	count := fs.Int("count", 25000, "transactions to add to the mempool")
	churn := fs.Float64("churn", 0, "transactions per second to add after the fill, until a signal stops it")
	appWallet := fs.String("app-wallet", "", "Core wallet that gets a few unconfirmed receives")
	reserve := fs.Int("reserve", 6000, "confirmed coins that the fill leaves for a later churn")
	_ = fs.Parse(args)
	rpc, err := newRPCClient(*url, *cookie)
	if err != nil {
		return err
	}
	f := &fixture{rpc: rpc, rng: rand.New(rand.NewPCG(*seed, 11))}
	f.topics = []codec.Topic{{'f', 'x', '0', '0'}, {'f', 'x', '0', '1'}}
	if err := f.scanPool(); err != nil {
		return err
	}
	// Each tx makes a new pool coin, so half the fill can spend unconfirmed coins.
	need := *count/2 + int(*churn*1800) + 1
	if err := f.dropMempoolSpent(need); err != nil {
		return err
	}
	var reserved []coin
	if *count > 0 {
		keep := min(*reserve, len(f.pool)-*count/2)
		reserved, f.pool = f.pool[:keep], f.pool[keep:]
	}
	receives := map[int]payee{}
	if *appWallet != "" && *count > 0 {
		addrs, err := f.newAddresses(*appWallet, 5)
		if err != nil {
			return err
		}
		for _, a := range addrs {
			script, err := addressScript(a)
			if err != nil {
				return err
			}
			receives[f.rng.IntN(*count)] = payee{script: script, sats: 100_000 + f.rng.Int64N(1_000_000)}
		}
	}
	start := time.Now()
	for done := 0; done < *count; done += 5000 {
		n := min(5000, *count-done)
		part := map[int]payee{}
		for i, p := range receives {
			if i >= done && i < done+n {
				part[i-done] = p
			}
		}
		txs, err := f.fillers(n, 0.1, part, false)
		if err != nil {
			return err
		}
		if err := f.submit(txs); err != nil {
			return err
		}
	}
	var info struct {
		Size  int   `json:"size"`
		Bytes int64 `json:"bytes"`
	}
	if err := rpc.callInto(&info, "getmempoolinfo"); err != nil {
		return err
	}
	fmt.Printf("mempool: %d txs, %d vbytes, filled in %s\n", info.Size, info.Bytes, time.Since(start).Round(time.Millisecond))
	if *churn <= 0 {
		return nil
	}
	f.pool = append(f.pool, reserved...)

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	tick := time.NewTicker(time.Duration(float64(time.Second) / *churn))
	defer tick.Stop()
	sent := 0
	for {
		select {
		case <-stop:
			fmt.Printf("churn: %d txs\n", sent)
			return nil
		case <-tick.C:
		}
		if len(f.pool) == 0 {
			return fmt.Errorf("churn: pool is empty after %d txs", sent)
		}
		txs, err := f.fillers(1, 0.1, nil, false)
		if err != nil {
			return err
		}
		if err := f.submit(txs); err != nil {
			return err
		}
		sent++
	}
}

func (f *fixture) newAddresses(wallet string, n int) ([]string, error) {
	calls := make([]rpcCall, n)
	for i := range calls {
		calls[i] = rpcCall{Method: "getnewaddress"}
	}
	res, err := f.rpc.batch(wallet, calls)
	if err != nil {
		return nil, fmt.Errorf("addresses of %s: %w", wallet, err)
	}
	out := make([]string, n)
	for i, r := range res {
		if err := json.Unmarshal(r, &out[i]); err != nil {
			return nil, err
		}
	}
	return out, nil
}

func addressScript(address string) ([]byte, error) {
	addr, err := btcutil.DecodeAddress(address, &chaincfg.RegressionNetParams)
	if err != nil {
		return nil, fmt.Errorf("decode %s: %w", address, err)
	}
	return txscript.PayToAddrScript(addr)
}

// seedPool mines coinbases to OP_TRUE, then splits each mature one into pool coins.
func (f *fixture) seedPool(coinbases, split int) error {
	var hashes []string
	if err := f.rpc.callInto(&hashes, "generatetodescriptor", coinbases+100, opTrueDescriptor); err != nil {
		return fmt.Errorf("mine seed blocks: %w", err)
	}
	var txs []*wire.MsgTx
	for _, h := range hashes[:coinbases] {
		var block struct {
			Tx []struct {
				Txid string `json:"txid"`
				Vout []struct {
					Value float64 `json:"value"`
					N     uint32  `json:"n"`
				} `json:"vout"`
			} `json:"tx"`
		}
		if err := f.rpc.callInto(&block, "getblock", h, 2); err != nil {
			return err
		}
		cb := block.Tx[0]
		hash, err := chainhash.NewHashFromStr(cb.Txid)
		if err != nil {
			return err
		}
		in := coin{op: wire.OutPoint{Hash: *hash, Index: cb.Vout[0].N}, value: btcToSats(cb.Vout[0].Value), bare: true}
		tx := wire.NewMsgTx(2)
		addInput(tx, in)
		each := (in.value - 100_000) / int64(split)
		for range split {
			tx.AddTxOut(wire.NewTxOut(each, poolScript))
		}
		hash = new(chainhash.Hash)
		*hash = tx.TxHash()
		for i := range split {
			f.pool = append(f.pool, coin{op: wire.OutPoint{Hash: *hash, Index: uint32(i)}, value: each})
		}
		txs = append(txs, tx)
	}
	if err := f.submit(txs); err != nil {
		return err
	}
	return f.mineAll()
}

// scanPool reads the confirmed pool coins from the UTXO set.
func (f *fixture) scanPool() error {
	var res struct {
		Unspents []struct {
			Txid   string  `json:"txid"`
			Vout   uint32  `json:"vout"`
			Amount float64 `json:"amount"`
		} `json:"unspents"`
	}
	desc := "raw(" + hex.EncodeToString(poolScript) + ")"
	var info struct {
		Descriptor string `json:"descriptor"`
	}
	if err := f.rpc.callInto(&info, "getdescriptorinfo", desc); err != nil {
		return err
	}
	if err := f.rpc.callInto(&res, "scantxoutset", "start", []string{info.Descriptor}); err != nil {
		return fmt.Errorf("scan pool: %w", err)
	}
	for _, u := range res.Unspents {
		hash, err := chainhash.NewHashFromStr(u.Txid)
		if err != nil {
			return err
		}
		if v := btcToSats(u.Amount); v > 200_000 {
			f.pool = append(f.pool, coin{op: wire.OutPoint{Hash: *hash, Index: u.Vout}, value: v})
		}
	}
	// fillers spend from the end, so the biggest coins go first.
	sort.Slice(f.pool, func(i, j int) bool { return f.pool[i].value < f.pool[j].value })
	return nil
}

// dropMempoolSpent keeps the pool coins that no mempool tx spends. It fails
// when fewer than n are left.
func (f *fixture) dropMempoolSpent(n int) error {
	calls := make([]rpcCall, len(f.pool))
	for i, c := range f.pool {
		calls[i] = rpcCall{Method: "gettxout", Params: []any{c.op.Hash.String(), c.op.Index, true}}
	}
	var keep []coin
	for at := 0; at < len(calls); at += 2000 {
		res, err := f.rpc.batch("", calls[at:min(at+2000, len(calls))])
		if err != nil {
			return err
		}
		for i, r := range res {
			if string(r) != "null" {
				keep = append(keep, f.pool[at+i])
			}
		}
	}
	if len(keep) < n {
		return fmt.Errorf("%d of %d pool coins are unspent, need %d", len(keep), len(f.pool), n)
	}
	f.pool = keep
	return nil
}

func btcToSats(v float64) int64 { return int64(v*1e8 + 0.5) }

func addInput(tx *wire.MsgTx, c coin) {
	in := wire.NewTxIn(&c.op, nil, nil)
	if !c.bare {
		in.Witness = wire.TxWitness{witnessTrue}
	}
	tx.AddTxIn(in)
}

func vsize(tx *wire.MsgTx) int64 {
	return int64((tx.SerializeSizeStripped()*3 + tx.SerializeSize() + 3) / 4)
}

// feeRate gives a sat/vB rate with the long low tail of a real mempool.
func (f *fixture) feeRate() int64 {
	switch x := f.rng.Float64(); {
	case x < 0.5:
		return 1 + f.rng.Int64N(4)
	case x < 0.85:
		return 5 + f.rng.Int64N(20)
	case x < 0.97:
		return 25 + f.rng.Int64N(75)
	default:
		return 100 + f.rng.Int64N(400)
	}
}

func (f *fixture) opReturnPayload(first bool) ([]byte, error) {
	if first {
		t := f.topics[f.rng.IntN(len(f.topics))]
		return codec.EncodeTopicCreation(codec.TopicCreation{Topic: t, RetentionDays: 30, Name: "fixture " + string(t[:])})
	}
	if f.rng.Float64() < 0.3 {
		headline := fmt.Sprintf("Fixture story %d about block space and fees", f.rng.IntN(1_000_000))
		return codec.EncodeStory(codec.Story{Topic: f.topics[f.rng.IntN(len(f.topics))], Headline: headline})
	}
	size := 8 + f.rng.IntN(73)
	if f.rng.Float64() < 0.05 {
		size = 100 + f.rng.IntN(300)
	}
	data := make([]byte, size)
	for i := range data {
		data[i] = byte(f.rng.UintN(256))
	}
	return data, nil
}

func (f *fixture) externalScript() []byte {
	if f.rng.Float64() < 0.3 {
		key := make([]byte, 32)
		for i := range key {
			key[i] = byte(f.rng.UintN(256))
		}
		return append([]byte{txscript.OP_1, 0x20}, key...)
	}
	hash := make([]byte, 20)
	for i := range hash {
		hash[i] = byte(f.rng.UintN(256))
	}
	return append([]byte{txscript.OP_0, 0x14}, hash...)
}

// fillers builds n transactions from pool coins. receives maps a tx index to
// one more output that pays a wallet. The new pool outputs join the pool.
func (f *fixture) fillers(n int, opReturnShare float64, receives map[int]payee, topicRound bool) ([]*wire.MsgTx, error) {
	txs := make([]*wire.MsgTx, 0, n)
	var created []coin
	for i := range n {
		inputs := 1
		if f.rng.Float64() < 0.08 {
			inputs = 2 + f.rng.IntN(2)
		}
		if len(f.pool) < inputs {
			return nil, fmt.Errorf("pool is empty after %d of %d txs", i, n)
		}
		tx := wire.NewMsgTx(2)
		var in int64
		for range inputs {
			c := f.pool[len(f.pool)-1]
			f.pool = f.pool[:len(f.pool)-1]
			addInput(tx, c)
			in += c.value
		}

		var out int64
		pay := func(script []byte, sats int64) {
			tx.AddTxOut(wire.NewTxOut(sats, script))
			out += sats
		}
		if p, ok := receives[i]; ok && in > p.sats+1_000_000 {
			pay(p.script, p.sats)
		}
		externals := 0
		switch x := f.rng.Float64(); {
		case x < 0.5:
			externals = 1
		case x < 0.7 && in > 2_000_000:
			externals = 2 + f.rng.IntN(19)
		}
		for range externals {
			pay(f.externalScript(), 546+f.rng.Int64N(20_000))
		}
		if f.rng.Float64() < opReturnShare || topicRound && i < len(f.topics) {
			data, err := f.opReturnPayload(topicRound && i < len(f.topics))
			if err != nil {
				return nil, err
			}
			script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddFullData(data).Script()
			if err != nil {
				return nil, err
			}
			pay(script, 0)
		}
		splits := 1
		if in-out > 4_000_000 && f.rng.Float64() < 0.35 {
			splits = 2
		}
		for range splits {
			tx.AddTxOut(wire.NewTxOut(0, poolScript))
		}
		fee := vsize(tx) * f.feeRate()
		if in-out-fee < int64(splits)*1000 {
			fee = vsize(tx)
		}
		rest := in - out - fee
		if rest < int64(splits)*1000 {
			return nil, fmt.Errorf("coin of %d sats cannot pay %d out and %d fee", in, out, fee)
		}
		base := len(tx.TxOut) - splits
		for s := range splits {
			v := rest / int64(splits)
			if s == 0 {
				v += rest % int64(splits)
			}
			tx.TxOut[base+s].Value = v
		}
		hash := tx.TxHash()
		for s := range splits {
			if v := tx.TxOut[base+s].Value; v > 200_000 {
				created = append(created, coin{op: wire.OutPoint{Hash: hash, Index: uint32(base + s)}, value: v})
			}
		}
		txs = append(txs, tx)
	}
	f.rng.Shuffle(len(created), func(i, j int) { created[i], created[j] = created[j], created[i] })
	f.pool = append(created, f.pool...)
	return txs, nil
}

// submit sends the txs in parallel batches.
func (f *fixture) submit(txs []*wire.MsgTx) error {
	const chunk = 500
	var (
		wg    sync.WaitGroup
		mu    sync.Mutex
		first error
	)
	sem := make(chan struct{}, 4)
	for at := 0; at < len(txs); at += chunk {
		part := txs[at:min(at+chunk, len(txs))]
		calls := make([]rpcCall, len(part))
		for i, tx := range part {
			var buf bytes.Buffer
			if err := tx.Serialize(&buf); err != nil {
				return err
			}
			calls[i] = rpcCall{Method: "sendrawtransaction", Params: []any{hex.EncodeToString(buf.Bytes()), 0}}
		}
		wg.Add(1)
		sem <- struct{}{}
		go func() {
			defer wg.Done()
			defer func() { <-sem }()
			if _, err := f.rpc.batch("", calls); err != nil {
				mu.Lock()
				first = cmpErr(first, err)
				mu.Unlock()
			}
		}()
	}
	wg.Wait()
	return first
}

func cmpErr(a, b error) error {
	if a != nil {
		return a
	}
	return b
}

// walletSends sends n payments from a Core wallet, some to several payees.
func (f *fixture) walletSends(wallet string, n int) error {
	calls := make([]rpcCall, n)
	for i := range calls {
		recipients := 1
		if f.rng.Float64() < 0.2 {
			recipients = 2 + f.rng.IntN(3)
		}
		outs := map[string]any{}
		for range recipients {
			addr, err := scriptAddress(f.externalScript())
			if err != nil {
				return err
			}
			outs[addr] = float64(10_000+f.rng.Int64N(1_000_000)) / 1e8
		}
		calls[i] = rpcCall{Method: "send", Params: map[string]any{"outputs": outs, "fee_rate": 1 + f.rng.IntN(20)}}
	}
	_, err := f.rpc.batch(wallet, calls)
	return err
}

func scriptAddress(script []byte) (string, error) {
	_, addrs, _, err := txscript.ExtractPkScriptAddrs(script, &chaincfg.RegressionNetParams)
	if err != nil || len(addrs) != 1 {
		return "", fmt.Errorf("no address for script %x: %v", script, err)
	}
	return addrs[0].EncodeAddress(), nil
}

// mineAll mines until the mempool is empty.
func (f *fixture) mineAll() error {
	for range 10 {
		var hashes []string
		if err := f.rpc.callInto(&hashes, "generatetodescriptor", 1, opTrueDescriptor); err != nil {
			return fmt.Errorf("mine: %w", err)
		}
		var info struct {
			Size int `json:"size"`
		}
		if err := f.rpc.callInto(&info, "getmempoolinfo"); err != nil {
			return err
		}
		if info.Size == 0 {
			return nil
		}
	}
	return errors.New("mempool still holds transactions after 10 blocks")
}
