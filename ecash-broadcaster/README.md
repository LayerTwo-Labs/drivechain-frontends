# ecash-broadcaster

A connect server with one endpoint, `BroadcastECashTx`, that broadcasts a signed
eCash transaction to an eCash node's `sendrawtransaction` and returns the txid.

## Run

```sh
just gen      # generate connect stubs from proto
just build    # -> bin/ecash-broadcaster
just run --listen :8090 \
  --bitcoind-host localhost --bitcoind-port 38332 \
  --bitcoind-rpcuser <user> --bitcoind-rpcpassword <pass>
```

## Call

```sh
grpcurl -plaintext -d '{"signed_hex":"..."}' \
  localhost:8090 ecash.v1.ECashBroadcastService/BroadcastECashTx
```
