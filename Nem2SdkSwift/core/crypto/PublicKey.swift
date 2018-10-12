// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// Represents a public key.
public struct PublicKey: Equatable, CustomStringConvertible {
    // MARK: Properties
    /// The raw public key value.
    public let bytes: [UInt8]

    /// Public key hex string description.
    public var description: String {
        return bytes.hexString.uppercased()
    }

    // MARK: Methods
    /**
     * Creates a new public key.
     *
     * - parameter bytes: The raw public key value.
     * - throws: Nem2SDkSwiftError.illegalArgument if the byte length is invalid.
     */
    public init(bytes: [UInt8]) throws {
        guard bytes.count == KeyPair.PUBLIC_KEY_SIZE else {
            throw Nem2SdkSwiftError.illegalArgument("Invalid public key byte length.")
        }

        self.bytes = bytes
    }

    /**
     * Creates a public key from a hex string.
     *
     * - parameter hexString: The public key hex string.
     * - throws: Nem2SDkSwiftError.illegalArgument if the byte length is invalid or the hex string is malformed.
     */
    public init(hexString: String) throws {
        try self.init(bytes: try HexEncoder.toBytes(hexString))
    }

    public static func ==(lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.bytes == rhs.bytes
    }

}
