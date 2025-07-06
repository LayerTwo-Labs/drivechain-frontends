# BitWindow TODO

Drivechain-Qt elements to implement:

#### Core Bitcoin features:

- [x] Latest transactions / mempool viewer
- [x] Latest blocks list
- [x] Block explorer
- [x] Wallet (Create, view, send, receive)
- [x] View bitcoin network statistics

#### Sidechain-specific features:

- [x] View list of sidechains
- [ ] Propose sidechains
- [x] Deposit to sidechains
- [ ] View list of sidechain withdrawals
- [x] View list of your sidechain deposits
- [ ] Set withdrawal bundle ACK settings
- [ ] View sidechain proposals
- [ ] Sidechain proposal ACK settings

#### Advanced but important features:

- [x] Deniability
- [x] Coin News (view, create, manage settings, import & export types)

#### Deprioritized features:

- [x] Graffiti Explorer & creator (OP_RETURN text encoding viewer & creator)
- [ ] Multisig lounge
- [x] OP_RETURN file backup
- [ ] Sign & verify messages
- [ ] View mining pool info / statistics
- [x] Hash Calculator
- [ ] Merkle tree viewer
- [x] Base58 decoder / encoder
- [ ] Paper wallet (create, print)
- [x] Address book (wallet)
- [ ] Write a check
- [ ] Timestamp files
- [ ] Chain merchants
- [ ] Proof of funds

# RPCs that would be helpful from CUSF client

Some interface for setting withdrawal bundle ACK / NACK / ABSTAIN, and to list
your current vote settings and to reset those settings. The current version has
3 rpcs for this, but it could be done however you want.

- [ ] clearwithdrawalvotes
- [ ] listwithdrawalvotes
- [ ] setwithdrawalvote

For withdrawal bundles BitWindow will need to get their work score, a list of
failed withdrawals, and a list of paid out withdrawals. The current software
uses many RPCs for this, but it can be done however you want.

- [ ] getworkscore "nsidechain" "hash")
- [ ] havefailedwithdrawal
- [ ] havespentwithdrawal
- [ ] listspentwithdrawals
- [ ] listwithdrawalstatus "nsidechain")
- [ ] listfailedwithdrawals

An interface to create sidechain proposals, and to list activation status of
pending proposals

- [ ] createsidechainproposal
- [ ] getsidechainactivationstatus
- [ ] listsidechainactivationstatus
- [ ] listsidechainproposals

BitWindows needs to be able to create and list user-created sidechain deposits
at least (Maybe all sidechain deposits???)

- [x] createsidechaindeposit "nsidechain" "depositaddress" "amount"
- [x] listsidechaindeposits
