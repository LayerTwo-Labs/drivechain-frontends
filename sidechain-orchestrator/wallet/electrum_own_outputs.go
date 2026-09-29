package wallet

import (
	"context"
	"fmt"
)

// walletChain names one derivation chain of one script kind.
type walletChain struct {
	kind   ScriptKind
	change bool
}

// addressSpot is where an address sits on a wallet's derivation chains.
type addressSpot struct {
	walletChain
	index uint32
}

// outputsNotOwned lists the output addresses of a scan's transactions that the
// scan does not hold.
func outputsNotOwned(scan *electrumScan) []string {
	owned := make(map[string]bool, len(scan.addrs))
	for _, a := range scan.addrs {
		owned[a.address] = true
	}
	seen := make(map[string]bool)
	var out []string
	for _, a := range scan.addrs {
		for _, tx := range a.txs {
			for _, vout := range tx.Vout {
				addr := vout.ScriptPubKeyAddress
				if addr == "" || owned[addr] || seen[addr] {
					continue
				}
				seen[addr] = true
				out = append(out, addr)
			}
		}
	}
	return out
}

// chainWindows reports how far each chain of a wallet derives for a lookup: the
// whole window past the highest index the scan saw in use.
func (p *ElectrumBackend) chainWindows(w *WalletData, scan *electrumScan) map[walletChain]uint32 {
	windows := make(map[walletChain]uint32)
	for _, kind := range p.receiveKinds(w) {
		for _, change := range []bool{false, true} {
			windows[walletChain{kind, change}] = electrumOwnOutputWindow
		}
	}
	for _, a := range scan.addrs {
		if a.hdPath == "" || !a.stats.Used() {
			continue
		}
		chain := walletChain{a.kind, a.change}
		if _, ok := windows[chain]; !ok {
			continue
		}
		if end := a.index + 1 + electrumOwnOutputWindow; end > windows[chain] {
			windows[chain] = end
		}
	}
	return windows
}

// addressSpots maps each address a wallet derives inside the given windows to
// its place on the chains.
func (p *ElectrumBackend) addressSpots(w *WalletData, windows map[walletChain]uint32) (map[string]addressSpot, error) {
	net := p.params()
	if net == nil {
		return nil, fmt.Errorf("no chain params for this network; cannot derive wallet addresses")
	}
	spots := make(map[string]addressSpot)
	for _, kind := range p.receiveKinds(w) {
		d, err := p.walletDescriptorFor(w, kind)
		if err != nil {
			return nil, err
		}
		for _, change := range []bool{false, true} {
			chain := walletChain{kind, change}
			for i := uint32(0); i < windows[chain]; i++ {
				ds, _, err := d.DeriveScript(change, i, net)
				if err != nil {
					return nil, fmt.Errorf("derive %s/%d: %w", kind, i, err)
				}
				spots[ds.address.EncodeAddress()] = addressSpot{chain, i}
			}
		}
	}
	return spots, nil
}

// spotsFor serves the address map from the per-wallet cache, building it again
// when a chain used an index past the window the cached map covers.
func (p *ElectrumBackend) spotsFor(walletID string, w *WalletData, scan *electrumScan) (map[string]addressSpot, error) {
	windows := p.chainWindows(w, scan)
	p.mu.Lock()
	spots, covered := p.addrSpots[walletID], p.addrSpotWindows[walletID]
	p.mu.Unlock()
	if spots != nil && windowsCover(covered, windows) {
		return spots, nil
	}
	gen := p.chainGeneration()
	spots, err := p.addressSpots(w, windows)
	if err != nil {
		return nil, err
	}
	p.mu.Lock()
	defer p.mu.Unlock()
	// One lock holds the check and the write: a map built against the outgoing
	// chain must never reach the cache.
	if gen != p.generation {
		return nil, fmt.Errorf("network changed while the address map of wallet %s was built", walletID)
	}
	p.addrSpots[walletID] = spots
	p.addrSpotWindows[walletID] = windows
	// A wider map can hold an address the last one missed.
	delete(p.otherAddrs, walletID)
	return spots, nil
}

// unchecked drops the addresses a previous scan already looked up and did not
// find, so a steady wallet derives nothing on a refresh.
func (p *ElectrumBackend) unchecked(walletID string, addresses []string) []string {
	p.mu.Lock()
	others := p.otherAddrs[walletID]
	p.mu.Unlock()
	out := make([]string, 0, len(addresses))
	for _, address := range addresses {
		if !others[address] {
			out = append(out, address)
		}
	}
	return out
}

// rememberOther records the addresses the map does not derive.
func (p *ElectrumBackend) rememberOther(walletID string, addresses []string) {
	if len(addresses) == 0 {
		return
	}
	p.mu.Lock()
	defer p.mu.Unlock()
	if p.otherAddrs[walletID] == nil {
		p.otherAddrs[walletID] = make(map[string]bool)
	}
	for _, address := range addresses {
		p.otherAddrs[walletID][address] = true
	}
}

// windowsCover reports whether a built map reaches through every window asked for.
func windowsCover(covered, want map[walletChain]uint32) bool {
	for chain, end := range want {
		if covered[chain] < end {
			return false
		}
	}
	return true
}

// addOwnOutputs puts an output the wallet derives, but the walk never reached,
// into the scan. Bitcoin Core reserves a change index on every funding call and
// never gives it back, so the change of a send the full node built can sit past
// the gap the walk stops at. Without this the coin reads as a payment out.
func (p *ElectrumBackend) addOwnOutputs(
	ctx context.Context, walletID string, w *WalletData, scan, prior *electrumScan,
) error {
	descriptors := make(map[ScriptKind]*Descriptor)
	added := 0
	for {
		missing := outputsNotOwned(scan)
		if len(missing) == 0 {
			break
		}
		// Ahead of the cached misses: a wider map can hold an address the last
		// lookup missed, and building it clears them.
		spots, err := p.spotsFor(walletID, w, scan)
		if err != nil {
			return err
		}
		missing = p.unchecked(walletID, missing)
		if len(missing) == 0 {
			break
		}
		round := 0
		var others []string
		for _, address := range missing {
			spot, ok := spots[address]
			if !ok {
				others = append(others, address)
				continue
			}
			d, ok := descriptors[spot.kind]
			if !ok {
				if d, err = p.walletDescriptorFor(w, spot.kind); err != nil {
					return err
				}
				descriptors[spot.kind] = d
			}
			a, err := p.deriveAddr(d, spot.change, spot.index)
			if err != nil {
				return err
			}
			if a.address != address {
				others = append(others, address) // map drift — the walk picks it up
				continue
			}
			if err := p.hydrate(ctx, walletID, &a, prior); err != nil {
				return err
			}
			scan.addrs = append(scan.addrs, a)
			round++
		}
		p.rememberOther(walletID, others)
		if round == 0 {
			break
		}
		added += round
	}
	if added > 0 {
		p.log.Info().Str("wallet_id", walletID).Int("addresses", added).
			Msg("the scan added addresses the walk did not reach")
	}
	return nil
}
