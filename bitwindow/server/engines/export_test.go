package engines

// ExpireNodeModeCache drops the cached mode, so the next read reaches the
// orchestrator. Tests use it in place of a clock.
func ExpireNodeModeCache(n *NodeMode) {
	n.expire()
}
