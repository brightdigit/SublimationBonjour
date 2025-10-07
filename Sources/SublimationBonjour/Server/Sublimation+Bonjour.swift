//
//  Sublimation+Bonjour.swift
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

#if canImport(Network) && !CLIENT_ONLY
  public import Network
  public import Sublimation

  /// Friendly extensions for setting up a `Sublimation` object for `Bonjour`
  @available(*, deprecated, message: "Use BonjourSublimatory.init.")
  extension Sublimation {
    /// Initializes a `Sublimation` instance with the provided parameters.
    ///
    /// - Parameters:
    ///   - bindingConfiguration: A ``BindingConfiguration``
    ///   - listenerParameters: The network parameters to use for the listener.
    ///   - name: Service name.
    ///   - type: Service type.
    ///   - listenerQueue: DispatchQueue for the listener.
    ///   - connectionQueue: DispatchQueue for each new connection made.
    /// - Throws: an error if the parameters are not compatible with the provided port.
    public convenience init(
      bindingConfiguration: BindingConfiguration,
      listenerParameters: NWParameters = .tcp,
      name: String = BonjourSublimatory.defaultName,
      type: String = BonjourSublimatory.defaultHttpTCPServiceType,
      listenerQueue: DispatchQueue = .global(),
      connectionQueue: DispatchQueue = .global()
    ) throws {
      let sublimatory = try BonjourSublimatory(
        bindingConfiguration: bindingConfiguration,
        listenerParameters: listenerParameters,
        name: name,
        type: type,
        listenerQueue: listenerQueue,
        connectionQueue: connectionQueue
      )
      self.init(sublimatory: sublimatory)
    }
    /// Initializes a `Sublimation` instance with the provided parameters.
    ///
    /// Uses a `NWListener` to broadcast the server information.
    /// - Parameters:
    ///   - bindingConfiguration: A ``BindingConfiguration``
    ///   - listener: The `NWListener` to use.
    ///   - name: Service name.
    ///   - type: Service type.
    ///   - listenerQueue: DispatchQueue for the listener.
    ///   - connectionQueue: DispatchQueue for each new connection made.
    public convenience init(
      bindingConfiguration: BindingConfiguration,
      listener: NWListener,
      name: String = BonjourSublimatory.defaultName,
      type: String = BonjourSublimatory.defaultHttpTCPServiceType,
      listenerQueue: DispatchQueue = .global(),
      connectionQueue: DispatchQueue = .global()
    ) {
      let sublimatory = BonjourSublimatory(
        bindingConfiguration: bindingConfiguration,
        listener: listener,
        name: name,
        type: type,
        listenerQueue: listenerQueue,
        connectionQueue: connectionQueue
      )
      self.init(sublimatory: sublimatory)
    }
  }
#endif
