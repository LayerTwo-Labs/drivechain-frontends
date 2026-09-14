//go:build integration

package blockfile_test

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/blockfile"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/corewalletfile"
	_ "github.com/mattn/go-sqlite3"
	"github.com/stretchr/testify/require"
)

func TestCoreMagicMigration(t *testing.T) {
	source := os.Getenv("BITCOIND_MIGRATION_SOURCE")
	target := os.Getenv("BITCOIND_MIGRATION_TARGET")
	if source == "" || target == "" {
		t.Skip("set BITCOIND_MIGRATION_SOURCE and BITCOIND_MIGRATION_TARGET to run")
	}
	sourceMagic := os.Getenv("BITCOIND_MIGRATION_SOURCE_MAGIC")
	if sourceMagic == "" {
		sourceMagic = "eca5a134"
	}
	targetMagic := os.Getenv("BITCOIND_MIGRATION_TARGET_MAGIC")
	if targetMagic == "" {
		targetMagic = "fabfb5da"
	}
	from, err := blockfile.ParseMagic(sourceMagic)
	require.NoError(t, err)
	to, err := blockfile.ParseMagic(targetMagic)
	require.NoError(t, err)
	for _, xor := range []bool{false, true} {
		t.Run(fmt.Sprintf("xor_%t", xor), func(t *testing.T) {
			dir := t.TempDir()
			node := startMigrationCore(t, source, dir, xor)
			genesis := migrationCall[string](t, node, "getblockhash", 0)
			require.Equal(t, "0f9188f13cb7b2c71f2a335e3a4fc328bf5beb436012afca590b1a11466e2206", genesis)
			migrationCall[json.RawMessage](t, node, "createwallet", "migration", false, false, "", false, true, true)
			address := migrationCall[string](t, node, "getnewaddress")
			migrationCall[[]string](t, node, "generatetoaddress", 103, address)
			txid := migrationCall[string](t, node, "sendtoaddress", address, 1)
			common := migrationCall[[]string](t, node, "generatetoaddress", 1, address)[0]
			extra := migrationCall[[]string](t, node, "generatetoaddress", 2, address)
			migrationCall[json.RawMessage](t, node, "invalidateblock", extra[0])
			require.Equal(t, common, migrationCall[string](t, node, "getbestblockhash"))
			require.Equal(t, 104, migrationCall[int](t, node, "getblockcount"))
			state := migrationCall[migrationUTXO](t, node, "gettxoutsetinfo", "muhash")
			migrationCheckIndexes(t, node)
			transaction := migrationCall[string](t, node, "getrawtransaction", txid)
			filter := migrationCall[migrationFilter](t, node, "getblockfilter", common)
			descriptors := migrationCall[json.RawMessage](t, node, "listdescriptors", true)
			blocks := make(map[string]string)
			for height := 0; height <= 104; height++ {
				hash := migrationCall[string](t, node, "getblockhash", height)
				blocks[hash] = migrationCall[string](t, node, "getblock", hash, 0)
			}
			for _, hash := range extra {
				blocks[hash] = migrationCall[string](t, node, "getblock", hash, 0)
			}
			networkDir := filepath.Join(dir, "regtest")
			options := blockfile.Options{DataDir: networkDir, From: from, To: to}
			_, err := blockfile.Preview(context.Background(), options)
			require.ErrorContains(t, err, "cannot lock Core directory")
			node.stop(t)
			walletPath := filepath.Join(networkDir, "wallets", "migration", "wallet.dat")
			walletRows := migrationWalletRows(t, walletPath)
			files, key, records := migrationReadFiles(t, networkDir, from)
			require.Equal(t, xor, !bytes.Equal(key, make([]byte, 8)))
			_, err = blockfile.Preview(context.Background(), options)
			require.NoError(t, err)
			start := time.Now()
			if xor {
				options.Progress = func(progress blockfile.Progress) error {
					if progress.Stage == "convert" && progress.ConvertedRecords > 0 {
						return context.Canceled
					}
					return nil
				}
				partial, err := blockfile.Convert(context.Background(), options)
				require.ErrorIs(t, err, context.Canceled)
				require.Greater(t, partial.ConvertedRecords, int64(0))
				require.Less(t, partial.ConvertedRecords, partial.Records)
				options.Progress = nil
			}
			report, err := blockfile.Convert(context.Background(), options)
			require.NoError(t, err)
			t.Logf("Core conversion: %d records, %s, report %+v", records, time.Since(start), report)
			migrationCheckFiles(t, files, key, from, to)
			_, err = blockfile.Convert(context.Background(), options)
			require.NoError(t, err)
			walletReport, err := corewalletfile.Convert(context.Background(), corewalletfile.Options{
				DataDir: networkDir, From: from, To: to,
			})
			require.NoError(t, err)
			require.Equal(t, 1, walletReport.Wallets)
			require.True(t, walletReport.Complete)
			require.Equal(t, walletRows, migrationWalletRows(t, walletPath))
			migrationBackupPeers(t, networkDir)

			node = startMigrationCore(t, target, dir, xor)
			require.Zero(t, migrationCall[int](t, node, "getconnectioncount"))
			require.Equal(t, state, migrationCall[migrationUTXO](t, node, "gettxoutsetinfo", "muhash"))
			require.True(t, migrationCall[bool](t, node, "verifychain", 4, 0))
			for hash, raw := range blocks {
				require.Equal(t, raw, migrationCall[string](t, node, "getblock", hash, 0))
			}
			require.Equal(t, transaction, migrationCall[string](t, node, "getrawtransaction", txid))
			require.Equal(t, filter, migrationCall[migrationFilter](t, node, "getblockfilter", common))
			require.JSONEq(t, string(descriptors), string(migrationCall[json.RawMessage](t, node, "listdescriptors", true)))
			block := migrationCall[struct {
				Hash   string   `json:"hash"`
				Height int      `json:"height"`
				Tx     []string `json:"tx"`
			}](t, node, "getblock", common, 1)
			require.Equal(t, common, block.Hash)
			require.Equal(t, 104, block.Height)
			require.Contains(t, block.Tx, txid)
			migrationCheckIndexes(t, node)
			migrationCheckInvalid(t, node, extra[1])

			targetAddress := migrationCall[string](t, node, "getnewaddress")
			migrationCall[[]string](t, node, "generatetoaddress", 2, targetAddress)
			previousState := migrationCall[migrationUTXO](t, node, "gettxoutsetinfo", "muhash")
			endTip := migrationCall[[]string](t, node, "generatetoaddress", 1, targetAddress)[0]
			endState := migrationCall[migrationUTXO](t, node, "gettxoutsetinfo", "muhash")
			require.Equal(t, 107, endState.Height)
			migrationCall[json.RawMessage](t, node, "invalidateblock", endTip)
			require.Equal(t, previousState, migrationCall[migrationUTXO](t, node, "gettxoutsetinfo", "muhash"))
			migrationCall[json.RawMessage](t, node, "reconsiderblock", endTip)
			require.Equal(t, endState, migrationCall[migrationUTXO](t, node, "gettxoutsetinfo", "muhash"))
			migrationCheckInvalid(t, node, extra[1])
			node.stop(t)

			node = startMigrationCore(t, target, dir, xor, "-reindex=1")
			require.Eventually(t, func() bool {
				var height int
				return node.call("getblockcount", nil, &height) == nil && height == endState.Height
			}, 30*time.Second, 50*time.Millisecond)
			require.Equal(t, endState, migrationCall[migrationUTXO](t, node, "gettxoutsetinfo", "muhash"))
			require.True(t, migrationCall[bool](t, node, "verifychain", 4, 0))
			migrationCheckIndexes(t, node)
			require.Equal(t, transaction, migrationCall[string](t, node, "getrawtransaction", txid))
			require.Equal(t, filter, migrationCall[migrationFilter](t, node, "getblockfilter", common))
			node.stop(t)
		})
	}
}

type migrationUTXO struct {
	Height      int     `json:"height"`
	BestBlock   string  `json:"bestblock"`
	TxOuts      int     `json:"txouts"`
	MuHash      string  `json:"muhash"`
	TotalAmount float64 `json:"total_amount"`
}

type migrationFilter struct {
	Filter string `json:"filter"`
	Header string `json:"header"`
}

type migrationCore struct {
	url    string
	client *http.Client
	cmd    *exec.Cmd
	done   chan error
}

func startMigrationCore(t *testing.T, path, dir string, xor bool, extra ...string) *migrationCore {
	t.Helper()
	port, err := net.Listen("tcp4", "127.0.0.1:0")
	require.NoError(t, err)
	address := port.Addr().String()
	_, number, err := net.SplitHostPort(address)
	require.NoError(t, err)
	require.NoError(t, port.Close())
	xorFlag := "0"
	if xor {
		xorFlag = "1"
	}
	args := []string{
		"-regtest", "-datadir=" + dir, "-server=1", "-daemon=0", "-printtoconsole=0",
		"-listen=0", "-connect=0", "-dnsseed=0", "-discover=0", "-networkactive=0",
		"-rpcbind=127.0.0.1", "-rpcport=" + number, "-rpcuser=migration", "-rpcpassword=migration",
		"-txindex=1", "-blockfilterindex=1", "-fallbackfee=0.0001", "-persistmempool=0",
		"-blocksxor=" + xorFlag,
	}
	args = append(args, extra...)
	log, err := os.OpenFile(filepath.Join(dir, "process.log"), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0600)
	require.NoError(t, err)
	node := &migrationCore{
		url: "http://" + address, client: &http.Client{Timeout: 30 * time.Second},
		cmd: exec.Command(path, args...), done: make(chan error, 1),
	}
	node.cmd.Stdout = log
	node.cmd.Stderr = log
	require.NoError(t, node.cmd.Start())
	require.NoError(t, log.Close())
	go func() { node.done <- node.cmd.Wait() }()
	t.Cleanup(func() { node.stop(t) })
	deadline := time.Now().Add(30 * time.Second)
	for time.Now().Before(deadline) {
		select {
		case err := <-node.done:
			node.cmd = nil
			log, readErr := os.ReadFile(filepath.Join(dir, "process.log"))
			require.NoError(t, readErr)
			t.Fatalf("Core exit: %v\n%s", err, log)
		default:
		}
		var height int
		if node.call("getblockcount", nil, &height) == nil {
			return node
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatal("Core RPC did not start")
	return nil
}

func (node *migrationCore) stop(t *testing.T) {
	t.Helper()
	if node.cmd == nil {
		return
	}
	var result json.RawMessage
	err := node.call("stop", nil, &result)
	if err != nil {
		require.NoError(t, node.cmd.Process.Kill())
		processErr := <-node.done
		node.cmd = nil
		t.Fatalf("Core stop failed: %v; process exit: %v", err, processErr)
	}
	select {
	case err := <-node.done:
		node.cmd = nil
		require.NoError(t, err)
	case <-time.After(30 * time.Second):
		require.NoError(t, node.cmd.Process.Kill())
		processErr := <-node.done
		node.cmd = nil
		t.Fatalf("Core did not stop: %v", processErr)
	}
}

func (node *migrationCore) call(method string, params []any, result any) error {
	if params == nil {
		params = []any{}
	}
	data, err := json.Marshal(map[string]any{"jsonrpc": "2.0", "id": 1, "method": method, "params": params})
	if err != nil {
		return err
	}
	request, err := http.NewRequest(http.MethodPost, node.url, bytes.NewReader(data))
	if err != nil {
		return err
	}
	request.SetBasicAuth("migration", "migration")
	request.Header.Set("Content-Type", "application/json")
	response, err := node.client.Do(request)
	if err != nil {
		return err
	}
	body, readErr := io.ReadAll(response.Body)
	closeErr := response.Body.Close()
	if readErr != nil {
		return readErr
	}
	if closeErr != nil {
		return closeErr
	}
	var reply struct {
		Result json.RawMessage `json:"result"`
		Error  *struct {
			Code    int    `json:"code"`
			Message string `json:"message"`
		} `json:"error"`
	}
	if err := json.Unmarshal(body, &reply); err != nil {
		return fmt.Errorf("%s: decode RPC reply: %w", method, err)
	}
	if reply.Error != nil {
		return fmt.Errorf("%s: RPC %d: %s", method, reply.Error.Code, reply.Error.Message)
	}
	return json.Unmarshal(reply.Result, result)
}

func migrationCall[T any](t *testing.T, node *migrationCore, method string, params ...any) T {
	t.Helper()
	var result T
	require.NoError(t, node.call(method, params, &result), method)
	return result
}

func migrationCheckIndexes(t *testing.T, node *migrationCore) {
	t.Helper()
	require.Eventually(t, func() bool {
		var indexes map[string]struct {
			Synced bool `json:"synced"`
		}
		if node.call("getindexinfo", nil, &indexes) != nil {
			return false
		}
		return len(indexes) == 2 && indexes["txindex"].Synced && indexes["basic block filter index"].Synced
	}, 30*time.Second, 50*time.Millisecond)
}

func migrationCheckInvalid(t *testing.T, node *migrationCore, hash string) {
	t.Helper()
	tips := migrationCall[[]struct {
		Hash   string `json:"hash"`
		Status string `json:"status"`
	}](t, node, "getchaintips")
	for _, tip := range tips {
		if tip.Hash == hash {
			require.Equal(t, "invalid", tip.Status)
			return
		}
	}
	t.Fatalf("Core omitted the old branch: %s", hash)
}

func migrationReadFiles(t *testing.T, dir string, magic blockfile.Magic) (map[string][]byte, []byte, int) {
	t.Helper()
	key, err := os.ReadFile(filepath.Join(dir, "blocks", "xor.dat"))
	require.NoError(t, err)
	require.Len(t, key, 8)
	files := make(map[string][]byte)
	records := 0
	for _, prefix := range []string{"blk", "rev"} {
		paths, err := filepath.Glob(filepath.Join(dir, "blocks", prefix+"*.dat"))
		require.NoError(t, err)
		require.NotEmpty(t, paths)
		for _, path := range paths {
			data, err := os.ReadFile(path)
			require.NoError(t, err)
			files[path] = data
			records += len(migrationRecordOffsets(t, path, data, key, magic))
		}
	}
	return files, key, records
}

func migrationRecordOffsets(t *testing.T, path string, data, key []byte, magic blockfile.Magic) []int {
	t.Helper()
	plain := bytes.Clone(data)
	for index := range plain {
		plain[index] ^= key[index%len(key)]
	}
	var offsets []int
	for offset := 0; offset < len(plain); {
		require.GreaterOrEqual(t, len(plain)-offset, 8, path)
		if bytes.Equal(data[offset:offset+8], make([]byte, 8)) {
			require.Equal(t, make([]byte, len(data)-offset), data[offset:], path)
			break
		}
		require.Equal(t, magic[:], plain[offset:offset+4], "%s at %d", path, offset)
		size := int(binary.LittleEndian.Uint32(plain[offset+4 : offset+8]))
		if strings.HasPrefix(filepath.Base(path), "rev") {
			size += 32
		}
		require.LessOrEqual(t, offset+8+size, len(plain), path)
		offsets = append(offsets, offset)
		offset += 8 + size
	}
	return offsets
}

func migrationCheckFiles(t *testing.T, files map[string][]byte, key []byte, from, to blockfile.Magic) {
	t.Helper()
	for path, original := range files {
		want := bytes.Clone(original)
		for _, offset := range migrationRecordOffsets(t, path, original, key, from) {
			for index := range to {
				want[offset+index] = to[index] ^ key[(offset+index)%len(key)]
			}
		}
		got, err := os.ReadFile(path)
		require.NoError(t, err)
		require.Equal(t, want, got, path)
	}
}

func migrationBackupPeers(t *testing.T, dir string) {
	t.Helper()
	backup := filepath.Join(dir, "peer-backup")
	require.NoError(t, os.Mkdir(backup, 0700))
	for _, name := range []string{"peers.dat", "anchors.dat", "mempool.dat"} {
		path := filepath.Join(dir, name)
		_, err := os.Stat(path)
		if os.IsNotExist(err) {
			continue
		}
		require.NoError(t, err)
		require.NoError(t, os.Rename(path, filepath.Join(backup, name)))
	}
}

func migrationWalletRows(t *testing.T, path string) map[string]string {
	t.Helper()
	fileURL := url.URL{Scheme: "file", Path: path, RawQuery: "mode=ro"}
	db, err := sql.Open("sqlite3", fileURL.String())
	require.NoError(t, err)
	defer func() { require.NoError(t, db.Close()) }()
	rows, err := db.Query("SELECT hex(key), hex(value) FROM main ORDER BY key")
	require.NoError(t, err)
	defer func() { require.NoError(t, rows.Close()) }()
	values := make(map[string]string)
	for rows.Next() {
		var key, value string
		require.NoError(t, rows.Scan(&key, &value))
		values[key] = value
	}
	require.NoError(t, rows.Err())
	require.NotEmpty(t, values)
	return values
}
