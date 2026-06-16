# Build context is the coinnews/ directory (NOT coinnews/server), so
# both the server source and the codec module are available — the
# server's go.mod has `replace => ../codec`, so codec must be present.
FROM golang:1.25-alpine AS builder

# go-sqlite3 is a cgo package: needs a C toolchain to build.
RUN apk add --no-cache gcc musl-dev

WORKDIR /build

COPY codec ./codec
COPY server ./server

WORKDIR /build/server

ENV CGO_ENABLED=1
RUN go build -v -o /coinnewsd .

FROM alpine AS final

RUN apk add --no-cache curl ca-certificates

COPY --from=builder /coinnewsd /usr/bin/

# Smoke check: the binary loads and its flags parse in this runtime
# image (catches a broken cgo/libc link). `-h` prints usage and exits 0.
RUN coinnewsd -h

# COINNEWS_LISTEN defaults to 0.0.0.0:8080 in main.go.
EXPOSE 8080

CMD ["coinnewsd"]
