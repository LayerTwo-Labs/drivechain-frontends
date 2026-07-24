#!/usr/bin/env python3
"""Hardware-wallet daemon: one JSON request per line in, one response out.

Each command opens the device fresh and closes it, so no libusb handle is held
across the unlock re-enumeration. The Trezor keeps its PIN-entry state in
firmware, so promptpin and sendpin are two independent opens.
"""

import json
import sys

from hwilib import commands
from hwilib.common import Chain
from hwilib.errors import handle_errors

CHAINS = {
    "main": Chain.MAIN,
    "test": Chain.TEST,
    "signet": Chain.SIGNET,
    "regtest": Chain.REGTEST,
}


def _chain(req):
    return CHAINS.get(req.get("chain", "test"), Chain.TEST)


def _log(msg):
    sys.stderr.write("hwi-daemon: %s\n" % msg)
    sys.stderr.flush()


def _open(req):
    # Fingerprint re-enumerates and matches internally; path is for a locked
    # device (PIN entry) that has no fingerprint yet.
    pw = req.get("passphrase") or ""
    fingerprint = req.get("fingerprint") or ""
    path = req.get("device_path") or ""
    if fingerprint:
        client = commands.find_device(password=pw, fingerprint=fingerprint, chain=_chain(req))
    elif path:
        client = commands.get_client(req["type"], path, password=pw, chain=_chain(req))
    else:
        raise ValueError("no device_path or fingerprint given")
    if client is None:
        raise ValueError("device not found")
    return client


def _with_client(req, fn):
    client = _open(req)
    try:
        return fn(client)
    finally:
        try:
            client.close()
        except Exception:
            pass


def _handle(req):
    cmd = req["cmd"]
    _log("cmd=%s type=%s path=%r fp=%r pass=%s" % (
        cmd, req.get("type"), req.get("device_path"), req.get("fingerprint"),
        "yes" if req.get("passphrase") else "no",
    ))

    if cmd == "enumerate":
        return commands.enumerate(password=req.get("passphrase") or "")

    if cmd == "promptpin":
        return _with_client(req, commands.prompt_pin)

    if cmd == "sendpin":
        return _with_client(req, lambda c: commands.send_pin(c, req["pin"]))

    if cmd == "togglepassphrase":
        return _with_client(req, commands.toggle_passphrase)

    if cmd == "getxpub":
        return _with_client(req, lambda c: commands.getxpub(c, req["derivation_path"]))

    if cmd == "signtx":
        return _with_client(req, lambda c: commands.signtx(c, req["psbt"]))

    if cmd == "displayaddress":
        return _with_client(req, lambda c: commands.displayaddress(c, desc=req["descriptor"]))

    if cmd == "close":
        return {"success": True}

    return {"error": "unknown command: %s" % cmd, "code": -1}


def _write(obj):
    try:
        line = json.dumps(obj, default=str)
    except Exception as e:
        line = json.dumps({"error": "unserializable result: %s" % e, "code": -1})
    sys.stdout.write(line + "\n")
    sys.stdout.flush()


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
        except ValueError as e:
            _write({"error": "bad request: %s" % e, "code": -1})
            continue
        result = {}
        with handle_errors(result=result):
            result = _handle(req)
        _write(result)


if __name__ == "__main__":
    main()
