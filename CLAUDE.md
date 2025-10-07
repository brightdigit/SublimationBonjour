# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SublimationBonjour is a Swift package that enables Bonjour-based service discovery for Swift servers using the Sublimation framework. It allows iOS/watchOS/tvOS apps to automatically discover and connect to local Swift servers (Hummingbird/Vapor) without manual configuration.

### Core Architecture

The package uses a bidirectional communication model:

**Server Side (`BonjourSublimatory`):**
- Advertises server availability via `NWListener` (Network framework)
- Encodes server connection details (hosts, port, security) as Protocol Buffers
- Broadcasts information via both Bonjour TXT records and connection data
- Key components: `BindingConfiguration`, `BonjourSublimatory`

**Client Side (`BonjourClient`):**
- Discovers advertised services using `NWBrowser`
- Decodes server information from TXT records
- Provides URLs via `AsyncStream<URL>` or `first()` method
- Key components: `BonjourClient`, `StreamManager`

**Data Flow:**
1. Server creates `BindingConfiguration` with connection details (hosts, port, isSecure)
2. `BonjourSublimatory` serializes this using Protocol Buffers
3. `NWListener` broadcasts via `_sublimation._tcp` Bonjour service
4. Client's `NWBrowser` discovers services and parses TXT records
5. Client returns discovered URLs to the app

## Swift 6 Compatibility

This project uses Swift 6 with strict concurrency checking and experimental features enabled:
- AccessLevelOnImport
- BitwiseCopyable
- IsolatedAny
- MoveOnlyPartialConsumption
- NestedProtocols
- NoncopyableGenerics
- TransferringArgsAndResults
- VariadicGenerics
- FullTypedThrows (upcoming)
- InternalImportsByDefault (upcoming)

**Important:** All code must be Swift 6 compliant with proper isolation and sendability.

## Development Commands

### Building
```bash
swift build
```

### Testing
```bash
# Run all tests
swift test

# Run specific test
swift test --filter <TestName>
```

### Code Quality
```bash
# Format code (requires mint or swift-format installation)
mint run swiftlang/swift-format format --in-place --recursive Sources/ Tests/

# Lint code
mint run realm/SwiftLint

# Check for unused code
mint run peripheryapp/periphery scan
```

### Linting Rules
The project uses strict SwiftLint configuration with:
- Indentation: 2 spaces
- Line length: 90 characters
- Function body length: 25-35 lines
- File length: 175-250 lines
- Cyclomatic complexity: 6-8
- Missing documentation warnings enabled
- Explicit access control required on all declarations
- Force unwrapping disabled

**Exception:** `BindingConfiguration+Protobuf.swift` is excluded from linting (generated code).

## Platform Support

**Apple Platforms:** macOS 14+, iOS 17+, watchOS 10+, tvOS 17+, visionOS 1+
**Linux:** Ubuntu 20.04+ (Note: Network framework features are Apple-only via `#if canImport(Network)`)

## Testing

Tests are located in `Tests/SublimationBonjourTests/`. All platform-specific code should include appropriate `#if canImport(Network)` guards.

## Dependencies

- **Sublimation** (2.0.1+): Core server discovery framework
- **swift-protobuf** (1.26.0+): Protocol Buffers serialization for `BindingConfiguration`

## Common Patterns

### Creating a Server with Bonjour
```swift
let bindingConfiguration = BindingConfiguration(
  hosts: ["server.local", "192.168.1.100"],
  port: 8080,
  isSecure: false
)

let bonjour = try BonjourSublimatory(
  bindingConfiguration: bindingConfiguration
)

try await bonjour.run() // Long-running task
```

### Client Discovery
```swift
let client = BonjourClient()

// Get first available URL
let url = await client.first()

// Or stream all discovered URLs
for await url in await client.urls {
  print("Discovered: \(url)")
}
```

## File Organization

```
Sources/SublimationBonjour/
├── Server/              # Server-side Bonjour broadcasting
│   ├── BonjourSublimatory.swift
│   ├── BindingConfiguration.swift
│   └── BindingConfiguration+Protobuf.swift (generated)
├── Client/              # Client-side service discovery
│   ├── BonjourClient.swift
│   ├── StreamManager.swift
│   └── BindingConfiguration+TXTRecord.swift
└── Extensions/          # Network framework extensions
    ├── NWListener.swift
    ├── NWConnection.swift
    └── NWTXTRecord.swift
```

## CI/CD

GitHub Actions workflows test on:
- **macOS:** Xcode 16.4 with multiple Swift versions
- **Linux:** Ubuntu Noble/Jammy containers with Swift 6.0+

Tests must pass on all supported platforms before merging.
