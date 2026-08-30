package api_bitdrive

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bitdrive"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"
)

// A transaction can carry one BitDrive payload per output. Keying downloads on
// the txid alone made every payload after the first look already-downloaded, so
// it never reached disk.
func TestDownloadPendingFiles_TwoPayloadsInOneTransaction(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)

	const (
		txid      = "aabbcc"
		timestamp = uint32(1700000000)
	)
	metadataB64 := engines.EncodeMetadata(false, false, timestamp, "txt")

	require.NoError(t, opreturns.Persist(ctx, db, []opreturns.OPReturn{
		{TxID: txid, Vout: 0, Data: []byte(engines.FormatOPReturnData(metadataB64, "first payload"))},
		{TxID: txid, Vout: 1, Data: []byte(engines.FormatOPReturnData(metadataB64, "second payload"))},
	}))

	// Unencrypted payloads need neither a wallet nor chain params.
	server := &Server{
		database:       db,
		bitdriveEngine: engines.NewBitDriveEngine(db, nil, t.TempDir(), nil),
	}

	resp, err := server.DownloadPendingFiles(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	require.Equal(t, uint32(2), resp.Msg.DownloadedCount)
	require.Zero(t, resp.Msg.FailedCount)

	files, err := bitdrive.List(ctx, db)
	require.NoError(t, err)
	require.Len(t, files, 2)

	want := map[int32]string{0: "first payload", 1: "second payload"}
	for _, file := range files {
		content, err := server.bitdriveEngine.GetFileContent(ctx, file.Filename)
		require.NoError(t, err)
		require.Equal(t, want[file.Vout], string(content))
		delete(want, file.Vout)
	}
	require.Empty(t, want)

	// Both payloads are downloaded now, so a second pass has nothing to do.
	resp, err = server.DownloadPendingFiles(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	require.Zero(t, resp.Msg.DownloadedCount)
}
