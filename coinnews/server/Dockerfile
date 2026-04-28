FROM golang:alpine AS builder

RUN apk add --no-cache build-base sqlite-dev

WORKDIR /build

# Build context is coinnews/, so both server/ and codec/ are
# present and the go.mod `replace` directive resolves.
COPY codec ./codec
COPY server ./server

WORKDIR /build/server
RUN CGO_ENABLED=1 go build -v -o ./coinnewsd .

FROM alpine AS final

RUN apk add --no-cache curl sqlite-libs

COPY --from=builder /build/server/coinnewsd /usr/bin/

EXPOSE 8080

CMD ["coinnewsd"]
