package utils_test

import (
	"fmt"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/utils"
	utilspb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1"
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
