//
//  NWConnection.swift
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

  extension NWConnection {
    internal func start(
      on queue: DispatchQueue,
      sendingData data: Data,
      loggingTo logger: Logger
    ) {
      self.stateUpdateHandler = { state in
        self.onConnectionState(state, sendingData: data, loggingTo: logger)
      }
      self.start(queue: queue)
    }

    private func onConnectionState(
      _ state: NWConnection.State, sendingData data: Data, loggingTo logger: Logger
    ) {
      switch state {
      case .waiting(let error):

        logger.debug("Connection Waiting error: \(error.localizedDescription)")

      case .ready:
        logger.debug("Connection Ready")
        logger.debug("Sending data \(data.count) bytes")
        self.send(
          content: data,
          completion: .contentProcessed { error in
            if let error { logger.error("Connection Send error: \(error)") }
            self.cancel()
          }
        )
      case .failed(let error): logger.debug("Connection Failure: \(error)")
      default: logger.debug("Connection state updated: \(state.debugDescription)")
      }
    }
  }

  extension NWConnection.State: @retroactive CustomDebugStringConvertible {
    @_documentation(visibility: internal)
    public var debugDescription: String {
      switch self {
      case .setup: return "setup"

      case .waiting(let error):
        return "waiting: \(error.debugDescription)"
      case .preparing: return "preparing"
      case .ready: return "ready"
      case .failed(let error): return "failed:  \(error.debugDescription)"
      case .cancelled: return "cancelled"
      @unknown default: return "unknown state"
      }
    }
  }
#endif
