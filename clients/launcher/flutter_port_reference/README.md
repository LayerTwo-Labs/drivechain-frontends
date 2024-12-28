# Drivechain Launcher Architecture

## Migration Progress

### ✅ Completed
1. **Resource Configuration Migration**
   - Migrated component definitions from resource_downloader.gd to chain_config.json
   - Added all required components:
     - GRPCURL
     - BIP300301 Enforcer
     - Bitcoin Core (Patched)
     - BitWindow
     - Thunder
   - Implemented cross-platform paths
   - Added required JSON schema fields:
     - network configurations
     - wallet paths
     - binary locations
     - download information

### 🚧 In Progress/Todo
1. **Resource Downloader Implementation**
   - Convert download management from Godot to Flutter
   - Implement progress tracking using Streams
   - Port extraction logic for different platforms
   - Implement binary verification

2. **Configuration Manager**
   - Port configuration.gd functionality
   - Implement data directory management
   - Setup Bitcoin Core configuration
   - Implement cross-platform path resolution
   - Add user-specific settings management

3. **RPC Client**
   - Port RPC/GRPC communication
   - Implement Bitcoin Core RPC calls
   - Setup enforcer GRPC communication
   - Port Thunder CLI interactions

4. **L2 Status Manager**
   - Implement Layer 2 state management
   - Port L1 component coordination
   - Add process lifecycle management
   - Implement chain status monitoring

## Component Overview

1. **Resource Downloader**
   - Manages downloading of all required binaries
   - Handles cross-platform paths and extraction
   - Tracks download progress
   - Verifies binary installations

2. **Configuration Manager**
   - Manages data directories for all components
   - Handles Bitcoin Core configuration
   - Provides cross-platform path resolution
   - Manages user-specific settings

3. **RPC Client**
   - Handles all external communication
   - Manages Bitcoin Core RPC calls
   - Handles GRPC communication with enforcer
   - Manages Thunder CLI interactions

4. **L2 Status Manager**
   - Manages Layer 2 sidechain state
   - Coordinates with L1 components
   - Handles process lifecycle
   - Monitors chain status

## Flow and Order of Operations

### 1. Initial Setup
```
ResourceDownloader
└── Check for existing binaries
    ├── If missing: Download required components
    │   ├── GRPCURL
    │   ├── Bitcoin Core
    │   ├── Enforcer
    │   └── BitWindow
    └── Extract and verify installations

Configuration
└── Check/Create necessary directories
    └── Write default configurations
        └── Bitcoin Core config
```

### 2. L1 (Layer 1) Startup Sequence
```
Main Window
├── Verify all L1 components ready
├── Start Bitcoin Core
│   └── RPC Client monitors status
├── Wait for Bitcoin Core ready
├── Start Enforcer
│   └── RPC Client monitors status
└── Start BitWindow
```

### 3. L2 (Layer 2) Operations
```
L2 Status Manager
├── Check L1 prerequisites
│   ├── Verify L1 software ready
│   └── Verify L1 running
├── Download L2 components if needed
│   └── ResourceDownloader handles Thunder binaries
├── Start L2 process
└── Monitor L2 status via RPC Client
```

### 4. Ongoing Operations
```
RPC Client
├── Regular status checks
│   ├── Bitcoin block height
│   ├── Enforcer status
│   └── Thunder status
└── Handle communication failures

L2 Status Manager
└── Regular state updates
    └── Block height monitoring
```

### 5. Shutdown Sequence
```
Main Window
├── Stop L2 processes
├── Stop BitWindow
├── Stop Enforcer
└── Stop Bitcoin Core
```

## Flutter Implementation Notes

1. **State Management**
   - Use Provider/Bloc for component state
   - Implement proper state isolation
   - Handle cross-component dependencies

2. **Async Operations**
   - Convert signals to Streams
   - Implement proper error handling
   - Use async/await patterns

3. **Platform Specifics**
   - Isolate platform-specific code
   - Use appropriate Flutter packages
   - Handle permissions properly

## Next Steps Priority

1. **Resource Downloader**
   - Implement download management using Flutter http package
   - Add progress tracking with StreamController
   - Port platform-specific extraction logic
   - Add binary verification

2. **Configuration**
   - Setup data directory management
   - Implement Bitcoin Core configuration
   - Add user settings management

3. **RPC/Communication**
   - Implement RPC client
   - Setup GRPC communication
   - Add Thunder CLI integration

4. **Process Management**
   - Implement L2 status management
   - Add process lifecycle handling
   - Setup chain monitoring
