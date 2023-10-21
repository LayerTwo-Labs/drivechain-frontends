## Sidechain deposit

Generate new SC deposit address.

Format: sN_addr_checksum

https://github.com/LayerTwo-Labs/testchain/blob/ba78df157fcb9f85d898f65db43c2842ab9473ff/src/sidechain.cpp#L206-L229

There's something strange going on for generating.

https://github.com/torkelrogstad/bitcoin/blob/c44e3a737d1780a1a07135657ac0fd7686251933/src/qt/sidechainpage.cpp#L748-L762

1. Get key from pool - looks completely normal
2. Get destination for key - must be 'legacy'
3. Learn related scripts
4. Encode destination
5. Add to address book

Same thing happens in regular Core, just with a specific label.

https://github.com/torkelrogstad/bitcoin/blob/c44e3a737d1780a1a07135657ac0fd7686251933/src/qt/sidechainpage.cpp#L748-L762

## Sidechain withdrawal

Generate new MC deposit address
