//
//  BonjourSublimatory.swift
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

  internal import Foundation

  public import Network

  public import Logging
  public import SublimationCore

  /// Sublimatory for using Bonjour auto-discovery.
  public struct BonjourSublimatory: Sublimatory, NWListenerServiceDescriptor {
    /// Default name for the listener service which is "Sublimation"
    public static let defaultName = "Sublimation"
    /// Default service type which is "_sublimation._tcp".
    public static let defaultHttpTCPServiceType = "_sublimation._tcp"
    /// Default parameters for the listener which is `NWParameters.tcp`
    public static let defaultParameters: NWParameters = .tcp

    private let bindingConfiguration: BindingConfiguration
    internal let logger: Logger
    internal let listener: NWListener
    internal let name: String
    internal let type: String
    internal let listenerQueue: DispatchQueue
    internal let connectionQueue: DispatchQueue

    //    @available(*, unavailable, message: "Temporary Code for pulling ipaddresses.")
    //    static func getAllIPAddresses() -> [String: [String]] {
    //      var addresses: [String: [String]] = [:]
    //
    //      let monitor = NWPathMonitor()
    //      let queue = DispatchQueue.global(qos: .background)
    //
    //      monitor.pathUpdateHandler = { path in
    //        for interface in path.availableInterfaces {
    //          var interfaceAddresses: [String] = []
    //          let endpoint = NWEndpoint.Host(interface.debugDescription)
    //          let parameters = NWParameters.tcp
    //          parameters.requiredInterface = interface
    //
    //          let connection = NWConnection(host: endpoint, port: 80, using: parameters)
    //          connection.stateUpdateHandler = { state in
    //            if case .ready = state {
    //              if let localEndpoint = connection.currentPath?.localEndpoint {
    //                switch localEndpoint {
    //                case let .hostPort(host, _):
    //                  interfaceAddresses.append(host.debugDescription)
    //                default:
    //                  break
    //                }
    //              }
    //              addresses[interface.debugDescription] = interfaceAddresses
    //            }
    //          }
    //          connection.start(queue: queue)
    //        }
    //        monitor.cancel()
    //      }
    //
    //      monitor.start(queue: queue)
    //
    //      // Wait for a short period to gather the results
    //      sleep(2)
    //
    //      return addresses
    //    }

    /// Uses a `NWListener` to broadcast the server information.
    /// - Parameters:
    ///   - bindingConfiguration: A ``BindingConfiguration``
    ///   - logger: A logger.
    ///   - listener: The `NWListener` to use.
    ///   - name: Service name.
    ///   - type: Service type.
    ///   - listenerQueue: DispatchQueue for the listener.
    ///   - connectionQueue: DispatchQueue for each new connection made.
    public init(
      bindingConfiguration: BindingConfiguration,
      logger: Logger,
      listener: NWListener,
      name: String = Self.defaultName,
      type: String = Self.defaultHttpTCPServiceType,
      listenerQueue: DispatchQueue = .global(),
      connectionQueue: DispatchQueue = .global()
    ) {
      self.bindingConfiguration = bindingConfiguration
      self.logger = logger
      self.listener = listener
      self.name = name
      self.type = type
      self.listenerQueue = listenerQueue
      self.connectionQueue = connectionQueue
    }

    /// Creates a `NWListener` to broadcast the server information.
    /// - Parameters:
    ///   - bindingConfiguration: A ``BindingConfiguration``
    ///   - logger: A logger.
    ///   - listenerParameters: The network parameters to use for the listener.
    ///   - name: Service name.
    ///   - type: Service type.
    ///   - listenerQueue: DispatchQueue for the listener.
    ///   - connectionQueue: DispatchQueue for each new connection made.
    /// - Throws: an error if the parameters are not compatible with the provided port.
    public init(
      bindingConfiguration: BindingConfiguration,
      logger: Logger,
      listenerParameters: NWParameters = Self.defaultParameters,
      name: String = Self.defaultName,
      type: String = Self.defaultHttpTCPServiceType,
      listenerQueue: DispatchQueue = .global(),
      connectionQueue: DispatchQueue = .global()
    ) throws {
      let listener = try NWListener(using: listenerParameters)
      self.init(
        bindingConfiguration: bindingConfiguration,
        logger: logger,
        listener: listener,
        name: name,
        type: type,
        listenerQueue: listenerQueue,
        connectionQueue: connectionQueue
      )
    }

    /// Shutdown any active services by cancelling the listener.
    public func shutdown() { listener.cancel() }
    /// Runs the Sublimatory service.
    /// -  Note: This method contains long running work,
    /// returning from it is seen as a failure.
    public func run() async throws {
      let data = try bindingConfiguration.serializedData()
      let txtRecord = NWTXTRecord(data: data)
      return try await listener.run(self, txtRecord: txtRecord, onConnectionSend: data)
    }
  }
#endif
