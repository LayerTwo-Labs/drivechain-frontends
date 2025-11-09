/*
 * Copyright 2010 Jeff Garzik
 * Copyright 2012-2017 pooler
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.  See COPYING for more details.
 */

package cpuminer

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"unsafe"
)

func reverseBytes(p []byte) {
	for i, j := 0, len(p)-1; i < j; i, j = i+1, j-1 {
		p[i], p[j] = p[j], p[i]
	}
}

func decodeHex(p []byte, hexstr string) error {
	if hexstr == "" {
		return errors.New("hex2bin: empty string")
	}

	hexstrLen := len(hexstr)
	if hexstrLen%2 != 0 {
		return errors.New("hex2bin: str truncated")
	}

	binLen := hexstrLen / 2
	if binLen > len(p) {
		return fmt.Errorf("hex2bin: buffer too small (need %d, have %d)", binLen, len(p))
	}

	decoded, err := hex.DecodeString(hexstr)
	if err != nil {
		return fmt.Errorf("hex2bin: invalid hex: %v", err)
	}

	copy(p, decoded)
	return nil
}

// varint_encode encodes a uint64 as a Bitcoin varint
func varint_encode(p []byte, n uint64) int {
	if n < 0xfd {
		p[0] = byte(n)
		return 1
	}
	if n <= 0xffff {
		p[0] = 0xfd
		p[1] = byte(n & 0xff)
		p[2] = byte(n >> 8)
		return 3
	}
	if n <= 0xffffffff {
		p[0] = 0xfe
		for i := 1; i < 5; i++ {
			p[i] = byte(n & 0xff)
			n >>= 8
		}
		return 5
	}
	p[0] = 0xff
	for i := 1; i < 9; i++ {
		p[i] = byte(n & 0xff)
		n >>= 8
	}
	return 9
}

// le32enc encodes little-endian uint32
func le32enc(pp []byte, x uint32) {
	p := (*[4]byte)(unsafe.Pointer(&pp[0]))
	p[0] = byte(x & 0xff)
	p[1] = byte(x >> 8)
	p[2] = byte(x >> 16)
	p[3] = byte(x >> 24)
}

// sha256d performs double SHA-256 hash
func sha256d(hash []byte, data []byte) {
	h := sha256.Sum256(data)
	h2 := sha256.Sum256(h[:])
	copy(hash, h2[:])
}
