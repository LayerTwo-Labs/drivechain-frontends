# CoinNews Protocol

**Status:** Draft &nbsp;·&nbsp; **License:** BSD-2-Clause

CoinNews encodes a topic-scoped bulletin board — stories, threaded
comments, signed votes — inside Bitcoin `OP_RETURN` outputs.
Indexers reach the same view by scanning blocks; no trusted server.
Wire format is engineered for byte-efficiency (Vote = 111 B,
headline-only Story = 6 B + headline) so on-chain footprint per
message stays close to the irreducible signature + reference cost.

## Definitions

| Term      | Meaning                                                                                |
|-----------|----------------------------------------------------------------------------------------|
| Message   | One CoinNews record carried by one `OP_RETURN` push.                                   |
| Topic     | 4-byte ID scoping Stories. First confirmed creation wins the name.                     |
| Item      | A confirmed Message, addressed by its `ItemID` (§4).                                   |
| Author    | A 32-byte BIP-340 x-only pubkey that signed the Message.                               |
| TLV       | Tag-Length-Value tuple carrying optional metadata (URL, language, …).                  |

`OP_RETURN` here means one `OP_RETURN` followed by one `OP_PUSHBYTES`
of up to 80 bytes (the relay default). Vote requires
`-datacarriersize ≥ 111`; longer logical Messages chunk via
Continuation (§9).

## Specification

### 1. Common envelope

Every CoinNews payload begins with a 2-byte magic `"CN"`
(`0x43 0x4E`) followed by a 1-byte **TypeTag**:

```
"CN"(2) ‖ TypeTag(1) ‖ rest…
```

`"CN"` lets indexers reject non-CoinNews `OP_RETURN` traffic with a
2-byte prefix scan. Unknown TypeTags MUST cause the Message to be
ignored — they're reserved for future versions.

| TypeTag | Type             | §  |
|---------|------------------|----|
| `0x01`  | Topic Creation   | 5  |
| `0x02`  | Story            | 6  |
| `0x03`  | Comment          | 7  |
| `0x04`  | Upvote           | 8  |
| `0x05`  | Downvote         | 8  |
| `0x06`  | Continuation     | 9  |
| `0x80…` | Application use  | —  |

### 2. Varint length

CoinNews uses Bitcoin's "compact size" varint for every length field:

| First byte | Value range          | Total width |
|------------|----------------------|-------------|
| `0x00…0xfc`| 0–252                | 1 B         |
| `0xfd`     | 253–65 535           | 3 B (LE)    |
| `0xfe`     | 65 536–2³²−1         | 5 B (LE)    |
| `0xff`     | reserved             | —           |

Most strings cost 1 byte of length prefix; long bodies stay encodable
up to the 8 KiB reassembly cap (§9) at 3 bytes.

### 3. Topic identifiers

A **Topic** is a 4-byte (32-bit) ID. There is no central registry;
the first confirmed Topic Creation (§5) for a given ID wins the
display name. Topic `0x00000000` is reserved for "no topic" / global
items that don't slot into a category.

Topic IDs only appear on Topic Creation and Story; Comment and Vote
inherit topic from the target Item.

### 4. Item identifiers

References to other Items (a Comment's parent, a Vote's target, a
Continuation's head) use **ItemID**:

```
ItemID = sha256(txid_LE(32) ‖ vout_LE(4))[0:12]
```

12 bytes (96 bits). Collision space is 2⁹⁶ — at any plausible
deployment volume the chance of any collision is < 10⁻¹³.
ItemIDs are 24 B shorter than full outpoints; on a 100k-vote board
that saves ≈ 2.4 MB of block space.

#### 4.1 Resolving ItemIDs

ItemIDs are **publisher-computed**, **indexer-resolved** — neither
party needs to invert SHA-256.

* **Publishers** always know the target's full outpoint at write
  time: they're casting a Vote against a Story they're looking at,
  or replying to a Comment they're rendering. They hash the
  outpoint they already have; they never need to "look up" an
  ItemID they don't already own.
* **Indexers** build the reverse map as they scan blocks. Every
  time the scanner accepts a CoinNews Item, it computes that
  Item's own `(txid, vout) → ItemID` and inserts both directions
  into its index:
  ```
  items_by_outpoint  : (txid, vout) → row
  items_by_id        : ItemID       → (txid, vout)
  ```
  When a later Message arrives whose `parent_id` /
  `target_id` / `head_id` isn't in `items_by_id`, the reference is
  unresolvable and the Message MUST be dropped.

Both maps are populated in a single forward pass: an Item must be
scanned (and indexed by ItemID) before any later Message can refer
to it. A fresh indexer bootstrapping from genesis sees Items in
block order, so by the time a Comment with `parent_id = X` arrives,
the Item with that ItemID has already been indexed in some prior
block — provided the publisher waited for that prior block to be
mined before broadcasting (which they MUST, because the target
outpoint doesn't exist until then).

#### 4.2 Permissionless indexing

CoinNews is fully self-describing from on-chain data. An implementer
with nothing but a Bitcoin Core node MUST be able to build the same
view of the board as every other indexer, with no third-party calls,
no registry lookups, and no off-chain seed data. The properties below
are normative; any deviation is a non-conformant implementation.

* **Canonical scan order.** Items are processed in
  `(block_height ASC, tx_index ASC, vout_index ASC)`. This ordering
  is the only rule for "earlier" / "later" anywhere in this spec —
  vote dedup ("later votes from the same author MUST be ignored"),
  Topic-Creation collision ("earliest confirmed creation wins"),
  Continuation `seq` ordering, and any future first-wins / last-wins
  semantics. Re-orgs replay the affected blocks; deterministic output
  follows from deterministic input.
* **Same-block references are legal** if they obey scan order. A
  Comment may reference a Story posted earlier in the same block
  (lower `tx_index`, or same tx with lower `vout_index`). A Vote
  cast against a target in the *same transaction* MUST be at a
  higher `vout_index` than the target.
* **All inputs are on-chain.** Every byte needed to verify a
  Message — Topic name, parent body, author pubkey, signature
  domain, ItemID resolution — is present in some prior `OP_RETURN`
  or in the carrying transaction itself (for Story attribution,
  §6). Implementers MUST NOT depend on the metadata registry
  (§11), any HTTP service, or any pre-shipped database fixture
  to produce a conforming index.
* **Metadata registry is informational only.** §11's tag registry
  is a human-readable dictionary of well-known tag bytes; an
  indexer that has never seen the registry still produces a
  conforming index — it just renders unknown tags as
  `tag_<hex> = <bytes>` rather than friendly names. Two indexers
  with different registry snapshots produce identical Item lists,
  identical scores, identical thread structure; only their UI
  labels for unknown tags differ.
* **No genesis block / no activation height.** CoinNews is
  active for any block whose `OP_RETURN`s match the §1 envelope.
  Indexers SHOULD scan from Bitcoin's genesis on first run; in
  practice, no `"CN"` payloads exist before the first
  CoinNews-aware release, but the spec does not encode that as a
  cutoff. Two indexers starting from different heights agree on
  every Item that exists in their shared range.
* **Determinism budget.** Given a chain tip, the canonical output
  of an indexer is the tuple
  `(items_by_id, votes_by_target_and_author, topics_by_id)`.
  Conforming indexers MUST agree byte-for-byte on this tuple
  modulo serialisation. Anything beyond it (rendered HTML, sort
  caches, search indexes) is implementation-defined.

### 5. Topic Creation

```
"CN" ‖ 0x01 ‖ topic(4) ‖ retention_days(1) ‖ name(varint+UTF-8)
```

`retention_days = 0x00` ⇒ infinite. Earliest confirmed creation per
TopicID wins; later collisions are silently ignored.

### 6. Story

```
"CN" ‖ 0x02 ‖ topic(4) ‖ headline(varint+UTF-8) ‖ tlv*
```

Headline is a varint-prefixed UTF-8 string. The trailing TLV section
(§10) carries optional `url`, `body`, `subtype`, etc. A
headline-only Story is 7 + headline bytes.

Stories are unsigned: attribution falls to the spending transaction's
first input address. Implementations wanting cryptographic authorship
SHOULD treat the author's first Comment on the Story as the
authoritative body.

### 7. Comment

```
"CN" ‖ 0x03 ‖ parent_id(12) ‖ author_xpk(32) ‖ sig(64) ‖ tlv*
```

`author_xpk` is a 32-byte BIP-340 x-only public key. `sig` is the
64-byte BIP-340 Schnorr signature over

```
tagged_hash("CoinNews/Comment", parent_id ‖ tlv_blob)
```

Envelope without TLV = 111 B (fits in a 111-byte OP_RETURN). Any
non-empty body MUST be carried in TLV; long bodies chunk via §9.

Indexers MUST drop Comments whose `parent_id` is unresolvable in the
index, or whose signature fails to verify.

### 8. Vote

```
"CN" ‖ 0x04 ‖ target_id(12) ‖ author_xpk(32) ‖ sig(64)   (upvote)
"CN" ‖ 0x05 ‖ target_id(12) ‖ author_xpk(32) ‖ sig(64)   (downvote)
```

Total: 111 B exactly. Sig is Schnorr over
`tagged_hash("CoinNews/Vote", typetag ‖ target_id)`.

A given `(author_xpk, target_id)` pair counts at most once. Later
votes from the same author against the same target — including flips
from upvote to downvote — MUST be ignored.

### 9. Continuation

```
"CN" ‖ 0x06 ‖ head_id(12) ‖ seq(1) ‖ chunk(≤63)
```

`seq` is 0-indexed and monotonically increasing. Continuations MUST
appear in the head's transaction or a later transaction in the same
block, in `seq` order. The reassembled trailing TLV section MUST NOT
exceed 8 KiB. Out-of-order, gapped, or post-block continuations ⇒
drop the message.

### 10. Metadata (TLV)

Every TLV blob is zero or more concatenated tuples:

```
tag(1) ‖ length(varint) ‖ value(length B)
```

`length = 0` is legal (flag-style tags). Unknown tags MUST be
skipped — varint-prefixed framing makes that safe and forward-
compatible. Duplicate tags are interpreted as a list for
multi-value fields (e.g. multiple `url` tags ⇒ a gallery);
single-value fields (`subtype`, `nsfw`, `lang`) MUST take the first
occurrence and ignore the rest.

The tag-byte namespace is split into three regions:

| Range         | Owner                                         |
|---------------|-----------------------------------------------|
| `0x01…0x7f`   | This spec and its amendments (well-known tags) |
| `0x80…0xef`   | The CoinNews Metadata Registry (see §11)      |
| `0xf0…0xff`   | Application-private; never surfaced as canon  |

Well-known tags defined by this spec:

| Tag    | Field         | Value                                          | Where          |
|--------|---------------|------------------------------------------------|----------------|
| `0x01` | `url`         | UTF-8 absolute URI (RFC 3986)                  | Story, Comment |
| `0x02` | `body`        | UTF-8 free text                                | Story, Comment |
| `0x03` | `lang`        | BCP-47 short tag (`en`, `pt-BR`)               | Story, Comment |
| `0x04` | `nsfw`        | flag (length 0 = sfw, value `0x01` = nsfw)     | Story          |
| `0x05` | `subtype`     | 1 B: `0=link, 1=text, 2=ask, 3=show, 4=poll, 5=job` | Story     |
| `0x06` | `media_hash`  | 32 B SHA-256 of off-chain image/video          | Story          |
| `0x07` | `reply_quote` | UTF-8 excerpt being quoted (≤140 B)            | Comment        |

### 11. Metadata Registry

The space `0x80…0xef` is reserved for **out-of-band registrations**:
new metadata fields can be added without revising this spec. Anyone
who wants a new well-known tag opens a PR against the registry repo
(`github.com/<tbd>/coinnews-metadata-registry`) with:

* the tag byte they're claiming,
* a one-line field name,
* the value encoding,
* the message types it applies to,
* a short rationale.

A registration is "live" once the PR is merged. The registry is the
single source of truth for tag assignments; this spec does NOT need
to be updated for new fields. Existing indexers continue to ignore
registry tags they don't know about — by §10, that's a no-op, not a
parse error.

This separation means CoinNews's payload schema can grow at the
pace of clients (fast) while the on-chain envelope (slow, hard to
revise) stays frozen.

### 12. Identity & signatures

* Authors are 32-byte BIP-340 x-only secp256k1 pubkeys.
* Signatures are BIP-340 Schnorr (64 B) over per-type tagged hashes.
* Spending the OP_RETURN's containing transaction confers no
  authority; the embedded signature is the sole identity proof.
* Stories are unsigned for byte-efficiency on the most common write;
  see §6 for how to layer authorship on top.

### 13. Ranking

Front-page and thread ordering use the Hacker News rank, made part
of the spec so independent indexers agree:

```
score = (upvotes − downvotes − 1) / (age_hours + 2)^1.8
```

`age_hours = max(0, (now − block_time)/3600)`. Items with
`upvotes − downvotes < 0` MAY be hidden from default views but MUST
remain retrievable by ItemID. Comment threads use the same formula
scoped to siblings.

### 14. Retention & fees

Topic Creation's `retention_days` is a hint. Storage-constrained
indexers MAY drop older Items past the hint; full indexers keep
everything.

The miner fee is the only anti-spam mechanism. Wallets SHOULD
surface the per-message fee in the publish flow.

## Rationale

* **`"CN"` magic, not topic-as-magic.** Topic only appears where
  it's load-bearing (creation + Story); Comment/Vote/Continuation
  derive topic from their reference target. Saves 4 bytes on every
  reply and vote.
* **1-byte type tags.** Replaces `"new"` (3 B), `"re"` (2 B),
  `"up"`/`"dn"` (2 B). Saves 1–2 B per Message.
* **12-byte ItemID.** A truncated SHA-256 of `(txid, vout)` is 24 B
  shorter than the full outpoint; collision space at 2⁹⁶ is
  negligible at any plausible CoinNews scale.
* **32-byte x-only pubkeys + Schnorr.** 1 B saved per signed
  Message vs. the 33-byte compressed form, and tagged hashes give
  per-type domain separation without per-type magic strings inside
  the signed payload.
* **Varint length prefixes.** Most fields are short and pay 1 byte
  of overhead; long bodies pay 3. Fixed-width slots wasted bytes
  on the common case.
* **Out-of-band TLV registry.** The on-chain envelope is the
  expensive thing to evolve; the metadata schema isn't. Splitting
  them lets new fields ship at client cadence.
* **Vote dedup per `(author, target)`.** Without it, capital buys
  ranking; with it, only persuading other authors moves the front
  page.

## Reference Implementation

The Go codec at `bitwindow/server/coinnews/` covers all six message
types, the TLV layer, ItemID truncation, and BIP-340 Schnorr verify
with per-type tagged hashes.

## Test Vectors

```
# Topic Creation: "Hacker News", 30-day retention, topic 0x484e5321
"CN" ‖ 01 ‖ 484e5321 ‖ 1e ‖ 0b "Hacker News"
hex: 434e0148 4e53211e 0b48 6163 6b65 7220 4e65 7773
total: 18 B
```

```
# Story: link post in topic 0x484e5321
#   headline = "Microsoft and OpenAI end revenue-sharing deal" (45 B)
#   tlv      = subtype=link(05 01 00), url=<53 B URL>(01 35 …)
"CN" ‖ 02 ‖ 484e5321 ‖ 2d <headline 45 B>
       ‖ 05 01 00                 ; subtype=link
       ‖ 01 35 <url 53 B>         ; url
total: 2 + 1 + 4 + 1 + 45 + 3 + 2 + 53 = 111 B
```

```
# Vote: upvote of an Item with target_id 12 B
"CN" ‖ 04 ‖ <12 B target_id> ‖ <32 B author_xpk> ‖ <64 B sig>
total: 111 B exact
```
