package cgminer_test

import (
	"context"
	"io"
	"net"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/cgminer"
)

// The estats reply in the Avalon A10 API manual, with the per-chip arrays cut short.
const a10Estats = "STATUS=S,When=6397,Code=70,Msg=CGMiner stats,Description=cgminer 4.11.1|STATS=0,ID=AVA100,Elapsed=6354,Calls=0,Wait=0.000000,Max=0.000000,Min=99999999.000000,MM ID0=Ver[1066-19101244_fe411a8_71edeca] DNA[020100002c2af618] NETFAIL[0 0 0 0 0 0 0 0] SYSTEMSTATU[Work: In Work, Hash Board: 3 ] Elapsed[6355] MW[1443554 1443536 1443615] LW[4330705] MH[0 2 0] HW[2] DH[0.736%] Temp[25] TMax[74] TAvg[66] Fan1[3671] Fan2[3635] Fan3[3564] Fan4[3623] FanR[55%] Vo[336] PS[0 1217 1279 221 2834 1280] PLL0[510 1002 2072 3142] GHSmm[51062.40] GHSavg[50291.83] WU[702568.70] Freq[632.65] Led[0] MGHS[16645.36 16761.64 16884.83] MTmax[74 72 74] MTavg[65 63 66] TA[342] ECHU[512 512 512] ECMM[0] PVT_T0[ 59  58  55  56] MW0[198 209 215 214] CRC[0 1 0] POW_I2C_CONN[SUCCES] HS_RCD0[Tenv:23 Tavg:65 Fan1:3407 Fan2:3407 V12:1217 Vout:1277 P_I:220 P_P:2809] MEMFREE[269880 B] FACOPTS0[] FACOPTS1[] WORKMODE[1],MM Count=1,Smart Speed=1,Connection Overloaded=false,Voltage Level Offset=0,Nonce Mask=25 |"

// A Nano 3S estats reply in the field order of its cgminer driver.
const nano3sEstats = "STATUS=S,When=1784800000,Code=70,Msg=CGMiner stats,Description=cgminer 4.11.1|STATS=0,ID=AVA100,Elapsed=4021,Calls=0,Wait=0.000000,Max=0.000000,Min=99999999.000000,MM ID0=Ver[Nano3s-25021401_56abae7] LVer[25021401_56abae7] BVer[25021401_56abae7] HVer[6002] FVer[0x0000] ITemp[29] OTemp[-273] TMax[82] TAvg[80] TarT[80] Fan1[2400] FanR[45%] PS[0 0 27965 2 0 3210 66] GHSspd[6021.44] DHspd[0.012%] GHSmm[5998.12] GHSavg[5902.33] WU[82431.05] Freq[500.00] MGHS[5902.33] TA[10] Core[A3197S] BIN[36] PING[122] SoftOFF[0] ECHU[0] ECMM[0] PLL0[3120 0 0 0] SF0[475 500 525 550] PVT_T0[80 81 79 80] PVT_V0[294 295 294 293] MW0[102 98 99 101] CRC[0] COMCRC[0] ATA2[-5000-80-16-500-0] WORKMODE[2] MPO[140] CALIALL[7] ADJ[1] Nonce Mask[25],MM Count=1,Smart Speed=1,Connection Overloaded=false,Voltage Level Offset=0,Nonce Mask=25|"

// The AvalonMiner 1047 stats reply in the Prometheus exporter tests. It
// brackets the MM ID0 section and reports no PS list.
const avalon1047Stats = "STATUS=S,When=3600,Code=70,Msg=CGMiner stats,Description=cgminer 4.11.1|STATS=0,ID=AV1047,Elapsed=3600,MM Count=2,MM ID0[Ver[synthetic],DNA[REDACTED],SYSTEMSTATU[Work: In Work, Hash Board: 2],Temp[66],TMax[82],TAvg[70],Fan1[5600],Fan2[5700],FanR[88%],GHSmm[33300.5],GHSavg[32100.25],WU[450.5],Freq[625],HW[7],DH[0.01%],MPO[2220],PVT_T0[60 61 62],PVT_T1[63 64 65]]|"

func ptr[T any](v T) *T { return &v }

func TestParseStats(t *testing.T) {
	tests := []struct {
		name  string
		reply string
		want  cgminer.Device
	}{
		{
			name:  "an A10 reports hash board power at index 4",
			reply: a10Estats,
			want: cgminer.Device{
				TemperatureCelsius: ptr(66.0),
				FanPercent:         ptr(55.0),
				PowerWatts:         ptr(2834.0),
				WorkMode:           ptr(cgminer.WorkModeMid),
			},
		},
		{
			name:  "a Nano 3S reports wall power at index 6",
			reply: nano3sEstats,
			want: cgminer.Device{
				TemperatureCelsius: ptr(80.0),
				FanPercent:         ptr(45.0),
				PowerWatts:         ptr(66.0),
				WorkMode:           ptr(cgminer.WorkModeHigh),
			},
		},
		{
			name:  "a 1047 has no power reading and no work mode",
			reply: avalon1047Stats,
			want: cgminer.Device{
				TemperatureCelsius: ptr(70.0),
				FanPercent:         ptr(88.0),
			},
		},
		{
			name:  "the inlet sensor stands in for a missing average",
			reply: "STATUS=S,Code=70,Msg=CGMiner stats|STATS=0,MM ID0=ITemp[31] FanR[20%]|",
			want: cgminer.Device{
				TemperatureCelsius: ptr(31.0),
				FanPercent:         ptr(20.0),
			},
		},
		{
			name:  "an absent inlet sensor reads -273",
			reply: "STATUS=S,Code=70,Msg=CGMiner stats|STATS=0,MM ID0=ITemp[-273]|",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, ok := cgminer.ParseStats(tt.reply)
			require.True(t, ok)
			assert.Equal(t, tt.want, got)
		})
	}

	t.Run("a reply with no MM ID0 section", func(t *testing.T) {
		_, ok := cgminer.ParseStats("STATUS=S,When=1,Code=70,Msg=CGMiner stats|STATS=0,ID=POOL0|")
		assert.False(t, ok)
	})
}

func TestReplyError(t *testing.T) {
	tests := []struct {
		name    string
		reply   string
		wantErr string
	}{
		{name: "set OK", reply: "STATUS=S,When=1052,Code=119,Msg=ASC 0 set OK,Description=cgminer 4.11.1|"},
		{name: "set info", reply: "STATUS=I,When=19189,Code=118,Msg=ASC 0 set info: WORKMODE[1],Description=cgminer 4.11.1|"},
		{
			name:    "set failed",
			reply:   "STATUS=E,When=1052,Code=120,Msg=ASC 0 set failed: Unknown option: workmode,Description=cgminer 4.11.1|",
			wantErr: "ASC 0 set failed: Unknown option: workmode",
		},
		{name: "invalid command", reply: "STATUS=E,When=1,Code=14,Msg=Invalid command,Description=cgminer 4.11.1|", wantErr: "Invalid command"},
		{name: "no status", reply: "garbage", wantErr: "reply has no status"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := cgminer.ReplyError(tt.reply)
			if tt.wantErr == "" {
				assert.NoError(t, err)
				return
			}
			assert.ErrorContains(t, err, tt.wantErr)
		})
	}
}

// fakeDevice answers each request from replies and records what it got.
type fakeDevice struct {
	addr     string
	mu       sync.Mutex
	requests []string
}

func startFakeDevice(t *testing.T, replies map[string]string) *fakeDevice {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	t.Cleanup(func() { _ = ln.Close() })
	d := &fakeDevice{addr: ln.Addr().String()}
	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			buf := make([]byte, 256)
			n, _ := conn.Read(buf)
			request := string(buf[:n])
			d.mu.Lock()
			d.requests = append(d.requests, request)
			d.mu.Unlock()
			_, _ = io.WriteString(conn, replies[request]+"\x00")
			_ = conn.Close()
		}
	}()
	return d
}

func TestReadDevice(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	t.Run("estats", func(t *testing.T) {
		d := startFakeDevice(t, map[string]string{"estats": nano3sEstats})
		got, err := cgminer.ReadDevice(ctx, d.addr)
		require.NoError(t, err)
		assert.Equal(t, ptr(66.0), got.PowerWatts)
	})

	t.Run("stats when estats has no MM ID0", func(t *testing.T) {
		d := startFakeDevice(t, map[string]string{
			"estats": "STATUS=S,When=1,Code=70,Msg=CGMiner stats|STATS=0,ID=POOL0|",
			"stats":  a10Estats,
		})
		got, err := cgminer.ReadDevice(ctx, d.addr)
		require.NoError(t, err)
		assert.Equal(t, ptr(2834.0), got.PowerWatts)
	})

	t.Run("no device at the address", func(t *testing.T) {
		ln, err := net.Listen("tcp", "127.0.0.1:0")
		require.NoError(t, err)
		addr := ln.Addr().String()
		require.NoError(t, ln.Close())
		_, err = cgminer.ReadDevice(ctx, addr)
		require.Error(t, err)
	})
}

func TestSetWorkMode(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	const ok = "STATUS=S,When=1,Code=119,Msg=ASC 0 set OK,Description=cgminer 4.11.1|"
	const unknown = "STATUS=E,When=1,Code=120,Msg=ASC 0 set failed: Unknown option: %s,Description=cgminer 4.11.1|"

	t.Run("workmode", func(t *testing.T) {
		d := startFakeDevice(t, map[string]string{"ascset|0,workmode,set,2": ok})
		require.NoError(t, cgminer.SetWorkMode(ctx, d.addr, cgminer.WorkModeHigh))
		assert.Equal(t, []string{"ascset|0,workmode,set,2"}, d.requests)
	})

	t.Run("worklevel when the firmware has no workmode", func(t *testing.T) {
		d := startFakeDevice(t, map[string]string{
			"ascset|0,workmode,set,0":  strings.Replace(unknown, "%s", "workmode", 1),
			"ascset|0,worklevel,set,0": ok,
		})
		require.NoError(t, cgminer.SetWorkMode(ctx, d.addr, cgminer.WorkModeLow))
		assert.Equal(t, []string{"ascset|0,workmode,set,0", "ascset|0,worklevel,set,0"}, d.requests)
	})

	t.Run("both names fail", func(t *testing.T) {
		d := startFakeDevice(t, map[string]string{
			"ascset|0,workmode,set,1":  "STATUS=E,When=1,Code=120,Msg=ASC 0 set failed: current mode 0 is caling Don't permit switch mode,Description=cgminer 4.11.1|",
			"ascset|0,worklevel,set,1": strings.Replace(unknown, "%s", "worklevel", 1),
		})
		err := cgminer.SetWorkMode(ctx, d.addr, cgminer.WorkModeMid)
		require.ErrorContains(t, err, "caling")
		require.ErrorContains(t, err, "Unknown option: worklevel")
	})
}
