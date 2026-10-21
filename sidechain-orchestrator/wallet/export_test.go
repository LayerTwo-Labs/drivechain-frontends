package wallet

// WaitForBip47Imports blocks until every background bip47 import ends.
func WaitForBip47Imports(b *CoreBackend) {
	b.bip47Imports.Wait()
}
