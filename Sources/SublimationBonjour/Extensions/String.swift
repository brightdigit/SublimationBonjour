//
//  String.swift
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

internal import Foundation

extension String {
  // swift-format-ignore: NeverUseForceTry
  private nonisolated(unsafe) static let ipv6Regex = {
    // IPv6 regex pattern that covers most valid formats
    // This pattern allows for:
    // - Full 8 groups of 4 hex digits
    // - Compressed notation with ::
    // - IPv4-mapped addresses (::ffff:192.168.1.1)
    // - Zone identifiers (%interface)
    let pattern =
      // swiftlint:disable:next line_length
      #"^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[a-zA-Z][0-9a-zA-Z]*|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$"#
    // swiftlint:disable:next force_try
    return try! Regex(pattern)
  }()

  internal func isLocalhost() -> Bool {
    let localhostNames = ["localhost", "127.0.0.1", "::1"]
    return localhostNames.contains(self)
  }

  internal func isValidIPv6Address() -> Bool {
    // First check basic format requirements
    guard !self.isEmpty else {
      return false
    }
    guard self.contains(":") else {
      return false
    }

    // Check if it's a valid IPv4 address (which would be invalid for IPv6)
    if self.isValidIPv4Address() {
      return false
    }

    // Use Foundation's URL validation for cross-platform compatibility
    // IPv6 addresses in URLs are enclosed in square brackets
    let bracketedAddress = "[\(self)]"
    guard let url = URL(string: "http://\(bracketedAddress)") else {
      return false
    }

    // Check if the host component matches our original string (without brackets)
    guard url.host == self else {
      return false
    }

    // Additional regex validation for IPv6 format
    return self.isValidIPv6Format()
  }

  private func isValidIPv6Format() -> Bool {
    self.wholeMatch(of: Self.ipv6Regex) != nil
  }

  private func isValidIPv4Address() -> Bool {
    let components = self.split(separator: ".")
    guard components.count == 4 else {
      return false
    }

    for component in components {
      guard let num = Int(component), num >= 0 && num <= 255 else {
        return false
      }
    }
    return true
  }

  internal func splitByMaxLength(_ maxLength: Int) -> [String] {
    var result: [String] = []
    var currentIndex = self.startIndex

    while currentIndex < self.endIndex {
      let endIndex =
        self.index(
          currentIndex,
          offsetBy: maxLength,
          limitedBy: self.endIndex
        ) ?? self.endIndex
      let substring = String(self[currentIndex..<endIndex])
      result.append(substring)
      currentIndex = endIndex
    }

    return result
  }
}
