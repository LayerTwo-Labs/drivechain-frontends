package orchestrator

import "testing"

func TestEnforcerEnv_RustBacktraceEnabled(t *testing.T) {
	env := enforcerEnv()
	got, ok := env["RUST_BACKTRACE"]
	if !ok {
		t.Fatalf("expected RUST_BACKTRACE in enforcerEnv(), got %v", env)
	}
	if got != "1" && got != "full" {
		t.Fatalf("expected RUST_BACKTRACE=1 (or full), got %q", got)
	}
}
