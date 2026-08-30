# drivechain-frontends — engineering rules

## Always be concise

Be as concise as possible in everything: responses, code, and comments.

A comment says what the thing is or does, in one line, two at most. No
history, no "why not X", no cross-file spelunking, no product name-drops.
Most code needs no comment at all.

```
# Bad:
# Cross-building the Intel daemon on Apple Silicon needs Rosetta. This
# branch only runs in CI (dev builds the host arch only); the install is
# idempotent (no-op if already present).

# Good:
# Install Rosetta to cross-build the Intel daemon.
```

## Write a migration when user data is at stake

This project holds real money. A change that leaves an existing user unable to
see or spend their coins is a bug, not an acceptable cost.

Write a one-time migration when a change would otherwise:

- hide, move, or invalidate a key, a seed, or a derivation path
- make an existing wallet read as empty
- throw away a chain the user already synced

Rules for a migration:

- Run it once at startup, and make it safe to run twice.
- Never delete the old data until the new form reads back correctly.
- Leave a value the user set by hand alone.
- Cover it with a test that starts from the old on-disk shape.

For everything that is **not** user data — binary layout, config keys, database
schema for a deleted feature, proto field renames, frontend state shape — do not
write compat code. Write the new correct behaviour. The user wipes and
reinstalls.


## Figma: one file, never a new one

Every design for this project goes in the existing file:

https://www.figma.com/design/Uvj2xZiMJsOt3nDaSxDGLQ/drivechain-frontends
File key: `Uvj2xZiMJsOt3nDaSxDGLQ`

Never call `create_new_file`. A new file holds none of the design system, so
the design is worthless.

Read the file before you draw. Build from the components that are already
there — page `Components` holds dialog, button, input, avatar, and label. Use
the `sail/*` text styles. Put a new screen on its own page, named after the
flow.
