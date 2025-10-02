//
//  StringTests.swift
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

import Testing

@testable import SublimationBonjour

struct StringTests {
  // MARK: - IPv6 Address Validation Tests

  @Test(
    "Valid IPv6 addresses should return true",
    arguments: [
      // Full 8-group notation
      "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
      "2001:db8:85a3:0:0:8a2e:370:7334",
      "2001:db8:85a3::8a2e:370:7334",

      // Compressed notation
      "::1",  // Loopback
      "::",  // Unspecified
      "2001:db8::",  // Partial compression
      "::ffff:192.0.2.1",  // IPv4-mapped
      "::ffff:192.168.1.1",  // IPv4-mapped

      // Zone identifiers
      "fe80::1%lo0",
      "fe80::1%en0",
      "fe80::1%wlan0",

      // Various valid formats
      "2001:db8:85a3:0000:0000:8a2e:0370:7334",
      "2001:db8:85a3:0:0:8a2e:370:7334",
      "2001:db8:85a3::8a2e:370:7334",
      "2001:db8::8a2e:370:7334",
      "::8a2e:370:7334",
      "2001:db8:85a3::",
      "::1",
      "::",

      // IPv4-mapped addresses
      "::ffff:192.0.2.1",
      "::ffff:192.168.1.1",
      "::ffff:10.0.0.1",

      // Link-local addresses
      "fe80::1",
      "fe80::1%lo0",
      "fe80::1%en0",

      // Multicast addresses
      "ff02::1",
      "ff02::2",
      "ff05::1:3",

      // Unique local addresses
      "fd00::1",
      "fc00::1",
    ])
  func validateValidIPv6Addresses(_ address: String) async throws {
    #expect(address.isValidIPv6Address(), "Expected '\(address)' to be a valid IPv6 address")
  }

  @Test(
    "Invalid IPv6 addresses should return false",
    arguments: [
      // IPv4 addresses (should be rejected)
      "192.168.1.1",
      "10.0.0.1",
      "127.0.0.1",
      "8.8.8.8",

      // Hostnames (should be rejected)
      "localhost",
      "example.com",
      "google.com",
      "not-an-ip",
      "test-host",

      // Malformed IPv6 addresses
      "2001:db8:85a3::8a2e:370:7334:extra",  // Too many segments
      "2001:db8:85a3:0000:0000:8a2e:0370",  // Too few segments
      "2001:db8:85a3::8a2e:370:7334::",  // Multiple :: sequences
      "2001::db8::85a3",  // Multiple :: sequences
      "2001:db8:85a3:0000:0000:8a2e:0370:7334:extra",  // Too many groups
      "2001:db8:85a3:0000:0000:8a2e:0370",  // Too few groups
      "2001:db8:85a3:0000:0000:8a2e:0370:7334:extra:more",  // Way too many

      // Invalid characters
      "2001:db8:85a3:0000:0000:8a2e:0370:gggg",  // Invalid hex
      "2001:db8:85a3:0000:0000:8a2e:0370:733g",  // Invalid hex
      "2001:db8:85a3:0000:0000:8a2e:0370:7334:invalid",  // Invalid characters

      // Invalid IPv4-mapped addresses
      "::ffff:256.0.0.1",  // Invalid IPv4 octet
      "::ffff:192.168.1",  // Incomplete IPv4
      "::ffff:192.168.1.1.1",  // Too many IPv4 octets

      // Edge cases
      "",  // Empty string
      ":",  // Just colon
      ":::",  // Too many colons
      "2001:",  // Incomplete
      ":2001",  // Starts with colon
      "2001:::",  // Ends with too many colons
      "2001:db8:85a3:0000:0000:8a2e:0370:7334:",  // Trailing colon
      ":2001:db8:85a3:0000:0000:8a2e:0370:7334",  // Leading colon

      // Zone identifier edge cases
      "fe80::1%",  // Empty zone
      "fe80::1%123",  // Invalid zone characters
      "fe80::1%lo0%",  // Multiple % signs
      "fe80::1%lo0%en0",  // Multiple % signs
    ])
  func rejectInvalidIPv6Addresses(_ address: String) async throws {
    #expect(!address.isValidIPv6Address(), "Expected '\(address)' to be an invalid IPv6 address")
  }

  @Test(
    "IPv6 address validation should be case insensitive",
    arguments: [
      "2001:0db8:85a3:0000:0000:8a2e:0370:7334",  // All lowercase
      "2001:0DB8:85A3:0000:0000:8A2E:0370:7334",  // All uppercase
      "2001:0Db8:85A3:0000:0000:8a2E:0370:7334",  // Mixed case
    ])
  func validateIPv6AddressCaseInsensitive(_ address: String) async throws {
    #expect(address.isValidIPv6Address(), "Expected '\(address)' to be valid regardless of case")
  }

  @Test(
    "IPv6 address validation should reject edge cases",
    arguments: [
      String(repeating: "a", count: 1_000),  // Very long string
      "2001:db8:85a3:0000:0000:8a2e:0370:7334@#$%",  // Special characters
      "2001:db8:85a3:0000:0000:8a2e:0370:7334🚀",  // Unicode characters
      " 2001:db8:85a3:0000:0000:8a2e:0370:7334 ",  // Whitespace
      "2001:db8:85a3:0000:0000:8a2e:0370:7334\n",  // Newlines
    ])
  func rejectIPv6AddressEdgeCases(_ address: String) async throws {
    #expect(!address.isValidIPv6Address(), "Expected edge case '\(address)' to be rejected")
  }

  @Test("IPv6 address validation should be consistent")
  func ensureIPv6AddressValidationConsistency() async throws {
    // Test that the same address always returns the same result
    let testAddress = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
    let result1 = testAddress.isValidIPv6Address()
    let result2 = testAddress.isValidIPv6Address()
    #expect(result1 == result2)

    // Test that different instances of the same string return the same result
    let address1 = "::1"
    let address2 = "::1"
    #expect(address1.isValidIPv6Address() == address2.isValidIPv6Address())
  }

  @Test(
    "IPv6 address validation should reject IPv4 addresses",
    arguments: [
      "192.168.1.1",
      "10.0.0.1",
      "127.0.0.1",
      "8.8.8.8",
      "0.0.0.0",
      "255.255.255.255",
      "172.16.0.1",
      "192.168.0.1",
    ])
  func rejectIPv4Addresses(_ address: String) async throws {
    #expect(!address.isValidIPv6Address(), "Expected IPv4 address '\(address)' to be rejected")
  }

  @Test(
    "IPv6 address validation should reject hostnames",
    arguments: [
      "localhost",
      "example.com",
      "google.com",
      "not-an-ip",
      "test-host",
      "my-server.local",
      "api.example.org",
    ])
  func rejectHostnames(_ hostname: String) async throws {
    #expect(!hostname.isValidIPv6Address(), "Expected hostname '\(hostname)' to be rejected")
  }

  @Test(
    "IPv6 address validation should accept valid zone identifiers",
    arguments: [
      "fe80::1%lo0",
      "fe80::1%en0",
      "fe80::1%wlan0",
      "fe80::1%eth0",
      "fe80::1%bridge0",
    ])
  func validateIPv6AddressesWithZoneIdentifiers(_ address: String) async throws {
    #expect(address.isValidIPv6Address(), "Expected '\(address)' with zone identifier to be valid")
  }

  @Test(
    "IPv6 address validation should reject invalid zone identifiers",
    arguments: [
      "fe80::1%",  // Empty zone
      "fe80::1%123",  // Invalid zone characters
      "fe80::1%lo0%",  // Multiple % signs
      "fe80::1%lo0%en0",  // Multiple % signs
      "2001:db8::1%lo0",  // Zone on non-link-local
    ])
  func rejectIPv6AddressesWithInvalidZoneIdentifiers(_ address: String) async throws {
    #expect(!address.isValidIPv6Address(), "Expected '\(address)' with invalid zone to be rejected")
  }

  @Test(
    "IPv6 address validation should accept valid IPv4-mapped addresses",
    arguments: [
      "::ffff:192.0.2.1",
      "::ffff:192.168.1.1",
      "::ffff:10.0.0.1",
      "::ffff:127.0.0.1",
      "::ffff:8.8.8.8",
    ])
  func validateIPv4MappedAddresses(_ address: String) async throws {
    #expect(address.isValidIPv6Address(), "Expected IPv4-mapped address '\(address)' to be valid")
  }

  @Test(
    "IPv6 address validation should reject invalid IPv4-mapped addresses",
    arguments: [
      "::ffff:256.0.0.1",  // Invalid IPv4 octet
      "::ffff:192.168.1",  // Incomplete IPv4
      "::ffff:192.168.1.1.1",  // Too many IPv4 octets
      "::ffff:192.168.1.1.1.1",  // Way too many octets
    ])
  func rejectInvalidIPv4MappedAddresses(_ address: String) async throws {
    #expect(
      !address.isValidIPv6Address(),
      "Expected invalid IPv4-mapped address '\(address)' to be rejected")
  }

  @Test(
    "IPv6 address validation should accept valid compressed addresses",
    arguments: [
      "::1",  // All zeros compressed
      "::",  // All zeros
      "2001:db8::",  // Partial compression
      "2001:db8::8a2e:370:7334",  // Partial compression
      "::8a2e:370:7334",  // Leading compression
      "2001:db8:85a3::",  // Trailing compression
    ])
  func validateCompressedIPv6Addresses(_ address: String) async throws {
    #expect(address.isValidIPv6Address(), "Expected compressed address '\(address)' to be valid")
  }

  @Test(
    "IPv6 address validation should reject invalid compressed addresses",
    arguments: [
      "2001::db8::85a3",  // Multiple :: sequences
      "2001:db8:85a3::8a2e:370:7334::",  // Multiple :: sequences
      ":::1",  // Too many colons
      "2001:::",  // Ends with too many colons
    ])
  func rejectInvalidCompressedIPv6Addresses(_ address: String) async throws {
    #expect(
      !address.isValidIPv6Address(),
      "Expected invalid compressed address '\(address)' to be rejected")
  }
}
