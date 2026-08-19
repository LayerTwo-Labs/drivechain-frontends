package main

import (
	"errors"
	"fmt"
	"net/http"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestExitError(t *testing.T) {
	assert.NoError(t, exitError(nil))
	assert.NoError(t, exitError(http.ErrServerClosed))
	assert.NoError(t, exitError(fmt.Errorf("serve: %w", http.ErrServerClosed)))

	boom := errors.New("listen on \"127.0.0.1:8080\": address already in use")
	assert.ErrorIs(t, exitError(boom), boom)
}
