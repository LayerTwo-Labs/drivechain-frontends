package main

import (
	"errors"
	"fmt"
	"net/http"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestExitError(t *testing.T) {
	assert.NoError(t, exitError(nil))
	assert.NoError(t, exitError(http.ErrServerClosed))
	assert.NoError(t, exitError(fmt.Errorf("serve: %w", http.ErrServerClosed)))

	boom := errors.New("listen on \"127.0.0.1:8080\": address already in use")
	assert.ErrorIs(t, exitError(boom), boom)
}

// A user who passes --log.path gets the whole merged stream in that file.
func TestOrchestratordLogPathFollowsTheConfiguredPath(t *testing.T) {
	chosen := filepath.Join("/data", "my.log")

	require.Equal(t, chosen, orchestratordLogPath(config.Config{LogPath: chosen}, "/data/bitwindow"))
	require.Equal(t,
		filepath.Join("/data/bitwindow", "bitwindow.log"),
		orchestratordLogPath(config.Config{}, "/data/bitwindow"),
	)
}
