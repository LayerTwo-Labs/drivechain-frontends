FROM golang:alpine AS builder

WORKDIR /build

ADD . .

RUN go build -v -o ./faucet-backend .

FROM alpine AS final

RUN apk add curl

COPY --from=builder /build/faucet-backend /usr/bin/

CMD ["faucet-backend"]