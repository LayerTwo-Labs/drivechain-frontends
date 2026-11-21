package orchestrator

import (
	"strings"
	"time"
)

// bootStep logs one step of a daemon boot. The log time of these lines is the boot timeline.
func (o *Orchestrator) bootStep(binary, step string) {
	o.log.Info().Str("binary", binary).Str("step", step).Msg("boot step")
}

// stampFirstLogLine logs the first output line of proc as a boot step.
func (o *Orchestrator) stampFirstLogLine(binary string, proc *ManagedProcess) {
	if proc == nil {
		return
	}
	recent, sub := proc.subscribe(maxLogEntries, "", 0)
	go func() {
		defer sub.Cancel()
		for _, entry := range recent {
			if entry.Stream != "marker" {
				o.logFirstLine(binary, entry)
				return
			}
		}
		for entry := range sub.Entries() {
			if entry.Stream != "marker" {
				o.logFirstLine(binary, entry)
				return
			}
		}
	}()
}

func (o *Orchestrator) logFirstLine(binary string, entry LogEntry) {
	o.log.Info().Str("binary", binary).Str("step", "first log line").
		Time("written", lineTime(entry)).Msg("boot step")
}

// lineTime reads the leading RFC 3339 time of a log line, else the time the tail read it.
func lineTime(entry LogEntry) time.Time {
	first, _, _ := strings.Cut(entry.Line, " ")
	if t, err := time.Parse(time.RFC3339Nano, first); err == nil {
		return t
	}
	return entry.Timestamp
}
