package coinnews

// Topic is the 4-byte ID that scopes Stories.
type Topic [TopicLen]byte

// XOnlyPubKey is a 32-byte BIP-340 x-only secp256k1 public key.
type XOnlyPubKey [XOnlyPubKeyLen]byte

// SchnorrSig is a 64-byte BIP-340 Schnorr signature.
type SchnorrSig [SchnorrSigLen]byte

// TopicCreation announces a topic. Earliest confirmed creation per
// TopicID wins (spec §5).
type TopicCreation struct {
	Topic         Topic
	RetentionDays byte
	Name          string
}

// Story is a Topic-scoped post. Headline is required; everything else
// rides in the TLV section (spec §6).
type Story struct {
	Topic    Topic
	Headline string
	TLVs     []TLV
}

// Comment is a signed reply to another Item (spec §7). Sig MUST cover
// CommentSigHash(Parent, SerialiseTLVs(TLVs)).
type Comment struct {
	Parent    ItemID
	AuthorXPK XOnlyPubKey
	Sig       SchnorrSig
	TLVs      []TLV
}

// Continuation extends a head Message that didn't fit in 80 B (spec §9).
type Continuation struct {
	Head  ItemID
	Seq   byte
	Chunk []byte
}
