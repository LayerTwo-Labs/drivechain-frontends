package coinnews

// Magic is the 2-byte prefix every CoinNews payload starts with — see
// spec §1. Lets indexers reject non-CoinNews OP_RETURN traffic with a
// 2-byte prefix scan.
var Magic = [2]byte{'C', 'N'}

// TypeTag identifies the payload that follows Magic. See spec §1.
type TypeTag byte

const (
	TypeTopicCreation TypeTag = 0x01
	TypeStory         TypeTag = 0x02
	TypeComment       TypeTag = 0x03
	TypeUpvote        TypeTag = 0x04
	TypeDownvote      TypeTag = 0x05
	TypeContinuation  TypeTag = 0x06
)

// Sizes used across the wire format. Constants rather than literals so
// the test suite can compare against the BIP envelope budgets without
// re-deriving them.
const (
	MagicLen           = 2
	TypeTagLen         = 1
	TopicLen           = 4
	ItemIDLen          = 12
	XOnlyPubKeyLen     = 32
	SchnorrSigLen      = 64
	OutpointLen        = 36 // 32-byte txid + 4-byte vout LE
	MaxReassembledLen  = 8 * 1024
	ContinuationChunk  = 63
	VoteEnvelopeLen    = MagicLen + TypeTagLen + ItemIDLen + XOnlyPubKeyLen + SchnorrSigLen
	CommentEnvelopeLen = VoteEnvelopeLen
	// HeadlineMaxLen caps Story headlines at 252 bytes — the boundary
	// where compact-size varints jump from one to three bytes. Keeps
	// short headlines in their natural 1-byte length cost without
	// forbidding longer ones (long headlines just pay the 3-byte
	// varint, same as long bodies).
	HeadlineMaxLen = 252
)

// TLVTag values defined in spec §10. Tags 0x80–0xef are reserved for the
// out-of-band metadata registry; 0xf0–0xff for application-private
// extensions.
type TLVTag byte

const (
	TLVURL        TLVTag = 0x01
	TLVBody       TLVTag = 0x02
	TLVLang       TLVTag = 0x03
	TLVNSFW       TLVTag = 0x04
	TLVSubtype    TLVTag = 0x05
	TLVMediaHash  TLVTag = 0x06
	TLVReplyQuote TLVTag = 0x07
)

// Subtype values for the Story `subtype` TLV (tag 0x05).
type Subtype byte

const (
	SubtypeLink Subtype = 0
	SubtypeText Subtype = 1
	SubtypeAsk  Subtype = 2
	SubtypeShow Subtype = 3
	SubtypePoll Subtype = 4
	SubtypeJob  Subtype = 5
)
