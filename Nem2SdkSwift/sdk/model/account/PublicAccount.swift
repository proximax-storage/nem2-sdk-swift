// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// The public account structure contains account's address and public key.
public struct PublicAccount: Equatable {
    // MARK: Properties
    /// Account address.
    public let address: Address
    /// Account public key.
    public let publicKey: PublicKey

    // MARK: Methods
    /**
     * Create a PublicAccount from a public key and network type.
     *
     * - parameter publicKey: Public key
     * - parameter networkType: Network type
     */
    public init(publicKey: PublicKey, networkType: NetworkType) {
        self.address = Address(publicKey: publicKey, networkType: networkType)
        self.publicKey = publicKey
    }

    /**
     * Create a PublicAccount from a public key hex string and network type.
     *
     * - parameter publicKeyHexString: Public key hex string
     * - parameter networkType: Network type
     */
    public init(publicKeyHexString: String, networkType: NetworkType) throws{
        let publicKey = try PublicKey(hexString: publicKeyHexString)
        self.init(publicKey: publicKey, networkType: networkType)
    }

    /// :nodoc:
    public static func ==(lhs: PublicAccount, rhs: PublicAccount) -> Bool {
        return lhs.address == rhs.address && lhs.publicKey == rhs.publicKey
    }
}
