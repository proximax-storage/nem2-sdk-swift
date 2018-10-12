// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// Secret lock transaction
public class SecretLockTransaction: Transaction {
    // MARK: Properties

    /// Locked mosaic.
    public let mosaic: Mosaic
    /// Duration for the funds to be released or returned.
    public let duration: UInt64
    /// Hash algorithm, secret is generated with.
    public let hashType: HashType
    /// Proof hashed.
    public let secret: [UInt8]
    /// Recipient of the funds.
    public let recipient: Address

    // MARK: Methods
    init(base: Transaction,
         mosaic: Mosaic,
         duration: UInt64,
         hashType: HashType,
         secret: [UInt8],
         recipient: Address) {

        self.mosaic = mosaic
        self.duration = duration
        self.hashType = hashType
        self.secret = secret
        self.recipient = recipient

        super.init(base: base)
    }


    /**
     * Create a secret lock transaction object.
     *
     * - parameter mosaic:      Locked mosaic.
     * - parameter duration:    Duration for the funds to be released or returned.
     * - parameter hashType:    Hash algorithm secret is generated with.
     * - parameter secret:      Proof hashed.
     * - parameter recipient:   Recipient of the funds.
     * - parameter networkType: Network type.
     * - parameter deadline:    Deadline to include the transaction.
     *
     * - returns:  a SecretLockTransaction instance
     */
    public static func create(
            mosaic: Mosaic,
            duration: UInt64,
            hashType: HashType,
            secret: [UInt8],
            recipient: Address,
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60)) -> SecretLockTransaction {
        let base = Transaction(type: .secretLock, networkType: networkType, version: 3, deadline: deadline)
        return SecretLockTransaction(
                base: base,
                mosaic: mosaic,
                duration: duration,
                hashType: hashType,
                secret: secret,
                recipient: recipient)
    }

    override func getTransactionBodyBytes() -> [UInt8] {
        return self.mosaic.id.id.bytes + // mosaic id 8 bytes
                self.mosaic.amount.bytes + // mosaic amount 8 bytes
                self.duration.bytes + // duration 8 bytes
                self.hashType.rawValue.bytes + // hash algorithm 1 byte
                self.secret + // secret 64 byte
                self.recipient.bytes // base 32 address
    }

}
