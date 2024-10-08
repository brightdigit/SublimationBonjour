<p align="center">
    <img alt="Sublimation" title="Sublimation" src="Sources/SublimationBonjour/Documentation.docc/Resources/SublimationBonjour.svg" height="200">
</p>
<h1 align="center">SublimationBonjour</h1>

Use [Bonjour](https://developer.apple.com/bonjour/) for [Sublimation](https://github.com/brightdigit/Sublimation) for automatic discovery of your [Swift Server](https://www.swift.org/documentation/server/).

[![](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/SublimationBonjour/documentation)
[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/SublimationBonjour)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/SublimationBonjour)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/SublimationBonjour/SublimationBonjour.yml?label=actions&logo=github&?branch=main)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimationBonjour%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/SublimationBonjour)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimationBonjour%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/SublimationBonjour)


[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/SublimationBonjour)](https://codecov.io/gh/brightdigit/SublimationBonjour)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/SublimationBonjour)](https://www.codefactor.io/repository/github/brightdigit/SublimationBonjour)
[![codebeat badge](https://codebeat.co/badges/91d512f0-ab30-42f9-9791-02add3278171)](https://codebeat.co/projects/github-com-brightdigit-SublimationBonjour-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/SublimationBonjour)](https://codeclimate.com/github/brightdigit/SublimationBonjour)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/SublimationBonjour?label=debt)](https://codeclimate.com/github/brightdigit/SublimationBonjour)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/SublimationBonjour)](https://codeclimate.com/github/brightdigit/SublimationBonjour)

# Table of Contents

* [Introduction](#introduction)
  * [Requirements](#requirements)
  * [Installation](#installation)
* [Usage](#usage)
  * [Setting up your Server](#setting-up-your-server)
  * [Setting up your Client](#setting-up-your-client)
* [Documentation](#documentation)      
* [License](#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->


# Introduction

```mermaid
sequenceDiagram
  participant Server as Hummingbird/Vapor Server
  participant BonjourSub as BonjourSublimatory
  participant NWListener as NWListener
  participant Network as Local Network
  participant BonjourClient as BonjourClient
  participant App as iOS/watchOS App
  
  Server->>BonjourSub: Start server, provide IP addresses,<br/>hostnames, port, and protocol (http/https)
  BonjourSub->>NWListener: Configure with server information
  NWListener->>Network: Advertise service:<br/>1. Send encoded server data<br/>2. Use Text Record for additional info
  App->>BonjourClient: Request server URL
  BonjourClient->>Network: Search for advertised services
  Network-->>BonjourClient: Return advertised service information
  BonjourClient->>BonjourClient: 1. Receive and decode server data<br/>2. Parse Text Record
  BonjourClient-->>App: Return AsyncStream<URL><br/>or first available URL
  App->>Server: Connect to server using discovered URL
```

When the Swift Server begins it will tell Sublimation the ip addresses or host names which are available to access the server from (including the port number and whether to use https or http). This is called a `BonjourSublimatory`. The `BonjourSublimatory` then uses `NWListener` to advertise this information both by send the data encoded using Protocol Buffers as well as inside the Text Record advertised.

The iPhone or Apple Watch then uses a `BonjourClient` to fetch either an  `AsyncStream` of `URL` via `BonjourClient.urls` or simply get the `BonjourClient.first()` one available.

## Requirements 

**Apple Platforms**

- Xcode 16.0 or later
- Swift 6.0 or later
- iOS 17 / watchOS 10.0 / tvOS 17 / macOS 14 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 6.0 or later

## Installation

To integrate **SublimationBonjour** into your app using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/brightdigit/SublimationBonjour.git", from: "1.0.0")
  ],
  targets: [
      .target(
          name: "YourServerApp",
          dependencies: [
            .product(name: "SublimationBonjour", package: "SublimationBonjour"), ...
          ]),
      ...
  ]
)
```

# Usage

## Setting up your Server

Create a `BindingConfiguration` with:


* a list of host names and ip address
* port number of the server
* whether the server uses https or http

```swift
let bindingConfiguration = BindingConfiguration(
  host: ["Leo's-Mac.local", "192.168.1.10"],
  port: 8080
  isSecure: false
)
```


Create a `BonjourSublimatory` using that `BindingConfiguration` and include your server's logger. Then attach it to the `Sublimation` object:

```swift
let bonjour = BonjourSublimatory(
  bindingConfiguration: bindingConfiguration,
  logger: app.logger
)
let sublimation = Sublimation(sublimatory : bonjour)
```

You can also just create a `Sublimation` object:


```swift
let sublimation = Sublimation(
  bindingConfiguration: bindingConfiguration,
  logger: app.logger
)
```

## Setting up your Client

On the device, create a `BonjourClient` and either get an `AsyncStream` of `URL` objects via `BonjourClient.urls` or just ask for the first one using `BonjourClient.first()`:

```swift
let client = BonjourClient(logger: app.logger)
let hostURL = await client.first()
```

## Documentation

To learn more, check out the full [documentation](https://swiftpackageindex.com/brightdigit/SublimationBonjour/documentation).

# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SublimationBonjour/LICENSE) file for more info.
