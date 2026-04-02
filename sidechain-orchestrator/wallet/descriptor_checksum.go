package wallet

import (
	"fmt"
	"strings"
)

// Descriptor checksum implementation based on Bitcoin Core's algorithm
// https://github.com/bitcoin/bitcoin/blob/master/src/script/descriptor.cpp

const inputCharset = "0123456789()[],'/*abcdefgh@:$%{}IJKLMNOPQRSTUVWXYZ&+-.;<=>?!^_|~ijklmnopqrstuvwxyzABCDEFGH`#\"\\ "
const checksumCharset = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"

// polymod computes the descriptor checksum polymod
func polymod(c uint64, val uint64) uint64 {
	c0 := c >> 35
	c = ((c & 0x7ffffffff) << 5) ^ val
	if c0&1 != 0 {
		c ^= 0xf5dee51989
	}
	if c0&2 != 0 {
		c ^= 0xa9fdca3312
	}
	if c0&4 != 0 {
		c ^= 0x1bab10e32d
	}
	if c0&8 != 0 {
		c ^= 0x3706b1677a
	}
	if c0&16 != 0 {
		c ^= 0x644d626ffd
	}
	return c
}

// DescriptorChecksum computes the checksum for a descriptor string.
func DescriptorChecksum(desc string) (string, error) {
	c := uint64(1)
	cls := 0
	clscount := 0

	for _, ch := range desc {
		pos := strings.IndexRune(inputCharset, ch)
		if pos == -1 {
			return "", fmt.Errorf("invalid character in descriptor: %c", ch)
		}

		c = polymod(c, uint64(pos&31))

		cls = cls*3 + (pos >> 5)
		clscount++

		if clscount == 3 {
			c = polymod(c, uint64(cls))
			cls = 0
			clscount = 0
		}
	}

	if clscount > 0 {
		c = polymod(c, uint64(cls))
	}

	for i := 0; i < 8; i++ {
		c = polymod(c, 0)
	}

	c ^= 1

	var checksum strings.Builder
	for i := 0; i < 8; i++ {
		checksum.WriteByte(checksumCharset[(c>>(5*(7-i)))&31])
	}

	return checksum.String(), nil
}

// AddDescriptorChecksum adds a checksum to a descriptor string.
func AddDescriptorChecksum(desc string) (string, error) {
	checksum, err := DescriptorChecksum(desc)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%s#%s", desc, checksum), nil
}
