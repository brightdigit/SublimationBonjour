//
//  LoggerType.swift
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

#if canImport(os)
  public import os
#endif

// swift-format-ignore-file
// swiftlint:disable missing_docs file_types_order
#if canImport(os)
  /// Logger type alias for platforms with os framework support.
  @_documentation(visibility: internal)
  public typealias LoggerType = Logger
#else
  /// Protocol for logging on platforms without os framework support.
  @_documentation(visibility: internal)
  public protocol NilLoggerType {
    func debug(_ message: String)
    func error(_ message: String)
  }
  /// Logger type alias for platforms without os framework support.
  @_documentation(visibility: internal)
  public typealias LoggerType = any NilLoggerType
#endif
// swiftlint:enable missing_docs file_types_order
