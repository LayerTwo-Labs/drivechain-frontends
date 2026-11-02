package utils_test

import (
	"fmt"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/utils"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	utilspb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1/utilsv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
)

func TestEncodeBase58Check(t *testing.T) {
	t.Parallel()

	encode := func(t *testing.T, version int32) (*utilspb.EncodeBase58CheckResponse, error) {
		return utils.New(&chaincfg.RegressionNetParams).EncodeBase58Check(t.Context(), &utilspb.EncodeBase58CheckRequest{
			VersionByte: version,
			Data:        make([]byte, 20),
		})
	}

	t.Run("version 0 encodes", func(t *testing.T) {
		t.Parallel()
		resp, err := encode(t, 0)
		require.NoError(t, err)
		assert.Equal(t, "1111111111111111111114oLvT2", resp.Encoded)
	})

	t.Run("version 255 encodes", func(t *testing.T) {
		t.Parallel()
		_, err := encode(t, 255)
		require.NoError(t, err)
	})

	for _, version := range []int32{-1, 256, 300} {
		t.Run(fmt.Sprintf("version %d is invalid", version), func(t *testing.T) {
			t.Parallel()
			_, err := encode(t, version)
			assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		})
	}
}

func TestConvertOverTheWire(t *testing.T) {
	t.Parallel()

	cli := utilsv1connect.NewUtilsServiceClient(apitests.RPC(t, database.Test(t)))
	rowsByLabel := func(rows []*utilspb.ConvertRow) map[string]string {
		out := map[string]string{}
		for _, r := range rows {
			out[r.Label] = r.Value
		}
		return out
	}

	t.Run("a hex secret gives keys on the server params", func(t *testing.T) {
		t.Parallel()
		resp, err := cli.Convert(t.Context(), &utilspb.ConvertRequest{
			Input:  "0000000000000000000000000000000000000000000000000000000000000001",
			Format: utilspb.ConvertFormat_CONVERT_FORMAT_AUTO,
		})
		require.NoError(t, err)
		assert.Equal(t, utilspb.ConvertFormat_CONVERT_FORMAT_HEX, resp.Detected)
		assert.Empty(t, resp.Error)
		keys := rowsByLabel(resp.Keys)
		assert.Equal(t, "0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798", keys["Public key (compressed)"])
		assert.Equal(t, "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx", keys["P2WPKH address"])
		assert.Equal(t, "Hex", resp.Encodings[0].Label)
		assert.Equal(t, "SHA-256", resp.Hashes[0].Label)
	})

	t.Run("a mistyped WIF is an error, not a key", func(t *testing.T) {
		t.Parallel()
		resp, err := cli.Convert(t.Context(), &utilspb.ConvertRequest{
			Input:  "KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWa",
			Format: utilspb.ConvertFormat_CONVERT_FORMAT_WIF,
		})
		require.NoError(t, err)
		assert.Equal(t, utilspb.ConvertFormat_CONVERT_FORMAT_WIF, resp.Detected)
		assert.Contains(t, resp.Error, "WIF checksum does not match")
		assert.Empty(t, resp.Keys)
	})
}
