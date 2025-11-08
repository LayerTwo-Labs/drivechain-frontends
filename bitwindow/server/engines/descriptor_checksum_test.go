package engines

import (
	"testing"
)

func TestDescriptorChecksum(t *testing.T) {
	tests := []struct {
		desc             string
		expectedChecksum string
	}{
		{
			// From Bitcoin Core getdescriptorinfo
			desc:             "wpkh(tpubDDH1ndozCcuGXjVaXnB4NHUWbKfMTYfxH3wuU1GFvCXtEZZqsMY6NxBdgdaebExgDAVicckGNJDU8wVfRUWWMaov5jX4zPaDorqe75QwjAC/0/*)",
			expectedChecksum: "v39n29tr",
		},
		{
			// Another example from Bitcoin Core
			desc:             "wpkh(tpubDDH1ndozCcuGXjVaXnB4NHUWbKfMTYfxH3wuU1GFvCXtEZZqsMY6NxBdgdaebExgDAVicckGNJDU8wVfRUWWMaov5jX4zPaDorqe75QwjAC/1/*)",
			expectedChecksum: "a9qjhsmm",
		},
		{
			// Test with xprv - expected checksum from Bitcoin Core error message
			desc:             "wpkh(tprv8gayeDmk4FDbeGTne8WTxspQ2J9RJDV3hkM8BVDxVvjVQ5K5ExiWCTZmWXypiXyFhDMoCWKac4U8FMXkc5wvjFYQwiGYFdqmKAqdgPAL8pw/0/*)",
			expectedChecksum: "4zyy5snq",
		},
		{
			// Another xprv
			desc:             "wpkh(tprv8gayeDmk4FDbeGTne8WTxspQ2J9RJDV3hkM8BVDxVvjVQ5K5ExiWCTZmWXypiXyFhDMoCWKac4U8FMXkc5wvjFYQwiGYFdqmKAqdgPAL8pw/1/*)",
			expectedChecksum: "ykp9f9rc",
		},
	}

	for _, tt := range tests {
		t.Run(tt.desc[:20]+"...", func(t *testing.T) {
			checksum, err := DescriptorChecksum(tt.desc)
			if err != nil {
				t.Fatalf("compute checksum: %v", err)
			}

			if checksum != tt.expectedChecksum {
				t.Errorf("checksum mismatch:\n  got:      %s\n  expected: %s", checksum, tt.expectedChecksum)
			}
		})
	}
}
