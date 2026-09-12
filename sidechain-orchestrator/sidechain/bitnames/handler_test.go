package bitnames

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestDataServerAddressPrefersIPv4(t *testing.T) {
	v4 := "1.2.3.4:6002"
	v6 := "[::1]:6002"

	got, err := dataServerAddress(BitNameData{SocketAddrV4: &v4, SocketAddrV6: &v6})
	require.NoError(t, err)
	assert.Equal(t, v4, got)
}

func TestDataServerAddressFallsBackToIPv6(t *testing.T) {
	v6 := "[::1]:6002"

	got, err := dataServerAddress(BitNameData{SocketAddrV6: &v6})
	require.NoError(t, err)
	assert.Equal(t, v6, got)
}

func TestDataServerAddressSkipsEmptyIPv4(t *testing.T) {
	empty := ""
	v6 := "[::1]:6002"

	got, err := dataServerAddress(BitNameData{SocketAddrV4: &empty, SocketAddrV6: &v6})
	require.NoError(t, err)
	assert.Equal(t, v6, got)
}

func TestDataServerAddressErrorsWithNoAddress(t *testing.T) {
	_, err := dataServerAddress(BitNameData{})
	require.Error(t, err)
}
