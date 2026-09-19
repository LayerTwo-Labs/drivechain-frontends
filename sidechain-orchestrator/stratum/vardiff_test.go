package stratum

import (
	"math"
	"net"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestRetarget(t *testing.T) {
	tests := []struct {
		name    string
		current float64
		shares  int
		elapsed time.Duration
		want    float64
	}{
		{name: "one share per interval holds", current: 8192, shares: 6, elapsed: time.Minute, want: 8192},
		{name: "a small miss holds", current: 8192, shares: 9, elapsed: time.Minute, want: 8192},
		{name: "twice the rate doubles", current: 8192, shares: 12, elapsed: time.Minute, want: 16384},
		{name: "a fast miner steps up four times at most", current: 8192, shares: 30, elapsed: 5 * time.Second, want: 32768},
		{name: "half the rate halves", current: 8192, shares: 3, elapsed: 2 * time.Minute, want: 2048},
		{name: "no share drops by the full step", current: 8192, shares: 0, elapsed: time.Minute, want: 2048},
		{name: "no time holds", current: 8192, shares: 5, elapsed: 0, want: 8192},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.InDelta(t, tt.want, retarget(tt.current, tt.shares, tt.elapsed), 1e-9)
		})
	}
}

func TestDueForRetarget(t *testing.T) {
	assert.False(t, dueForRetarget(3, 30*time.Second))
	assert.True(t, dueForRetarget(3, time.Minute))
	assert.True(t, dueForRetarget(earlyRetargetShares, time.Second))
}

func TestClampDifficulty(t *testing.T) {
	assert.Equal(t, 1.0, clampDifficulty(0.01, 1e6))
	assert.Equal(t, 8192.0, clampDifficulty(8192, 1e6))
	assert.Equal(t, 1e6, clampDifficulty(1e9, 1e6))
	// A test network sits below the floor, and the network wins.
	assert.Equal(t, 4.6e-10, clampDifficulty(8192, 4.6e-10))
}

func TestHashrate(t *testing.T) {
	now := time.Unix(1_800_000_000, 0)
	t.Run("the window caps the span", func(t *testing.T) {
		var samples []shareSample
		for i := range 30 {
			samples = append(samples, shareSample{at: now.Add(-time.Duration(i) * 10 * time.Second), difficulty: 8192})
		}
		got := hashrate(samples, now.Add(-time.Hour), now)
		want := 30 * 8192 * math.Pow(2, 32) / hashrateWindow.Seconds()
		assert.InDelta(t, want, got, want*1e-9)
	})

	t.Run("old shares fall out", func(t *testing.T) {
		samples := []shareSample{{at: now.Add(-10 * time.Minute), difficulty: 8192}}
		assert.Zero(t, hashrate(samples, now.Add(-time.Hour), now))
		assert.Empty(t, pruneSamples(samples, now))
	})

	t.Run("a young connection divides by its age", func(t *testing.T) {
		samples := []shareSample{{at: now, difficulty: 1000}}
		got := hashrate(samples, now.Add(-time.Minute), now)
		assert.InDelta(t, 1000*math.Pow(2, 32)/60, got, 1)
	})
}

func TestLANIPv4(t *testing.T) {
	addr := func(cidr string) net.Addr {
		ip, ipnet, err := net.ParseCIDR(cidr)
		if err != nil {
			t.Fatal(err)
		}
		ipnet.IP = ip
		return ipnet
	}
	up := net.FlagUp | net.FlagBroadcast
	tests := []struct {
		name       string
		interfaces []Interface
		want       string
	}{
		{name: "loopback only", interfaces: []Interface{{Flags: up | net.FlagLoopback, Addrs: []net.Addr{addr("127.0.0.1/8")}}}},
		{name: "a VPN tunnel is skipped", interfaces: []Interface{
			{Flags: up | net.FlagPointToPoint, Addrs: []net.Addr{addr("10.8.0.2/24")}},
			{Flags: up, Addrs: []net.Addr{addr("fe80::1/64"), addr("192.168.1.20/24")}},
		}, want: "192.168.1.20"},
		{name: "a down interface is skipped", interfaces: []Interface{
			{Flags: net.FlagBroadcast, Addrs: []net.Addr{addr("192.168.1.20/24")}},
		}},
		{name: "a public address is skipped", interfaces: []Interface{
			{Flags: up, Addrs: []net.Addr{addr("8.8.8.8/24"), addr("10.0.0.5/8")}},
		}, want: "10.0.0.5"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			ip, ok := lanIPv4(tt.interfaces)
			if tt.want == "" {
				assert.False(t, ok)
				return
			}
			assert.True(t, ok)
			assert.Equal(t, tt.want, ip.String())
		})
	}
}

func TestReplyError(t *testing.T) {
	assert.NoError(t, replyError(nil))
	assert.NoError(t, replyError([]byte("null")))
	assert.EqualError(t, replyError([]byte(`[23, "low difficulty share", null]`)), "stratum error 23: low difficulty share")
	assert.EqualError(t, replyError([]byte(`{"code": 21, "message": "job not found"}`)), "stratum error 21: job not found")
	assert.EqualError(t, replyError([]byte(`"stale"`)), `stratum error 20: "stale"`)
}

func TestOutageOver(t *testing.T) {
	now := time.Unix(1_800_000_000, 0)
	assert.False(t, outageOver(time.Time{}, now))
	assert.False(t, outageOver(now.Add(-time.Minute), now))
	assert.True(t, outageOver(now.Add(-templateOutage), now))
}

func TestParseDifficulty(t *testing.T) {
	for _, good := range []struct {
		raw  string
		want float64
	}{
		{raw: `[8192]`, want: 8192},
		{raw: `["0.5"]`, want: 0.5},
	} {
		t.Run(good.raw, func(t *testing.T) {
			got, err := parseDifficulty([]byte(good.raw))
			assert.NoError(t, err)
			assert.Equal(t, good.want, got)
		})
	}
	for _, bad := range []string{`["NaN"]`, `["Inf"]`, `["-Inf"]`, `[0]`, `[-1]`, `[]`, `["fast"]`} {
		t.Run(bad, func(t *testing.T) {
			_, err := parseDifficulty([]byte(bad))
			assert.Error(t, err)
		})
	}
}
