# difficulty

Serves a live page of eCash difficulty retargets. It reads block headers from a
local eCash node and applies the consensus rule: from the fork, a retarget
every 288 blocks moves the target one seventh toward the measured window.

```sh
just build
bin/difficulty --rpc-cookie /path/to/.cookie --listen 127.0.0.1:8133
```

`GET /` serves the page. `GET /api/state` serves the data it shows.
