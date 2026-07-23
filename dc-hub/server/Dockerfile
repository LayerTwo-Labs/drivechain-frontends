FROM golang:alpine AS builder

WORKDIR /build

ADD . .

RUN go build -v -o ./dc-hubd .

FROM alpine AS final

RUN apk add curl

COPY --from=builder /build/dc-hubd /usr/bin/

CMD ["dc-hubd"]