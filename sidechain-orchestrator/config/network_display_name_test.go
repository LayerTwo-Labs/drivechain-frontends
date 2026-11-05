package config

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNetworkDisplayNameFallsBackToTheNetwork(t *testing.T) {
	assert.Equal(t, string(NetworkRegtest), NetworkDisplayName(NetworkRegtest))
}
