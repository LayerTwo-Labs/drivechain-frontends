# Flutter Fast-Withdrawal Implementation Guide

This guide outlines how to reimplement the Godot fast-withdrawal feature in Flutter. We are completely replacing the Godot implementation (net.gd and fast_withdraw.gd) with a Flutter equivalent.

## Overview

1. **Current Godot Implementation**
2. **Current Flutter State**
3. **Implementation Plan**
4. **Mock Bitcoin Client**

---

## 1. Current Godot Implementation

The Godot version consists of two main components:

### net.gd
- Handles all networking logic
- Defines signals for both server and client events:
  * Server: fast_withdraw_requested, fast_withdraw_invoice_paid
  * Client: fast_withdraw_invoice, fast_withdraw_complete
- Provides RPC methods:
  * request_fast_withdraw(amount, destination)
  * receive_fast_withdraw_invoice(amount, destination)
  * invoice_paid(txid, amount, destination)
  * withdraw_complete(txid, amount, destination)

### fast_withdraw.gd
- Handles UI and user interactions
- Connects to Bitcoin client (localhost:8382 or 172.105.148.135:8382)
- Uses net.gd for all network communications
- Updates UI based on network events

---

## 2. Current Flutter State

The Flutter version currently has:
- A basic UI implementation (ToolsPage)
- Dummy methods that simulate network responses
- No real networking implementation

---

## 3. Implementation Plan

### Step 1: Define Message Types
- Create data classes for all network messages
- Match the exact structure of Godot's messages
- Include proper serialization/deserialization

### Step 2: Create Net Service
Replace net.gd functionality:
```dart
class Net {
  // Debug printing
  bool printDebugNet = false;

  // Server signals as Streams
  Stream<(int, double, String)> fastWithdrawRequested;
  Stream<(int, String, double, String)> fastWithdrawInvoicePaid;

  // Client signals as Streams
  Stream<(double, String)> fastWithdrawInvoice;
  Stream<(String, double, String)> fastWithdrawComplete;

  // RPC methods
  Future<void> requestFastWithdraw(double amount, String destination);
  Future<void> receiveFastWithdrawInvoice(double amount, String destination);
  Future<void> invoicePaid(String txid, double amount, String destination);
  Future<void> withdrawComplete(String txid, double amount, String destination);
}
```

### Step 3: Update UI Implementation
- Replace dummy methods with real Net service calls
- Implement proper error handling
- Add connection management
- Update UI based on real network events

---

## 4. Mock Bitcoin Client

Since the actual Bitcoin client isn't ready, we need a mock server that:
- Listens on port 8382 (same as real client)
- Responds to all RPC methods
- Simulates the Bitcoin client's behavior
- Helps test our Flutter implementation

The mock server should:
1. Accept connections (WebSocket)
2. Handle RPC requests
3. Send appropriate responses
4. Simulate network conditions

Example mock response flow:
1. Client connects → Server accepts
2. Client sends request_fast_withdraw → Server generates mock L2 address
3. Client sends invoice_paid → Server generates mock mainchain txid
4. Server sends withdraw_complete

---

## Development Steps

1. **Create Net Service**
   - Implement all RPC methods
   - Set up Stream controllers for signals
   - Add connection management
   - Include debug logging

2. **Update UI**
   - Replace ToolsPageViewModel dummy methods
   - Add proper error handling
   - Implement connection management
   - Update UI based on real events

3. **Create Mock Bitcoin Client**
   - Implement WebSocket server
   - Add request handlers
   - Generate mock responses
   - Include configurable delays/errors for testing

4. **Testing**
   - Test all network operations
   - Verify error handling
   - Confirm UI updates correctly
   - Test with various network conditions

---

## Bottom Line

We are:
1. Completely replacing Godot's implementation with Flutter
2. Creating a proper Net service to handle all networking
3. Building a mock Bitcoin client for testing
4. Maintaining exact compatibility with the Bitcoin client's protocol

The mock Bitcoin client is temporary and will be replaced by the real client once it's ready, but our Flutter implementation will remain the same since it follows the same protocol.