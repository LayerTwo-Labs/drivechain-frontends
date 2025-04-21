FROM golang:alpine AS builder

WORKDIR /build

ADD . .

RUN go build -v -o ./faucetd .

FROM alpine AS final

RUN apk add curl

COPY --from=builder /build/faucetd /usr/bin/

CMD ["faucetd"]