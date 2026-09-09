package photon

import (
	"crypto/sha3"
	"encoding/binary"
	"runtime"
	"sync"
)

// SLH-DSA-SHAKE-256s, the parameter set photon signs with. FIPS 205 names
// these: n is the hash width, hPrime the height of one XMSS tree, w the
// Winternitz chain length, and wotsLen the number of chains in one key.
const (
	slhN      = 32
	slhHPrime = 8
	slhLayers = 8
	slhW      = 16
	slhLen    = 67
)

// Address types of FIPS 205.
const (
	typeWotsHash uint32 = 0
	typeWotsPK   uint32 = 1
	typeTree     uint32 = 2
	typeWotsPRF  uint32 = 5
)

// slhAddress is the 32-byte address the SHAKE parameter sets hash with.
type slhAddress [32]byte

func (a *slhAddress) setLayer(v uint32)      { binary.BigEndian.PutUint32(a[0:4], v) }
func (a *slhAddress) setType(v uint32)       { binary.BigEndian.PutUint32(a[16:20], v); clear(a[20:32]) }
func (a *slhAddress) setKeyPair(v uint32)    { binary.BigEndian.PutUint32(a[20:24], v) }
func (a *slhAddress) keyPair() uint32        { return binary.BigEndian.Uint32(a[20:24]) }
func (a *slhAddress) setChain(v uint32)      { binary.BigEndian.PutUint32(a[24:28], v) }
func (a *slhAddress) setTreeHeight(v uint32) { binary.BigEndian.PutUint32(a[24:28], v) }
func (a *slhAddress) setHash(v uint32)       { binary.BigEndian.PutUint32(a[28:32], v) }
func (a *slhAddress) setTreeIndex(v uint32)  { binary.BigEndian.PutUint32(a[28:32], v) }

// slhHash is F, H, PRF and T of the SHAKE parameter sets. All four hash the
// public seed, then the address, then the message.
func slhHash(pkSeed []byte, adrs slhAddress, parts ...[]byte) []byte {
	hasher := sha3.NewSHAKE256()
	hasher.Write(pkSeed)
	hasher.Write(adrs[:])
	for _, part := range parts {
		hasher.Write(part)
	}
	out := make([]byte, slhN)
	hasher.Read(out)
	return out
}

// slhPublicKey is the SLH-DSA public key of a key pair: the public seed and
// the root of the top hypertree layer. The address of a photon wallet hashes
// exactly these bytes.
func slhPublicKey(skSeed, pkSeed []byte) []byte {
	var adrs slhAddress
	adrs.setLayer(slhLayers - 1)
	root := slhTopRoot(skSeed, pkSeed, adrs)
	return append(append([]byte{}, pkSeed...), root...)
}

// slhTopRoot builds the XMSS tree of the top layer and returns its root. The
// leaves cost every hash in the key generation, so they run side by side.
func slhTopRoot(skSeed, pkSeed []byte, adrs slhAddress) []byte {
	leaves := make([][]byte, 1<<slhHPrime)

	var wg sync.WaitGroup
	limit := make(chan struct{}, runtime.NumCPU())
	for leaf := range leaves {
		wg.Add(1)
		limit <- struct{}{}
		go func() {
			defer wg.Done()
			defer func() { <-limit }()
			leafAdrs := adrs
			leafAdrs.setType(typeWotsHash)
			leafAdrs.setKeyPair(uint32(leaf))
			leaves[leaf] = wotsPublicKey(skSeed, pkSeed, leafAdrs)
		}()
	}
	wg.Wait()

	for height := uint32(1); height <= slhHPrime; height++ {
		parents := make([][]byte, len(leaves)/2)
		for i := range parents {
			nodeAdrs := adrs
			nodeAdrs.setType(typeTree)
			nodeAdrs.setTreeHeight(height)
			nodeAdrs.setTreeIndex(uint32(i))
			parents[i] = slhHash(pkSeed, nodeAdrs, leaves[2*i], leaves[2*i+1])
		}
		leaves = parents
	}
	return leaves[0]
}

// wotsPublicKey is the WOTS+ public key of one leaf.
func wotsPublicKey(skSeed, pkSeed []byte, adrs slhAddress) []byte {
	secretAdrs := adrs
	secretAdrs.setType(typeWotsPRF)
	secretAdrs.setKeyPair(adrs.keyPair())

	chains := make([]byte, 0, slhLen*slhN)
	for chain := uint32(0); chain < slhLen; chain++ {
		secretAdrs.setChain(chain)
		secret := slhHash(pkSeed, secretAdrs, skSeed)
		adrs.setChain(chain)
		chains = append(chains, wotsChain(pkSeed, secret, adrs)...)
	}

	keyAdrs := adrs
	keyAdrs.setType(typeWotsPK)
	keyAdrs.setKeyPair(adrs.keyPair())
	return slhHash(pkSeed, keyAdrs, chains)
}

// wotsChain hashes one secret to the end of its Winternitz chain.
func wotsChain(pkSeed, secret []byte, adrs slhAddress) []byte {
	out := secret
	for step := uint32(0); step < slhW-1; step++ {
		adrs.setHash(step)
		out = slhHash(pkSeed, adrs, out)
	}
	return out
}
