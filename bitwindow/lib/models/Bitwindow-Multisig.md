# Bitwindow Multisig Tool - Complete User Guide

## Table of Contents
1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Creating Your First Multisig Group](#creating-your-first-multisig-group)
4. [Managing Public Keys](#managing-public-keys)
5. [Funding Your Multisig Group](#funding-your-multisig-group)
6. [Creating Transactions](#creating-transactions)
7. [Signing Transactions](#signing-transactions)
8. [Broadcasting Transactions](#broadcasting-transactions)
9. [Advanced Features](#advanced-features)
10. [Troubleshooting](#troubleshooting)
11. [Security Best Practices](#security-best-practices)

---

## Overview

Bitwindow's Multisig Tool enables secure Bitcoin multisignature wallet management with features including:

- **M-of-N Multisig Creation**: Create customizable multisig groups (e.g., 2-of-3, 3-of-5)
- **PSBT Workflow**: Full Partially Signed Bitcoin Transaction support
- **Key Management**: Import/export public keys and coordinate with multiple participants
- **Transaction Coordination**: Create, sign, and broadcast multisig transactions
- **Watch-Only Wallets**: Monitor balances and transaction history
- **Import/Export**: TXID-based group restoration and PSBT file management

---

## Getting Started

### Prerequisites
- Bitwindow application installed and running
- Bitcoin Core node connected
- Basic understanding of Bitcoin multisig concepts

### Accessing the Multisig Tool
1. Launch Bitwindow
2. Navigate to **Wallet** → **Multisig Lounge**
3. The interface displays two main sections:
   - **Multisig Groups**: Your created/imported multisig groups
   - **Multisig Transactions**: Transaction history and pending signatures

---

## Creating Your First Multisig Group

### Step 1: Basic Setup
1. Click **"Create New Group"** in the Group Tools panel
2. Fill in the group details:
   - **Group Name**: A descriptive name (e.g., "Family Savings")
   - **Required Signatures (m)**: Number of signatures needed to spend
   - **Total Keys (n)**: Total number of participants
   - **Encryption**: Choose whether to encrypt the multisig data

### Step 2: Key Configuration Examples

#### 2-of-3 Multisig (Recommended for beginners)
- **Required Signatures**: 2
- **Total Keys**: 3
- **Use Case**: Personal backup with trusted third party

#### 3-of-5 Multisig (Business/Organization)
- **Required Signatures**: 3
- **Total Keys**: 5
- **Use Case**: Company treasury requiring majority approval

### Step 3: Adding Public Keys
After setting parameters, you'll proceed to key import:

1. **Add Your Wallet Key** (if you have a seed phrase):
   - Click **"Add Wallet Key"**
   - Your key will be automatically generated and marked as "MyKey"

2. **Import External Keys**:
   - Click **"Import Public Key"**
   - Choose from multiple import methods:
     - **Manual Entry**: Paste xpub and derivation path
     - **JSON File**: Import from exported key file

3. **Key Validation**:
   - Each key shows owner name, xpub preview, and derivation path
   - Wallet keys are automatically marked with a wallet icon
   - Remove incorrect keys with the trash icon

### Step 4: Finalizing Group Creation
1. Ensure you have all required keys (progress shows X/N)
2. Click **"Create Multisig Group"**
3. The system will:
   - Generate Bitcoin descriptors
   - Create watch-only wallet
   - Save group configuration
   - Broadcast to the blockchain for restoration
   - Display in your groups list

---

## Managing Public Keys

### Exporting Your Public Key
To share your public key with other participants:

1. Click **"Get Key"** in Group Tools
2. Select your wallet account index
3. Choose export format:
   - **Copy to Clipboard**: Quick sharing
   - **JSON File**: Structured data for import

### Key Information Includes:
- **Owner**: Your chosen identifier
- **Extended Public Key (xpub)**: The actual key data
- **Derivation Path**: Key generation path (e.g., m/84'/1'/8000')
- **Fingerprint**: Wallet identification
- **Origin Path**: Root derivation information

### Import Methods for External Keys

#### Method 1: Manual Entry
```
Owner: Alice
xpub: xpub6D5sYKhn8sHJW...
Derivation Path: m/84'/1'/8001'
```

#### Method 2: JSON Import
```json
{
  "owner": "Bob",
  "xpub": "xpub6D5sYKhn8sHJW...",
  "path": "m/84'/1'/8002'",
  "fingerprint": "12345678",
  "origin_path": "84'/1'/8002'"
}
```

#### Method 3: Shared Text Format
```
Multisig Participant Key
Owner: Charlie
Extended Public Key: xpub6D5sYKhn8sHJW...
Derivation Path: m/84'/1'/8003'/0
Fingerprint: 87654321
Origin Path: 84'/1'/8003'
```

---

## Funding Your Multisig Group

### Getting a Receiving Address
1. Select your multisig group from the groups table
2. Click **"Fund Group"** in Group Tools
3. The modal displays:
   - **Group Information**: Name, signature requirements
   - **Receiving Address**: Fresh address for deposits

### Address Types
- **Receive Addresses**: External payments and deposits
- **Address Index**: Automatically increments for privacy

### Funding Process
1. **Copy the address**
2. **Send Bitcoin** from your regular wallet or exchange
3. **Wait for confirmation** (1-6 confirmations recommended)
4. **Balance updates** automatically in the groups table

### Monitoring Deposits
- **Balance Column**: Shows current confirmed balance
- **UTXOs Column**: Number of unspent transaction outputs
- **Transaction History**: All deposits appear in the transactions table

---

## Creating Transactions

### Prerequisites for Spending
- Multisig group with confirmed balance
- At least M participants ready to sign
- Destination address and amount determined

### Step 1: Initialize Transaction
1. Click **"Create Transaction"** in Transaction Tools
2. The PSBT Coordinator modal opens with:
   - **Group Selection**: Choose funded group
   - **Transaction Details**: Amount and destination
   - **Fee Settings**: Automatic or manual fee selection

### Step 2: Transaction Configuration

#### Basic Settings
- **Recipient Address**: Destination Bitcoin address
- **Amount**: BTC amount to send (max shows available balance)
- **Fee Rate**: sat/vB


### Step 3: PSBT Generation
1. Click **"Create Transaction"** in Transaction Tools
2. Select multisig group (if not pre-selected)
3. Enter transaction details:
   - **Destination Address**: Bitcoin address to send funds to
   - **Amount**: BTC amount (or click "MAX" for maximum spendable)
   - **Fee**: Automatically calculated by Bitcoin Core
4. Click **"Create Transaction"** to generate initial PSBT
5. Transaction appears in transactions table with "Needs Signatures" status
6. Optionally sign immediately with wallet keys if available

### Transaction States
The system uses these precise transaction states:
- **Needs Signatures**: Initial state, no signatures collected yet
- **Awaiting Signed PSBTs**: Some signatures collected but not enough
- **Ready to Combine**: Sufficient signatures collected, needs combining
- **Ready for Broadcast**: PSBT is finalized and ready to send
- **Broadcasted**: Sent to Bitcoin network, awaiting confirmations
- **Confirmed**: Has at least 1 confirmation in blockchain
- **Completed**: Fully processed transaction
- **Voided**: Transaction cancelled or failed

---

## Signing Transactions

### Who Can Sign?
- Participants with wallet keys in the multisig group
- Must have the private key/seed phrase corresponding to their public key
- Wallet must be unlocked and accessible

### Signing Process

#### Automatic Signing (Wallet Keys)
1. Locate the transaction in the transactions table
2. Click **"Sign"** button (appears only for signable transactions with your keys)
3. Sign Preview Modal appears showing:
   - **Transaction details**: Amount, destination, fee
   - **Group information**: M-of-N requirement
   - **Your signing key(s)**
   - **Current signature status**
4. Click **"Confirm & Sign"**
5. System uses `MultisigRPCSigner` to sign PSBT with Bitcoin Core
6. Transaction status updates based on signature count:
   - Updates to "Awaiting Signed PSBTs" if more signatures needed
   - Updates to "Ready to Combine" if sufficient signatures collected

#### Manual PSBT Process (External Signers)
1. **View Transaction Details**:
   - Click **"View"** on any transaction
   - Transaction Details modal opens

2. **Export PSBT**:
   - In "Export PSBTs" section, find the PSBT you need:
     - **Initial PSBT (unsigned)**: Base transaction template
     - **[KeyName] PSBT**: Individual participant's PSBT
   - Click **"Export"** next to desired PSBT
   - Save the .json file containing PSBT data

3. **External Signing**:
   - Use your hardware wallet or external software
   - Import and sign the PSBT
   - Export the signed PSBT

4. **Import Signed PSBT**:
   - Click **"Import PSBT"** in Transaction Tools
   - Select the signed PSBT .json file
   - System validates signatures using `PSBTValidator`
   - Updates transaction status automatically

### Signature Tracking
Each transaction displays:
- **Signatures Progress**: X/M format (e.g., 2/3 signatures)
- **Individual Key Status**: Shows which participants have signed
- **Wallet Key Indicator**: Your keys highlighted differently
- **Timestamp**: When each signature was added

---

## Broadcasting Transactions

### When Can You Broadcast?
- Transaction has M or more valid signatures (verified by `finalizepsbt`)
- Status shows "Ready for Broadcast"
- PSBT passes final validation checks

### Broadcasting Methods

#### Method 1: Direct Broadcast
1. Find transactions with "Ready for Broadcast" status
2. Click **"Broadcast"** button in the action column
3. Transaction is immediately sent to Bitcoin network
4. Status updates to "Broadcasted" with TXID

#### Method 2: Combine & Broadcast Modal
1. Click **"Combine & Broadcast"** in Transaction Tools
2. **Combine & Broadcast Modal** opens showing:
   - All eligible transactions (Ready to Combine or Ready for Broadcast)
   - Transaction selection dropdown
   - Group and signature information
3. Select transaction to broadcast
4. Click **"Broadcast Transaction"**
5. System combines PSBTs if needed, then broadcasts

### Post-Broadcast Monitoring
- **Transaction Status**: Updates to "Broadcasted" immediately
- **TXID Display**: Bitcoin transaction ID shown in table and details
- **Confirmation Tracking**: System monitors blockchain confirmations
- **Balance Updates**: Group balance refreshes when transaction confirms
- **Historical Record**: Transaction becomes part of permanent group history

### Confirmation Levels
- **0 confirmations**: In mempool, not yet in block
- **1+ confirmations**: Included in blockchain
- **6+ confirmations**: Generally considered final on Bitcoin

---

## Advanced Features

### Group Import/Export

#### Import Multisig Group via TXID
Use this to restore or join an existing multisig group:

1. Click **"Import from TXID"** in Group Tools
2. **Import Modal** opens - enter the transaction ID containing multisig data
3. Click **"Fetch Multisig Data"** to query blockchain
4. System extracts OP_RETURN data and validates:
   - Multisig flag presence (0x02)
   - Encryption status (encrypted groups cannot be imported)
   - JSON structure with group configuration
5. **Automatic Wallet Detection**:
   - System checks if any group keys belong to your wallet
   - Keys with matching derivation paths are flagged as "Wallet Key"
   - External keys are flagged as "External Key"
6. Review detected keys and group information
7. Click **"Import Group"** to save locally
8. System creates watch-only wallet with descriptors for monitoring

#### Export Group Information
Share group details with other participants:
- Group configuration saved in `bitdrive/multisig/multisig.json`
- Contains all public keys and descriptors
- Can be shared for group reconstruction

### PSBT File Management

#### Export PSBTs
Each transaction stores multiple PSBT states:
- **Initial PSBT**: Unsigned template
- **Participant PSBTs**: Individual signed versions
- **Combined PSBT**: Final merged version

#### Import External PSBTs
Support for PSBT files from:
- Hardware wallets (Ledger, Trezor, etc.)
- Software wallets (Electrum, Specter, etc.)
- Other Bitwindow instances

### Wallet Integration

#### HD Wallet Detection
- **Automatic Key Recognition**: When loading multisig groups, system automatically checks if any keys belong to your wallet
- **Derivation Path Matching**: Validates keys against your seed phrase using exact derivation paths
- **Wallet Flag Updates**: Sets `isWallet: true` for owned keys, enabling automatic signing
- **Account Index Range**: Searches account indices 8000-8099 for wallet-generated keys

#### Key Restoration Process
1. **Initial Validation**: `_validateAndFixWalletFlags()` runs at startup
2. **Key Matching**: For each group key, system attempts derivation using stored path
3. **XPub Comparison**: Generated xpub compared with group key's xpub
4. **Flag Updates**: Matching keys get updated with wallet metadata
5. **Transaction History**: Wallet groups automatically restore transaction history
6. **Balance Sync**: Group balances update from Bitcoin Core wallet data

---

## Troubleshooting

### Common Issues and Solutions

#### "No wallet keys found in group"
- **Cause**: Your seed phrase doesn't match any keys in the multisig
- **Solution**: Verify you're using the correct wallet or import the group correctly

#### "Transaction signing failed"
- **Cause**: Wallet not initialized or incorrect derivation path
- **Solution**: Ensure wallet is unlocked and keys match group configuration

#### "PSBT validation failed"
- **Cause**: Corrupted or incompatible PSBT file
- **Solution**: Re-export the PSBT or use a different signing method

#### "Insufficient balance"
- **Cause**: Trying to spend more than available or fees too high
- **Solution**: Check group balance and reduce amount or fees

#### "Group creation failed"
- **Cause**: Invalid parameters or duplicate keys
- **Solution**: Verify M ≤ N and all keys are unique

### File Locations
- **Multisig Groups**: `bitdrive/multisig/multisig.json`
- **Transactions**: `bitdrive/transactions.json`
- **Bitcoin Core Wallets**: Bitcoin data directory

### Recovery Options

#### Reset Wallet State
If groups or transactions become corrupted:
1. Backup your data files
2. Delete problematic JSON files
3. Restart Bitwindow
4. Re-import groups via TXID if needed

#### Emergency Recovery
- Keep backup copies of group configurations
- Save initial PSBTs for incomplete transactions
- Document all TXIDs for group reconstruction

---

## Security Best Practices

### Key Management
1. **Never share private keys**: Only share xpubs and derivation paths
2. **Verify public keys**: Confirm keys through multiple channels
3. **Use hardware wallets**: For high-value multisig groups
4. **Backup everything**: Group configs, PSBTs, and seed phrases

### Transaction Security
1. **Verify amounts**: Double-check transaction details before signing
2. **Validate addresses**: Confirm destination addresses independently
3. **Check fees**: Ensure reasonable fee rates
4. **Monitor confirmations**: Wait for adequate confirmations

### Operational Security
1. **Secure communications**: Use encrypted channels for coordination
2. **Role separation**: Different people for different keys
3. **Regular testing**: Test with small amounts first
4. **Update software**: Keep Bitwindow and Bitcoin Core updated

### Backup Strategy
1. **Seed phrases**: Secure offline storage for all participants
2. **Group configurations**: Multiple copies of multisig.json
3. **PSBT archive**: Save important transaction PSBTs
4. **Documentation**: Record group details and participant contacts

---

## Conclusion

The Bitwindow Multisig Tool provides enterprise-grade Bitcoin multisig functionality with an intuitive interface. By following this guide, you can securely create, manage, and operate multisig wallets for personal, business, or organizational use.

For additional support or advanced use cases, consult the Bitwindow documentation or community resources.

**Remember**: Multisig security depends on proper key management and participant coordination. Always test with small amounts before committing significant funds.