package orchestrator

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNew(t *testing.T) {
	o := newTestOrchestrator(t)
	assert.NotEmpty(t, o.DataDir)
	assert.Equal(t, "signet", o.Network)
	assert.Greater(t, len(o.configs), 0)
}

func TestOrchestrator_StatusUnknown(t *testing.T) {
	o := newTestOrchestrator(t)
	status := o.Status("nonexistent")
	assert.Equal(t, "nonexistent", status.Name)
	assert.NotEmpty(t, status.Error)
}

func TestOrchestrator_StatusNotRunning(t *testing.T) {
	o := newTestOrchestrator(t)
	status := o.Status("thunder")
	assert.Equal(t, "thunder", status.Name)
	assert.False(t, status.Running)
	assert.Equal(t, 6009, status.Port)
}

func TestOrchestrator_ListAll(t *testing.T) {
	o := newTestOrchestrator(t)
	assert.Equal(t, len(AllDefaults()), len(o.ListAll()))
}

func TestOrchestrator_LogsNotRunning(t *testing.T) {
	o := newTestOrchestrator(t)
	_, _, err := o.Logs("thunder")
	assert.Error(t, err)
}

func TestOrchestrator_AdoptOrphans(t *testing.T) {
	o := newTestOrchestrator(t)

	require.NoError(t, o.pidManager.WritePidFile("thunder", 99999))
	require.NoError(t, o.AdoptOrphans(context.Background()))

	_, err := o.pidManager.ReadPidFile("thunder")
	assert.Error(t, err)
}

func TestOrderForShutdown(t *testing.T) {
	assert.Equal(t,
		[]string{"thunder", "enforcer", "bitcoind"},
		orderForShutdown([]string{"bitcoind", "enforcer", "thunder"}),
	)
}

func TestOrderForShutdown_Empty(t *testing.T) {
	assert.Empty(t, orderForShutdown(nil))
}
