FROM golang:1.25-alpine AS builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Pure Go — no cgo anywhere in the cpuminer's import graph.
ENV CGO_ENABLED=0
RUN go build -v -o /cpuminer ./cmd

FROM alpine AS final

COPY --from=builder /cpuminer /usr/bin/

# Smoke check: the binary runs in this image. `-h` prints usage and exits 0.
RUN cpuminer -h

# Flags (-url, -coinbase-addr, -coinbase-sig, -routines, ...) go in `command`.
ENTRYPOINT ["cpuminer"]
