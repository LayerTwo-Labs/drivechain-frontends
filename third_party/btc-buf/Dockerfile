FROM golang:1.24-alpine AS builder

WORKDIR /work

## We install grpc-health-probe tool for internal healtch checks
RUN GRPC_HEALTH_PROBE_VERSION=v0.4.18 && \
    wget -qO/work/grpc-health-probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /work/grpc-health-probe

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -v -o ./btc-buf .

FROM debian:bullseye-slim
RUN apt-get update && \
    apt-get install -y openssh-client && \
    rm -rf /var/lib/apt/lists/*

# Setup SSH directory
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

COPY --from=builder /work/grpc-health-probe /usr/bin/grpc-health-probe
COPY --from=builder /work/btc-buf /usr/bin/btc-buf

# Verify we installed binaries correctly
RUN btc-buf -h
RUN which grpc-health-probe

EXPOSE 5080

HEALTHCHECK --interval=5s --timeout=3s --start-period=10s --retries=3 CMD [ "grpc-health-probe", "-addr=localhost:5080" ]

ENTRYPOINT [ "btc-buf", "--listen=0.0.0.0:5080" ]
