package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"
	"time"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log" // nolint:depguard
	"golang.org/x/exp/slices"
)

func configureLogging(cfg *config) error {
	parsed, err := zerolog.ParseLevel(strings.ToLower(cfg.LogLevel))
	if err != nil {
		return fmt.Errorf("invalid log level: %s", cfg.LogLevel)
	}
	zerolog.SetGlobalLevel(parsed)

	var output io.Writer = messageEnhancerWriter{os.Stderr}
	if !cfg.JsonLog {
		output = zerolog.NewConsoleWriter(func(w *zerolog.ConsoleWriter) {
			w.Out = os.Stderr
		})
	}

	l := log.Output(output)
	log.Logger = l

	// default is with whole second precision
	zerolog.TimeFieldFormat = time.RFC3339Nano
	zerolog.DefaultContextLogger = &l
	return nil
}

// We want to achieve two different goals when writing logs:
//  1. Structured logging - i.e. level, timestamp field, metadata. That way
//     our log aggregator can turn our logs into meaningful data.
//  2. It should still be human-readable. If the structured log aggregator
//     only shows us the `message` field, we'll lose a bunch of value
//     information.
//
// We do this by monkey-patching the `message` field with the other fields
// we want to see. This involves a bit of back-and-forth JSON parsing and
// manipulating, but we aren't exactly implementing performance critical
// software anyway.
type messageEnhancerWriter struct {
	underlying io.Writer
}

// These are fields we aren't interested in adding to the `message` field.
var uninterestingFields = []string{
	"message", // The actual field we're manipulating - don't want to duplicate.
	"level",   // Added automatically by the log aggregator.
	"time",    // Added automatically by the log aggregator.
	"caller",  // Very noisy. If we're interested in a specific line, we can still find this.
	"commit",
}

// Write implements io.Writer
func (m messageEnhancerWriter) Write(p []byte) (int, error) {
	// The log line is a JSON blob which we want to manipulate a little
	// before passing on. We're going to parse it into this map.
	var evt map[string]any

	// First, do the parsing.
	dec := json.NewDecoder(bytes.NewReader(p))
	// JSON numbers are notoriously finicky, use this safer string-based
	// representation
	dec.UseNumber()
	if err := dec.Decode(&evt); err != nil {
		return 0, fmt.Errorf("decode event: %w", err)
	}

	// This is the value we're going to enhance, before sticking it back in.
	message, ok := evt["message"]
	if !ok {
		message = ""
		evt["message"] = message
	}

	// Now we'll add all our fields to the message, for human consumption.
	for key, value := range evt {
		if value == nil {
			continue
		}

		// Skip all the boring fields.
		if slices.Contains(uninterestingFields, key) {
			continue
		}

		// We want to present durations as human-readable fields. Conversions
		// done with the `.Dur` method in zerolog converts the value to a
		// json.Number, so we can't check for a time.Duration type.
		// Therefore, check for a json.Number, and a few well known fields
		// that contain durations. This just affects the manipulated `message`
		// field, the raw values are still present in the JSON object.
		if fValue, ok := value.(json.Number); ok && key == "duration" {
			millis, _ := fValue.Float64()
			duration := time.Duration(millis) * time.Millisecond

			// convert the value to a human-readable representation
			value = duration.String()
		}

		if boolValue, ok := value.(bool); ok {
			value = fmt.Sprintf("%t", boolValue)
		}

		const sep = ":"
		message = fmt.Sprintf("%s   %s%s%s", message, key, sep, value)
	}

	// Stick the manipulated message back in.
	evt["message"] = message

	// Marshal back to JSON
	marshaled, err := json.Marshal(evt)
	if err != nil {
		return 0, err
	}

	// Be sure to add a newline!
	marshaled = append(marshaled, []byte("\n")...)

	// And then write to the underlying writer.
	return m.underlying.Write(marshaled)
}
