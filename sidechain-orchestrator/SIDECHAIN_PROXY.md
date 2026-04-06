# Sidechain CLI Proxy Pattern

The orchestrator now provides proxy commands for interacting with sidechain nodes using the Go RPC clients.

## Usage

```bash
# Generate OpenAPI schema for a sidechain
./orchestratorctl bitnames generate-schema
./orchestratorctl thunder generate-schema

# Check wallet balance
./orchestratorctl bitnames balance  
./orchestratorctl thunder balance

# All supported sidechains
./orchestratorctl {bitassets|bitnames|coinshift|photon|thunder|truthcoin|zside} <command>
```

## Smart Binary Management

When you run a sidechain command, the orchestrator will:

1. Check if the sidechain binary is downloaded
2. If not downloaded:
   - Interactive mode: Ask "BitNames is not downloaded. download now? [Y/n]"
   - CI mode: Auto-download when `--auto-download` flag or `ORCHESTRATOR_AUTO_DOWNLOAD` env var is set

## Available Commands

Each sidechain supports:
- `balance` - Show wallet balance
- `generate-schema` - Generate OpenAPI schema

## Implementation

- Uses existing Go RPC clients from `sidechain/*/client.go`
- Leverages orchestrator's download infrastructure
- Maps CLI commands to Go client methods via reflection
- Supports all sidechains with standard ports

## CI Integration

Replace manual binary downloads in workflows:

```yaml
# Old approach
- name: Download BitNames binary
  run: curl ... | unzip ...

# New approach  
- name: Build orchestratorctl
  run: go build -o orchestratorctl ./cmd/orchestratorctl/

- name: Generate schema
  env:
    ORCHESTRATOR_AUTO_DOWNLOAD: "1"
  run: ./orchestratorctl bitnames generate-schema > schema.json
```

## Ports

Default ports for each sidechain:
- bitassets: 28332
- bitnames: 38332
- coinshift: 58332
- photon: 18332
- thunder: 48332
- truthcoin: 68332
- zside: 78332

## Testing

Run tests with:
```bash
go test ./commands/ -v
```