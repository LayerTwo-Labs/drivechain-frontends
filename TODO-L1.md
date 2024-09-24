# BitWindow TODO

Drivechain-Qt elements to implement:

#### Core Bitcoin features:
- [X] Latest transactions / mempool viewer
- [X] Latest blocks list
- [X] Block explorer
- [X] Wallet (Create, view, send, receive)
- [X] View bitcoin network statistics

#### Sidechain-specific features:
- [ ] View list of sidechains
- [ ] Propose sidechains
- [ ] Deposit to sidechains
- [ ] View list of sidechain withdrawals 
- [ ] View list of your sidechain deposits
- [ ] Set withdrawal bundle ACK settings
- [ ] View sidechain proposals
- [ ] Sidechain proposal ACK settings

#### Advanced but important features:
- [ ] Deniability
- [ ] Coin News (view, create, manage settings, import & export types)

#### Deprioritized features:
- [ ] Graffiti Explorer & creator (OP_RETURN text encoding viewer & creator)
- [ ] Multisig lounge
- [ ] OP_RETURN file backup
- [ ] Sign & verify messages
- [ ] View mining pool info / statistics
- [ ] Hash Calculator
- [ ] Merkle tree viewer
- [ ] Base58 decoder / encoder
- [ ] Paper wallet (create, print)
- [ ] Address book (wallet)
- [ ] Write a check
- [ ] Timestamp files
- [ ] Chain merchants
- [ ] Proof of funds

# RPCs that would be helpful from CUSF client
Some interface for setting withdrawal bundle ACK / NACK / ABSTAIN, and to list your current vote settings and to reset those settings. The current version has 3 rpcs for this, but it could be done however you want.
- [ ] clearwithdrawalvotes
- [ ] listwithdrawalvotes
- [ ] setwithdrawalvote

  
For withdrawal bundles BitWindow will need to get their work score, a list of failed withdrawals, and a list of paid out withdrawals. The current software uses many RPCs for this, but it can be done however you want. 
- [ ] getworkscore "nsidechain" "hash")
- [ ] havefailedwithdrawal
- [ ] havespentwithdrawal
- [ ] listspentwithdrawals
- [ ] listwithdrawalstatus "nsidechain")
- [ ] listfailedwithdrawals

An interface to create sidechain proposals, and to list activation status of pending proposals       
- [ ] createsidechainproposal
- [ ] getsidechainactivationstatus
- [ ] listsidechainactivationstatus
- [ ] listsidechainproposals

Also a list of currently active sidechains
- [ ] listactivesidechains

BitWindows needs to be able to create and list user-created sidechain deposits at least (Maybe all sidechain deposits???)
- [ ] createsidechaindeposit "nsidechain" "depositaddress" "amount"
- [ ] listsidechaindeposits

BitWindow needs a way to display the current CTIP for each sidechain
- [ ] listsidechainctip