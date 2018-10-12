// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// The account info structure describes basic information for an account.
public struct AccountInfo {
    // MARK: Properties
    /// Account address.
    public let address: Address
    /// Height when the address was published.
    public let addressHeight: UInt64
    /// Public key of the account.
    public let publicKey: String
    /// Height when the public key was published.
    public let publicKeyHeight: UInt64
    /// Importance of the account.
    public let importance: UInt64
    /// Importance height of the account.
    public let importanceHeight: UInt64
    /// Mosaics hold by the account.
    public let mosaics: [Mosaic]

    /// :nodoc:
    public init(address: Address, addressHeight: UInt64, publicKey: String, publicKeyHeight: UInt64, importance: UInt64, importanceHeight: UInt64, mosaics: [Mosaic]) {
        self.address = address
        self.addressHeight = addressHeight
        self.publicKey = publicKey
        self.publicKeyHeight = publicKeyHeight
        self.importance = importance
        self.importanceHeight = importanceHeight
        self.mosaics = mosaics
    }
}

