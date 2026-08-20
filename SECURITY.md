# Responsible Disclosure Policy

This page is for security researchers who want to report a vulnerability in
Drivechain software. If you are a user with a question about your wallet, your
coins, or a lost password, please open a normal issue or use the community
channels instead — this address is for security reports only.

These applications hold private keys and move real value. We take reports
seriously and we welcome the work of external researchers.

## How to report

**Preferred:** open a private advisory through GitHub —
[report a vulnerability](https://github.com/LayerTwo-Labs/drivechain-frontends/security/advisories/new).
It is encrypted, visible only to maintainers, and keeps the whole exchange in
one place.

**Email:** security@layertwolabs.com

Please **do not** open a public issue, pull request, or forum post for a
security bug before it is fixed.

## Scope

In scope — anything in this repository and the artifacts it produces:

- The desktop clients: BitWindow, Thunder, BitNames, BitAssets, Truthcoin,
  Photon, CoinShift, zSide.
- `sidechain-orchestrator`, `sail_ui`, `sidechain_core`, and `bitwindowd`.
- The build and release pipeline, including the binaries this project
  downloads and launches on a user's machine, and how their authenticity is
  checked.
- The network catalog published at `drivechain.dev/config` and the endpoints it
  points clients at.

Out of scope — report these to the project that owns them:

- **Bitcoin Core itself.** Follow
  [Bitcoin Core's disclosure process](https://bitcoincore.org/en/contact/).
- **BIP300/301 protocol design.** Consensus-level findings belong with the
  specification and the enforcer, not here.
- **Third-party sidechain daemons** not built in this repository.
- Anything hosted or operated by a third party.

## What we are most interested in

Ranked roughly by how much damage they do:

1. Extraction or leakage of seeds, private keys, or xprvs — including into
   logs, crash reports, backups, or the clipboard.
2. Anything that lets a remote party spend, redirect, or burn a user's coins:
   forged deposits or withdrawals, address substitution, or a signing flow that
   signs something other than what the user approved.
3. Remote code execution, or a downloaded binary that isn't the one we
   published.
4. Locally reachable RPC or IPC surfaces that a website or another user account
   on the same machine can drive.
5. Corrupting a user's wallet file or chain data such that funds become
   unrecoverable.

Please do not send us: missing security headers with no exploit path,
self-XSS, dependency advisories with no reachable call path, rate-limiting
observations, or automated scanner output. Most such reports have no realistic
attack scenario — before sending one, consider what an attacker actually gains.

## Safe harbor

We support safe harbor for researchers who:

- Make a good-faith effort to avoid privacy violations, data destruction, and
  interruption or degradation of any service.
- Test only against their own wallets, their own funds, and their own nodes.
  Signet, regtest, and eCash exist for exactly this — use them rather than
  mainnet.
- Stop at the first sign of someone else's personal information, tell us, and
  purge any copy they made.
- Give us reasonable time to fix the issue before telling anyone else.

Work conducted in line with this policy is authorized conduct. We will not
pursue civil action or report it to law enforcement, and if a third party takes
legal action against you for it, we will make clear that your work was
authorized.

If you are unsure whether something is within these bounds, ask us first.

## What happens next

- We aim to acknowledge a report within **3 working days**.
- We will tell you whether we consider it a vulnerability, and our assessment
  of its severity, within **10 working days**.
- We work to a **90-day** coordinated disclosure window by default, shorter if
  the issue is being exploited, longer only by agreement with you.
- We will credit you by name or handle in the advisory and release notes unless
  you would rather stay anonymous.

Because users run these binaries locally, a fix is not finished when it is
merged — it lands when a release ships and users have updated. We will tell you
which release carries the fix.

## Rewards

There is no formal bug bounty programme. We may reward a well-written report of
a genuine, high-impact vulnerability, decided case by case.

## Writing a good report

Include:

- The version or commit, the operating system, and the network (mainnet,
  signet, ecash, regtest).
- Reproduction steps precise enough for us to follow without guessing, and a
  proof of concept where one is possible.
- What an attacker gains, and what they need in order to get it.

One vulnerability per report, please. Social engineering of our users,
contributors, or infrastructure — phishing, vishing, smishing — is not in scope
and is not authorized.
