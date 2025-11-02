#!/usr/bin/env python3
"""Remove legacy Bitcoin Core RPC methods from mock file."""

legacy_methods = [
    "AddMultisigAddress",
    "DumpPrivKey",
    "DumpWallet",
    "ImportAddress",
    "ImportPrivKey",
    "ImportPubKey",
    "ImportWallet",
]

with open("tests/mocks/mock_bitcoind.go", "r") as f:
    lines = f.readlines()

output = []
skip_until_blank = False
current_method = None

for line in lines:
    # Check if this is a comment starting a method we want to remove
    for method in legacy_methods:
        if line.strip().startswith(f"// {method} mocks") or line.strip().startswith(f"// {method} indicates"):
            skip_until_blank = True
            current_method = method
            break

    if skip_until_blank:
        # Skip lines until we find a closing brace followed by a blank line or new section
        if line.strip() == "}" or line.strip() == "":
            if line.strip() == "}":
                skip_until_blank = False
                current_method = None
            continue
    else:
        output.append(line)

with open("tests/mocks/mock_bitcoind.go", "w") as f:
    f.writelines(output)

print("Cleaned mock file")
