package rpcclient

import "testing"

func TestParseBitcoindVersionSupportsBitcoinSubversions(t *testing.T) {
	version := parseBitcoindVersion("/Satoshi:25.0.0/")

	if version != BitcoindPost25 {
		t.Fatalf("expected post-25 bitcoind version, got %v", version)
	}
	if !version.SupportUnifiedSoftForks() {
		t.Fatal("expected Bitcoin Core 25 to support unified softforks")
	}
}

func TestParseBitcoindVersionSupportsLitecoinCoreSubversions(t *testing.T) {
	version := parseBitcoindVersion("/LitecoinCore:0.21.4/")

	if version != BitcoindPre22 {
		t.Fatalf("expected Litecoin Core 0.21.4 to map to pre-22 capability set, got %v", version)
	}
	if !version.SupportUnifiedSoftForks() {
		t.Fatal("expected Litecoin Core 0.21.4 to support unified softforks")
	}
}

func TestParseBitcoindVersionSupportsLegacyLitecoinSubversions(t *testing.T) {
	version := parseBitcoindVersion("/Litecoin:0.18.1/")

	if version != BitcoindPre19 {
		t.Fatalf("expected legacy Litecoin 0.18.1 to map to pre-19 capability set, got %v", version)
	}
	if version.SupportUnifiedSoftForks() {
		t.Fatal("expected legacy Litecoin 0.18.1 to use legacy softfork parsing")
	}
}
