//
//  NWListener.swift
//  SublimationBonjour
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

  extension NWListener {
    internal func run(
      _ descriptor: NWListenerServiceDescriptor,
      txtRecord: NWTXTRecord,
      onConnectionSend data: Data
    ) async throws {
      self.startWith(descriptor, txtRecord: txtRecord, onConnectionSend: data)
      try await self.run(logger: descriptor.logger)
    }

    private func run(logger: Logger) async throws {
      try await withCheckedThrowingContinuation {
        // swiftlint:disable:next closure_parameter_position
        (continuation: CheckedContinuation<Void, any Error>) in
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
        connection.start(
          on: descriptor.connectionQueue,
          sendingData: data,
          loggingTo: logger
        )
      }

      self.start(queue: descriptor.listenerQueue)
    }
  }

  extension NWListener.State: @retroactive CustomDebugStringConvertible {
    // swift-format-ignore
    @_documentation(visibility: internal)
    public var debugDescription: String {
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
