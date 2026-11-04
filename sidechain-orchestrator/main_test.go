package orchestrator

import (
	"os"
	"testing"
	"time"
)

// lookalikeEnv makes the test binary only sleep, so a test can run it under
// another name. The multi-call coreutils of Ubuntu 26.04 refuse a renamed sleep.
const lookalikeEnv = "ORCHESTRATOR_TEST_LOOKALIKE"

func TestMain(m *testing.M) {
	if os.Getenv(lookalikeEnv) == "1" {
		time.Sleep(time.Minute)
		os.Exit(0)
	}
	os.Exit(m.Run())
}
