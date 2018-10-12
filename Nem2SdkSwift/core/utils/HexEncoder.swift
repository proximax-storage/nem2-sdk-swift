// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// Static class that contains utility functions for converting hex strings to and from bytes.
public class HexEncoder {
    // MARK: Methods
    /**
     * Converts bytes to hex string.
     *
     * - parameter bytes: Bytes
     * - returns: Hex string
     */
    public static func toHexString(_ bytes : [UInt8]) -> String {
        var result = ""
        bytes.forEach { (element) in
            result = result + String(format:"%02x", element)
        }
        return result
    }

    /**
     * Converts bytes to hex string
     *
     * - parameter input: Hex string
     * - returns: Bytes
     * - throws: Nem2SdkSwiftError.illegalArgument if the input is malformed.
     */
    public static func toBytes(_ input: String) throws -> [UInt8] {
        var s = input
        if input.count % 2 == 1 {
            s = "0" + s
        }
        let len = s.lengthOfBytes(using: .ascii)
        var data: [UInt8] = []
        for i in stride(from:0, to:len, by: 2) {
            let startIndex = s.index(s.startIndex, offsetBy: i)
            let endIndex = s.index(startIndex, offsetBy: 2)
            if let val = UInt8(s[startIndex..<endIndex], radix: 16) {
                data.append(val)
            } else {
                throw Nem2SdkSwiftError.illegalArgument("\(input) is cannot convert to bytes as hex string.")
            }
        }
        return data
    }
}

public extension Array where Element == UInt8 {
    // MARK: Properties
    /// Hex string description of this bytes.
    var hexString: String {
        return HexEncoder.toHexString(self)
    }
}

public extension String {
    // MARK: Methods
    /**
     * Decodes this string as hex string of bytes and returns the bytes.
     *
     * - throws: Nem2SdkSwiftError.illegalArgument if this string is malformed as hex string.
     * - returns: Bytes
     */
    func toBytesFromHexString() -> [UInt8]? {
        return try? HexEncoder.toBytes(self)
    }
}