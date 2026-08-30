package testharness

import "testing"

// A base inside the ephemeral range draws a port the OS already gave an
// outbound socket, and a base on a Core RPC port clashes with a node the test
// did not start.
func TestEveryPortBaseStaysInTheSafeRange(t *testing.T) {
	const nodes = 4

	coreRPCPorts := []int{8332, 18332, 18443, 38332}

	for i := 0; i < portBaseCount; i++ {
		base := 20000 + i*100
		_, _, top := testPorts(base, nodes-1)
		if top >= ephemeralFloor {
			t.Fatalf("base %d reaches %d, at or above the ephemeral floor %d", base, top, ephemeralFloor)
		}
		for _, taken := range coreRPCPorts {
			if taken >= base && taken <= top {
				t.Fatalf("base %d spans %d-%d, which covers the Core RPC port %d", base, base, top, taken)
			}
		}
	}
}

// randomPortBase must only ever return a base the check above covers.
func TestRandomPortBaseStaysOnTheGrid(t *testing.T) {
	highest := 20000 + (portBaseCount-1)*100
	for i := 0; i < 500; i++ {
		base := randomPortBase()
		if base < 20000 || base > highest || base%100 != 0 {
			t.Fatalf("randomPortBase returned %d", base)
		}
	}
}
