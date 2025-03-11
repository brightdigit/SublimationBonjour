//
//  NWListener.swift
//  SimulatorServices
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#if canImport(Network)
  import Foundation
  import Logging
  public import Network

  protocol NWListenerServiceDescriptor: Sendable {
    var logger: Logger { get }
    var listener: NWListener { get }
    var name: String { get }
    var type: String { get }
    var listenerQueue: DispatchQueue { get }
    var connectionQueue: DispatchQueue { get }
  }

  extension NWListener {
    func run(
      _ descriptor: NWListenerServiceDescriptor,
      txtRecord: NWTXTRecord,
      onConnectionSend data: Data
    ) async throws {
      self.startWith(descriptor, txtRecord: txtRecord, onConnectionSend: data)
      try await self.run(logger: descriptor.logger)
    }

    private func run(logger: Logger) async throws {
      try await withCheckedThrowingContinuation { continuation in
        self.stateUpdateHandler = { state in
          switch state {
          case .waiting(let error):
            logger.warning("Listener Waiting error: \(error)")
            continuation.resume(throwing: error)

          case .failed(let error):
            logger.error("Listener Failure: \(error)")
            continuation.resume(throwing: error)
          case .cancelled: continuation.resume()
          default: logger.debug("Listener state updated: \(state.debugDescription)")
          }
        }
      }
    }
    private func startWith(
      _ descriptor: NWListenerServiceDescriptor,
      txtRecord: NWTXTRecord,
      onConnectionSend data: Data
    ) {
      assert(self.service == nil)
      self.service = .init(
        name: descriptor.name,
        type: descriptor.type,
        txtRecord: txtRecord
      )
      let logger = descriptor.logger
      self.newConnectionHandler = { connection in
        connection.stateUpdateHandler = { state in
          switch state {
          case .waiting(let error):

            logger.debug("Connection Waiting error: \(error.localizedDescription)")

          case .ready:
            logger.debug("Connection Ready")
            logger.debug("Sending data \(data.count) bytes")
            connection.send(
              content: data,
              completion: .contentProcessed { error in
                if let error { logger.error("Connection Send error: \(error)") }
                connection.cancel()
              }
            )
          case .failed(let error): logger.debug("Connection Failure: \(error)")
          default: logger.debug("Connection state updated: \(state.debugDescription)")
          }
        }
        connection.start(queue: descriptor.connectionQueue)
      }

      self.start(queue: descriptor.listenerQueue)
    }
  }
  extension NWListener.State: @retroactive CustomDebugStringConvertible {
    @_documentation(visibility: internal) public var debugDescription: String {
      switch self {
      case .setup: "setup"

      case .waiting(let error):
        "waiting: \(error.debugDescription)"
      case .ready: "ready"
      case .failed(let error): "failed: \(error.debugDescription)"
      case .cancelled: "cancelled"
      @unknown default: "unknown state"
      }
    }
  }
#endif
