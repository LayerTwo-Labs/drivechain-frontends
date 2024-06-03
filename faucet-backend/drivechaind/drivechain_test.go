package drivechaind_test

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/faucet/drivechaind"
	"github.com/stretchr/testify/require"
)

func TestCheckValidDepositAddress(t *testing.T) {

	t.Run("can check various sidechain deposit addresses", func(t *testing.T) {

		// a valid onchain address, but not a deposit address
		err := drivechaind.CheckValidDepositAddress("3Ef6Dyk7UdbT8y8dge4Z73Ne2N18dPnU1h")
		require.Error(t, err)

		// valid
		err = drivechaind.CheckValidDepositAddress("s5_tmEoMXN71n8cQ7VNjP3EpEEn6fbXMvASwXt_712f8a")
		require.NoError(t, err)
		err = drivechaind.CheckValidDepositAddress("s0_sYvUEgThKWXxEN9PeE3KvcD1vEXEJzq8tv_adfbb5")
		require.NoError(t, err)
		err = drivechaind.CheckValidDepositAddress("s6_0xc96aaa54e2d44c299564da76e1cd3184a2386b8d_0ad45c")
		require.NoError(t, err)

		err = drivechaind.CheckValidDepositAddress("s5_tmCtD9o83Y1R2C8E99wV7XCmxD75Ruk71zx_637f80")
		require.NoError(t, err)

		// invalid checksums
		err = drivechaind.CheckValidDepositAddress("s6_0xc96aaa54e2d44c299564da76e1cd3184a2386b8d_adfbb5")
		require.Error(t, err)
		err = drivechaind.CheckValidDepositAddress("s5_tmEoMXN71n8cQ7VNjP3EpEEn6fbXMvASwXt_0ad45c")
		require.NoError(t, err)
	})
}
