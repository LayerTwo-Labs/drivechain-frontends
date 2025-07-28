# Multisig and Enforcer Wallet Compatibility

## Overview

This document explains the compatibility between the BitWindow multisig implementation and the BIP300/301 enforcer wallet, including limitations and recommended approaches.

## Key Compatibility Issues

### 1. Derivation Path Constraints

**Enforcer Wallet:**
- Fixed to BIP84 paths: `m/84'/1'/0'/0/*` (external) and `m/84'/1'/0'/1/*` (internal)
- Cannot derive keys at custom paths (e.g., `m/84'/1'/0'/0/8000+`)
- Single account structure (account 0 only)

**Multisig Requirements:**
- Participants need to coordinate key derivation
- Each participant contributes their public key
- Keys can come from any derivation path

### 2. Script Type Mismatch

**Enforcer Wallet:**
- Only supports P2WPKH (single-signature) addresses
- Descriptors: `wpkh(xpriv/84'/1'/0'/0/*)`
- Cannot sign for P2WSH (witness script hash) addresses

**Multisig Requirements:**
- Requires P2WSH for `wsh(sortedmulti(m, pubkey1, pubkey2, ..., pubkeyn))`
- Native SegWit multisig addresses start with `bc1q...` (longer than P2WPKH)

### 3. PSBT Signing Limitations

**Enforcer Wallet:**
- Can only sign inputs that match its P2WPKH descriptors
- Foreign UTXO feature requires matching descriptor patterns
- Cannot participate in multisig PSBT signing

**Multisig Requirements:**
- All m-of-n participants must sign the PSBT
- Requires coordination between participants
- Each participant signs with their respective key

## Recommended Implementation Approach

### 1. Separate Key Management

For multisig participation, users should:

1. **Generate Keys Externally:**
   ```bash
   # Use Bitcoin Core or another tool to generate keys
   bitcoin-cli -regtest getnewaddress "" "bech32"
   bitcoin-cli -regtest dumpprivkey <address>
   ```

2. **Use Standard Derivation Paths:**
   - Stick to BIP84 standard paths when possible
   - External keys: `m/84'/1'/0'/0/0`, `m/84'/1'/0'/0/1`, etc.
   - Avoid custom high-index paths like `/8000+`

### 2. PSBT Coordination Workflow

1. **Create Multisig Address:**
   ```python
   # Example using Bitcoin Core
   bitcoin-cli createmultisig 2 '["pubkey1", "pubkey2", "pubkey3"]'
   ```

2. **Fund the Address:**
   - Send funds to the generated P2WSH address
   - Enforcer wallet can track but not spend these UTXOs

3. **Create and Sign PSBT:**
   ```bash
   # Create PSBT
   bitcoin-cli createpsbt '[{"txid":"...", "vout":0}]' '[{"address":amount}]'
   
   # Each participant signs
   bitcoin-cli walletprocesspsbt <psbt>
   
   # Combine signatures
   bitcoin-cli combinepsbt '["psbt1", "psbt2"]'
   
   # Finalize and broadcast
   bitcoin-cli finalizepsbt <combined_psbt>
   bitcoin-cli sendrawtransaction <hex>
   ```

### 3. Enforcer Wallet Role

The enforcer wallet can:
- ✅ Track multisig addresses (watch-only)
- ✅ Monitor UTXO balances
- ✅ Provide fee estimates
- ✅ Broadcast finalized transactions

The enforcer wallet cannot:
- ❌ Generate multisig addresses directly
- ❌ Sign multisig PSBTs
- ❌ Derive keys at custom paths

## Implementation Status

### Current Features
- ✓ Multisig group creation and management
- ✓ Public key collection interface
- ✓ Group data persistence
- ✓ Balance tracking framework

### Requires External Tools
- ⚠️ Actual multisig address generation (needs Bitcoin Core RPC)
- ⚠️ PSBT creation and signing
- ⚠️ Key derivation at specific paths

### Future Enhancements

1. **Bitcoin Core Integration:**
   - Direct RPC calls for multisig operations
   - Automated PSBT creation
   - Descriptor import/export

2. **External Signer Support:**
   - Hardware wallet integration
   - Air-gapped signing workflows
   - QR code PSBT transfer

3. **Custom Wallet Instance:**
   - Separate BDK wallet for multisig operations
   - Custom descriptor support
   - Flexible derivation paths

## Best Practices

1. **Key Generation:**
   - Use standard BIP84 paths when possible
   - Document derivation paths clearly
   - Keep keys secure and backed up

2. **PSBT Workflow:**
   - Test with small amounts first
   - Verify all inputs and outputs
   - Coordinate signing securely

3. **Address Verification:**
   - Always verify multisig addresses independently
   - Check descriptor checksums
   - Confirm with all participants

## Security Considerations

1. **Key Storage:**
   - Multisig keys should be stored separately
   - Consider hardware wallets for participants
   - Never share private keys

2. **Communication:**
   - Use secure channels for PSBT exchange
   - Verify participant identities
   - Check transaction details carefully

3. **Backup:**
   - Store multisig configuration securely
   - Back up all participant public keys
   - Document the m-of-n scheme clearly

## Conclusion

While the enforcer wallet has limitations for direct multisig participation, it can still play a valuable role in tracking and broadcasting. The implementation provides a framework for multisig group management, with actual signing operations handled through external tools or future Bitcoin Core integration.