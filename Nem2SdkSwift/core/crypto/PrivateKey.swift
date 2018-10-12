// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation


/// Represents a private key.
public struct PrivateKey: Equatable, CustomStringConvertible {
    // MARK: Properties
    /// The raw private key value.
    public let bytes: [UInt8]

    /// Private key hex string description.
    public var description: String {
        return bytes.hexString.uppercased()
    }

    // MARK: Methods
    /**
     * Creates a new private key.
     *
     * - parameter bytes: The raw private key value.
     * - throws: Nem2SDkSwiftError.illegalArgument if the byte length is invalid.
     */
    public init(bytes: [UInt8]) throws{
        guard bytes.count == KeyPair.PRIVATE_KEY_SEED_SIZE else {
            throw Nem2SdkSwiftError.illegalArgument("Invalid private key byte length.")
        }
        self.bytes = bytes
    }

    /**
     * Creates a private key from a hex string.
     *
     * - parameter hexString: The private key hex string.
     * - throws: Nem2SDkSwiftError.illegalArgument if the byte length is invalid or the hex string is malformed.
     */
    public init(hexString: String) throws {
        try self.init(bytes: try HexEncoder.toBytes(hexString))
    }

    public static func ==(lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return lhs.bytes == rhs.bytes
    }

}
