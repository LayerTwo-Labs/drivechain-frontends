bin := "btc-buf"

gen:
    buf format -w proto
    buf generate --template buf.gen.yaml
    cd gen && go mod tidy

build: 
	go build -v -o ./{{ bin }} .

run *args:
	go run -v . {{ args }}

lint args='': 
	golangci-lint run {{ args }}

format: format-go format-proto

format-go:
	WRITE=1 bash scripts/check-goimports.sh
	WRITE=1 bash scripts/check-gogroup.sh

format-proto:
	buf format -w proto

clean: 
	rm -rf {{ bin }} gen
	
image: 
	docker buildx build --progress plain --platform linux/amd64 -t barebitcoin/btc-buf:$(git rev-parse --short HEAD) .
	
image-push: image
	docker push barebitcoin/btc-buf:$(git rev-parse --short HEAD) 

[positional-arguments]
curl *args='':
  #!/usr/bin/env bash
  set -euo pipefail

  url=""
  rest=()

  for a in "$@"; do
    if [[ -z "$url" && "$a" == /* ]]; then
      url="http://localhost:5080$a"
    else
      rest+=("$a")
    fi
  done

  [[ -n "$url" ]] || { echo "Error: No service URL found" >&2; exit 1; }

  buf curl --schema . --timeout=30m --emit-defaults "$url" "${rest[@]}"
