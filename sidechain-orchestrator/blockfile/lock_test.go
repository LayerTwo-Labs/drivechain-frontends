package blockfile

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestCoreLockChild(t *testing.T) {
	path := os.Getenv("BLOCKFILE_TEST_LOCK")
	if path == "" {
		return
	}
	file, err := os.OpenFile(path, os.O_RDWR|os.O_CREATE, 0600)
	require.NoError(t, err)
	defer func() { require.NoError(t, file.Close()) }()
	require.NoError(t, takeLock(file))
	_, err = fmt.Fprintln(os.Stdout, "lock acquired")
	require.NoError(t, err)
	_, err = io.Copy(io.Discard, os.Stdin)
	require.NoError(t, err)
}

func TestCoreProcessLocks(t *testing.T) {
	for _, directory := range []string{"data", "blocks"} {
		t.Run(directory, func(t *testing.T) {
			opts := testOptions(t, [8]byte{})
			old := putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, blockPayload(t), false))
			dir := opts.DataDir
			if directory == "blocks" {
				dir = opts.BlocksDir
			}
			cmd := exec.Command(os.Args[0], "-test.run=^TestCoreLockChild$")
			cmd.Env = append(os.Environ(), "BLOCKFILE_TEST_LOCK="+filepath.Join(dir, ".lock"))
			output, err := cmd.StdoutPipe()
			require.NoError(t, err)
			input, err := cmd.StdinPipe()
			require.NoError(t, err)
			require.NoError(t, cmd.Start())
			defer func() {
				require.NoError(t, input.Close())
				require.NoError(t, cmd.Wait())
			}()
			scanner := bufio.NewScanner(output)
			require.True(t, scanner.Scan())
			require.Equal(t, "lock acquired", scanner.Text())
			_, err = Convert(context.Background(), opts)
			require.ErrorContains(t, err, "cannot lock Core directory")
			require.Equal(t, old, readData(t, opts, "blk00000.dat"))
		})
	}
}

func TestSameProcessLocks(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, blockPayload(t), false))
	opts, err := prepare(opts)
	require.NoError(t, err)
	lock, err := lockDirectories(opts.DataDir, opts.BlocksDir)
	require.NoError(t, err)
	_, err = Convert(context.Background(), opts)
	require.ErrorContains(t, err, "conversion already owns directory")
	require.NoError(t, lock.close())
	_, err = Convert(context.Background(), opts)
	require.NoError(t, err)
}

func TestDefaultBlocksDirectory(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, blockPayload(t), false))
	opts.BlocksDir = ""
	_, err := Convert(context.Background(), opts)
	require.NoError(t, err)
}

func TestDataFileSymlinkFails(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("Windows restricts symlink creation")
	}
	opts := testOptions(t, [8]byte{})
	path := filepath.Join(t.TempDir(), "block.dat")
	data := dataRecord(sourceMagic, blockPayload(t), false)
	require.NoError(t, os.WriteFile(path, data, 0600))
	require.NoError(t, os.Symlink(path, filepath.Join(opts.BlocksDir, "blk00000.dat")))
	_, err := Convert(context.Background(), opts)
	require.ErrorContains(t, err, "not a regular file")
	actual, err := os.ReadFile(path)
	require.NoError(t, err)
	require.Equal(t, data, actual)
}

func TestSharedDirectoryLock(t *testing.T) {
	key := [8]byte{}
	opts := testOptions(t, key)
	opts.BlocksDir = opts.DataDir
	putRecords(t, opts, "blk00000.dat", key, 0, dataRecord(sourceMagic, blockPayload(t), false))
	_, err := Convert(context.Background(), opts)
	require.NoError(t, err)
}
