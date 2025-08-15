# Bitwindow Multisig Tool - User Guide

## Overview

Bitwindow's Multisig Tool enables secure Bitcoin multisignature wallet management with an intuitive interface. This guide walks you through each modal and workflow step-by-step.

*You must have a funded L1 wallet to create a multisig group*   https://node.drivechain.info/#/faucet

---

## Getting Started

### Accessing the Multisig Tool
1. Launch Bitwindow
2. Navigate to **Wallet** → **Multisig Lounge**


The interface shows:
- **Multisig Groups** table: Your created/imported groups
- **Multisig Transactions** table: Transaction history and pending signatures
- **Group Tools** panel: Create, import, and manage groups
- **Transaction Tools** panel: Create, sign, and broadcast transactions

---

## Creating a Multisig Group

### Step 1: Create New Group Modal

Click **"Create New Group"** to open the group creation modal.


Fill in:
- **Group Name**: Descriptive name (e.g., "Family Savings")
- **Required Signatures (m)**: Signatures needed to spend
- **Total Keys (n)**: Total number of participants
- **Do not broadcast**: Whether to save the group locally only (not broadcast to network) 

### Step 2: Adding Public Keys

After setting parameters, you'll add public keys for all participants.


**Adding Your Wallet Key:**
- Click **"Generate Wallet xPub"**
- Your key is automatically generated and marked as "MyKey" but the name is encouraged to be changed

**Importing External Keys:**
- Click **"Import Key"** 
- Choose import method:
  - **Manual Entry**: Paste xpub and derivation path
  - **JSON/CONF File**: Import from exported key file


Each key displays:
- Owner name
- xpub preview
- Derivation path
- Wallet icon (for your keys)

### Step 3: Finalizing Group Creation

Once you have all required keys (progress shows X/N), click **"Save Multisig Group"**.

The system will:
- Generate Bitcoin descriptors
- Create watch-only wallet
- Save group configuration
- Display in your groups list

---

## Exporting Your Public Key

### Get Key Modal

To share your public key with other participants, click **"Get Key"** in Group Tools.


The modal shows:
- Next available key index 
- Generated key information including:
  - Key Name (editable)
  - Extended Public Key (xpub)
  - Derivation Path
  - Key Fingerprint
  - Origin Path
- Export options:
  - **Copy to Clipboard**: Quick sharing
  - **Save Key**: Export as CONF file for sharing

---

## Funding Your Multisig Group

### Fund Group Modal

Select your multisig group and click **"Fund Group"** to get a receiving address.


The modal displays:
- Group selection (if multiple groups available)
- Group information (name, signature requirements)
- Fresh receiving address for deposits

**Funding Process:**
1. Copy the address
2. Send Bitcoin from your regular wallet or exchange
3. Wait for confirmation (1-6 confirmations recommended)
4. Balance updates automatically in the groups table



---

## Creating Transactions

### PSBT Coordinator Modal

Click **"Create Transaction"** to open the transaction creation modal.


Configure transaction details:
- **Group Selection**: Choose funded group (if multiple available)
- **Destination Address**: Recipient Bitcoin address
- **Amount**: BTC amount to send (or click "MAX" for maximum)
- **Fee**: Automatically calculated and deducted from amount

Click **"Create Transaction"** to generate the initial PSBT. The transaction will appear in the transactions table with "Needs Signatures" status.

If you have wallet keys in the group, you can immediately click **"Sign with My Keys"** to sign the transaction.

---

## Signing Transactions

### Sign Preview Modal

For transactions with your wallet keys, click **"Sign"** to open the signing preview modal.


The modal shows:
- **Transaction Details**: Amount, destination, fee, transaction ID
- **Signing Information**: Current signatures count and available wallet keys
- **Key Status**: Visual status for each key (Signed, Ready to sign, Awaiting external signature)

Review the transaction details carefully, then click **"Sign Transaction"** to sign with your wallet keys. The transaction status updates based on signature count.

### Transaction Details Modal

Click **"View"** on any transaction to see detailed information and manage PSBTs.


The modal includes:
- Complete transaction information
- Signature progress tracking
- **Export PSBTs** section with:
  - Initial PSBT (unsigned)
  - Individual participant PSBTs
  - Combined PSBT
- Export buttons for each PSBT type

---

## Importing External PSBTs

### Import PSBT Modal

For external signers, use **"Import PSBT"** to upload signed PSBTs.


The modal allows:
- Group selection for the PSBT
- File selection for signed PSBT .json files  
- Automatic signature validation and key detection
- Transaction status updates

**External Signing Process:**
1. Export PSBT from Transaction Details
2. Sign with hardware wallet or external software
3. Import the signed PSBT back into Bitwindow

---

## Broadcasting Transactions

### Combine & Broadcast Modal

Click **"Combine & Broadcast"** to finalize and send transactions.


The modal shows:
- Available transactions ready for processing
- Transaction selection
- Group and signature information
- Current transaction status
- Action button (Combine/Broadcast based on status)

**Broadcasting Requirements:**
- Transaction has M or more valid signatures
- Status shows "Ready for Broadcast"
- PSBT passes final validation

---

## Importing Groups

### Import from TXID Modal

Use **"Import from TXID"** to restore or join existing multisig groups.


The modal provides:
- TXID input field with paste button
- **"Import"** button to fetch and process data
- Automatic key detection and wallet key validation
- Progress indicators during import process

**Import Process:**
1. Enter transaction ID containing multisig data
2. Click **"Import"**
3. System validates OP_RETURN data and detects your wallet keys  
4. Automatic wallet key validation and group setup
5. Group is imported and synced automatically

---

## Transaction States Guide

Transactions progress through these states:

- **Needs Signatures**: Initial state, no signatures collected
- **Awaiting Signed PSBTs**: Some signatures collected but not enough
- **Ready to Combine**: Sufficient signatures collected, needs PSBT combining
- **Ready for Broadcast**: PSBT finalized and ready to send
- **Broadcasted**: Sent to Bitcoin network, awaiting confirmations
- **Confirmed**: Has at least 1 confirmation in blockchain
- **Completed**: Fully processed transaction
- **Voided**: Transaction cancelled or failed

The system automatically updates transaction status as signatures are collected and PSBTs are processed.

---

## Security Best Practices

### Key Management
- Never share private keys - only share xpubs and derivation paths
- Verify public keys through multiple channels
- Backup group configurations and seed phrases

### Transaction Security
- Verify amounts and addresses before signing
- Check fee rates are reasonable
- Wait for adequate confirmations (6+ for large amounts)

---
