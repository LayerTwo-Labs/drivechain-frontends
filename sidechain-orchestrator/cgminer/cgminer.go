// Package cgminer talks to the device API of cgminer-based ASIC miners on TCP
// port 4028: plain `command|parameter` requests, no login for reads.
package cgminer

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"regexp"
	"strconv"
	"strings"
)

// Port is the TCP port of the device API.
const Port = "4028"

const maxReplySize = 1 << 20

// WorkMode is the power mode of an Avalon miner.
type WorkMode int

const (
	WorkModeLow  WorkMode = 0
	WorkModeMid  WorkMode = 1
	WorkModeHigh WorkMode = 2
)

// Device holds what the device API reports. A nil field is a value the
// device did not report.
type Device struct {
	TemperatureCelsius *float64
	FanPercent         *float64
	PowerWatts         *float64
	WorkMode           *WorkMode
}

// Command sends one request to addr and returns the whole reply.
func Command(ctx context.Context, addr, command string) (string, error) {
	var dialer net.Dialer
	conn, err := dialer.DialContext(ctx, "tcp", addr)
	if err != nil {
		return "", fmt.Errorf("dial %s: %w", addr, err)
	}
	defer func() { _ = conn.Close() }()
	if deadline, ok := ctx.Deadline(); ok {
		if err := conn.SetDeadline(deadline); err != nil {
			return "", err
		}
	}
	if _, err := conn.Write([]byte(command)); err != nil {
		return "", fmt.Errorf("send %q: %w", command, err)
	}
	reply, err := io.ReadAll(io.LimitReader(conn, maxReplySize))
	if err != nil {
		return "", fmt.Errorf("read reply to %q: %w", command, err)
	}
	return strings.TrimRight(string(reply), "\x00\r\n"), nil
}

var statusField = regexp.MustCompile(`STATUS=([A-Z])`)
var messageField = regexp.MustCompile(`Msg=([^,|]*)`)

// ReplyError returns the error an E or F status reply carries.
func ReplyError(reply string) error {
	status := statusField.FindStringSubmatch(reply)
	if status == nil {
		return fmt.Errorf("reply has no status: %q", reply)
	}
	if status[1] != "E" && status[1] != "F" {
		return nil
	}
	if msg := messageField.FindStringSubmatch(reply); msg != nil {
		return errors.New(msg[1])
	}
	return fmt.Errorf("device error: %q", reply)
}

var bracketField = regexp.MustCompile(`(\w+)\[([^\]]*)\]`)

// ParseStats reads the MM ID0 section of an estats or stats reply. ok is
// false when the reply has no such section.
func ParseStats(reply string) (Device, bool) {
	start := strings.Index(reply, "MM ID0")
	if start < 0 {
		return Device{}, false
	}
	section := reply[start:]
	if end := strings.IndexByte(section, '|'); end >= 0 {
		section = section[:end]
	}

	fields := map[string]string{}
	for _, m := range bracketField.FindAllStringSubmatch(section, -1) {
		if _, seen := fields[m[1]]; !seen {
			fields[m[1]] = strings.TrimSpace(m[2])
		}
	}

	var d Device
	if t, ok := number(fields["TAvg"]); ok && t > 0 {
		d.TemperatureCelsius = &t
	} else if t, ok := number(fields["ITemp"]); ok && t > -273 {
		d.TemperatureCelsius = &t
	}
	if fan, ok := number(strings.TrimSuffix(fields["FanR"], "%")); ok {
		d.FanPercent = &fan
	}
	if watts, ok := power(fields["PS"]); ok {
		d.PowerWatts = &watts
	}
	if mode, err := strconv.Atoi(fields["WORKMODE"]); err == nil {
		m := WorkMode(mode)
		d.WorkMode = &m
	}
	return d, true
}

func number(s string) (float64, bool) {
	f, err := strconv.ParseFloat(strings.TrimSpace(s), 64)
	return f, err == nil
}

// power reads watts from a PS list. Home miners report wall power at index
// 6; the A-series reports hash board power at index 4.
func power(ps string) (float64, bool) {
	slots := strings.Fields(ps)
	var index int
	switch len(slots) {
	case 7:
		index = 6
	case 6:
		index = 4
	default:
		return 0, false
	}
	return number(slots[index])
}

// ReadDevice asks the miner at addr for its stats.
func ReadDevice(ctx context.Context, addr string) (Device, error) {
	var errs []error
	for _, command := range []string{"estats", "stats"} {
		reply, err := Command(ctx, addr, command)
		if err != nil {
			return Device{}, err
		}
		if err := ReplyError(reply); err != nil {
			errs = append(errs, fmt.Errorf("%s: %w", command, err))
			continue
		}
		if d, ok := ParseStats(reply); ok {
			return d, nil
		}
		errs = append(errs, fmt.Errorf("%s: no MM ID0 section", command))
	}
	return Device{}, errors.Join(errs...)
}

// SetWorkMode sets the power mode of the miner at addr. Some firmware names
// the setting worklevel, so that name is the second try.
func SetWorkMode(ctx context.Context, addr string, mode WorkMode) error {
	var errs []error
	for _, option := range []string{"workmode", "worklevel"} {
		reply, err := Command(ctx, addr, fmt.Sprintf("ascset|0,%s,set,%d", option, mode))
		if err != nil {
			return err
		}
		if err := ReplyError(reply); err != nil {
			errs = append(errs, fmt.Errorf("%s: %w", option, err))
			continue
		}
		return nil
	}
	return errors.Join(errs...)
}
