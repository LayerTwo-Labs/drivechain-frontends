# BitWindow hot path flow designs

## How I picked the paths

I read `bitwindow/lib/routing/router.dart`, the wallet tabs in
`bitwindow/lib/pages/wallet/wallet_page.dart`, and the sidechain tabs in
`bitwindow/lib/pages/sidechains_page.dart`.

Three paths carry almost all the traffic:

1. First run. Three route guards block every other screen.
2. Send bitcoin. The core daily action.
3. Sidechain deposit. The one action no other wallet gives you.

All tokens below come from `sail_ui`. See `SAIL_UI_REFERENCE.md`.

---

## Flow 1 — First run

### What happens today

`router.dart` puts three guards on the root route, in this order:

1. `DataDirGuard` sends the user to `/datadir-setup`.
2. `WalletGuard` sends the user to `/create-another-wallet`.
3. `PasswordGuard` sends the user to `/unlock-wallet`.

Each guard owns a separate full page. The pages do not know about each other.
The user meets three gates, and each gate looks like a fresh start.

Bitcoin Core and the Enforcer do not start here. That button sits on the
Sidechains page, at `sidechains_page.dart:181`. So a new user lands on
Overview with a dead node, an empty balance, and no next step.

### The problem

- The user cannot see how many steps remain.
- The node start hides on a page the new user has no reason to open.
- Overview looks broken on first sight, but nothing is broken.

### The design

Replace three separate pages with one stepper. Four steps, one screen, one
progress rail on the left.

| Step | Title | Primary action | Skip rule |
|---|---|---|---|
| 1 | Data folder | Accept the default path | Auto-pass if the folder exists |
| 2 | Wallet | Create, or restore from seed | Auto-pass if a wallet exists |
| 3 | Seed phrase | Write down 12 words, then re-type 3 | Skip on restore |
| 4 | Node | Start Bitcoin Core and the Enforcer | Auto-pass if both run |

Step 4 is the new part. It holds the node start button that lives on the
Sidechains page today.

### Screen anatomy, step 4

```
+----------------------------------------------------------+
| (1)--(2)--(3)--[4]        BitWindow setup                 |
+----------------------------------------------------------+
|                                                          |
|  Start the node                                          |
|  BitWindow needs Bitcoin Core and the Enforcer.          |
|                                                          |
|  [*] Bitcoin Core        Downloading  62%   ####----     |
|  [ ] Enforcer            Waits for Core                  |
|                                                          |
|  Block 812,004 of 843,110                                |
|  About 4 hours left                                      |
|                                                          |
|  [ Open BitWindow now ]      [ Advanced: edit config ]   |
+----------------------------------------------------------+
```

`Open BitWindow now` stays live during the sync. The user does not wait.
Overview then shows a sync banner instead of an empty balance.

### States

- Download fails: show the error, show a `Retry` button, keep the step open.
- Port in use: name the port, link to `/bitcoin-config`.
- Already synced: skip step 4, and go straight to Overview.

---

## Flow 2 — Send bitcoin

### What happens today

`wallet_send.dart` builds `SendTab` from two cards and one button row:

- `PayFromAndFeeCard` — source coins and the fee rate.
- `PayToCard` — destination and amount.
- Buttons: `Send`, `External signer (airgap)`, `Sign with <device>`,
  `Clear All`.

### The problem

- Three of the four buttons sign the same transaction. They read as three
  different actions, but they differ only in the signer.
- The fee sits in the "pay from" card. The amount sits in the "pay to" card.
  The user cannot see the fee and the amount at the same time.
- No review step exists. `Send` broadcasts.

### The design

One primary action. The signer becomes a field, not a button.

```
+----------------------------------------------------------+
|  Send                                                     |
+----------------------------------------------------------+
|  Pay from                                                 |
|  [ Wallet - 0.4213 BTC              v ]                   |
|  Signer  [ This computer            v ]                   |
|            This computer                                  |
|            Airgap (external signer)                       |
|            Ledger Nano S                                  |
|                                                           |
|  Pay to                                                   |
|  [ bc1q...                            ] [Paste] [Scan]    |
|  [ 0.0250          ] BTC     ~ 2,140 NOK                  |
|                                                           |
|  Fee   ( ) Slow 1h   (*) Normal 20m   ( ) Fast 10m        |
|        12 sat/vB - 0.00002 BTC                            |
|                                                           |
|  You send      0.02502 BTC                                |
|  Change back   0.39628 BTC                                |
|                                                           |
|  [ Review ]                              [ Clear all ]    |
+----------------------------------------------------------+
```

`Review` opens a sheet. The sheet repeats the address, the amount, the fee,
the total, and the signer. The sheet holds the only `Sign and broadcast`
button.

### Why a review step

A bitcoin send does not reverse. The review sheet is the last stop. It also
gives the airgap path and the hardware path one shared home.

### States

- Airgap signer: the sheet shows the QR steps in place, not in a new page.
- Hardware signer: the sheet shows "Confirm on your Ledger".
- Broadcast succeeds: show the txid, a copy button, and an explorer link.
- Broadcast fails: keep the sheet open, show the node error, allow a retry.

---

## Flow 3 — Sidechain deposit

### What happens today

Sidechains → Overview lists the 256 slots. A filled slot row shows a
`Deposit` button. The button opens `showDepositModal`.

Two builders make that same button, at `sidechains_page.dart:501` and
`sidechains_page.dart:656`. Both call `showDepositModal` with the same
arguments. The only difference is the disabled tooltip.

A second, larger deposit form lives in `MakeDepositsView`, under the
`Create Deposits` sub-tab. Withdrawals live in `See Withdrawals`, and a
third page holds `Fast Withdrawal`.

### The problem

- Two code paths build one button. They drift apart over time.
- Two deposit forms exist. The user cannot tell which one is correct.
- Withdrawals split across two tabs and one more page.

### The design

One deposit sheet. One withdraw sheet. The slot row is the only entry.

```
+----------------------------------------------------------+
|  Slot 9   Thunder      Running    0.8100 BTC   [Deposit]  |
|  Slot 4   BitNames     Stopped         --      [Start]    |
+----------------------------------------------------------+

  Deposit to Thunder
  +--------------------------------------------------------+
  |  From   Wallet - 0.4213 BTC                            |
  |  To     Thunder - address filled from the running node |
  |         tn1q...                        [Change]        |
  |                                                        |
  |  Amount [ 0.1000        ] BTC   [ Max ]                |
  |  Fee    12 sat/vB - 0.00002 BTC                        |
  |                                                        |
  |  Thunder balance after   0.9100 BTC                    |
  |  Wallet balance after    0.3212 BTC                    |
  |                                                        |
  |  [ Deposit 0.1 BTC ]                    [ Cancel ]     |
  +--------------------------------------------------------+
```

The address auto-fills from the running sidechain. Today the user types it.
That is the largest error source on this path.

The `Change` link opens manual entry, for a deposit to another person.

### States

- Sidechain stopped: the row shows `Start`, not `Deposit`.
- Sidechain starts but does not answer: show "Thunder does not answer" and a
  `Retry` link on the address field.
- Deposit sent: show the txid and the confirmation count, in the same sheet.

### Code cleanup this needs

- Delete one of the two deposit button builders. Keep the one with the
  tooltip.
- Fold `MakeDepositsView` into the sheet.
- Move `Fast Withdrawal` into the withdraw sheet, as a fee option.

---

## What to build first

1. Flow 2 review sheet. It is the smallest change, and it stops real money
   errors.
2. Flow 3 address auto-fill and the duplicate button delete.
3. Flow 1 stepper. It is the largest change, and it touches three guards.
