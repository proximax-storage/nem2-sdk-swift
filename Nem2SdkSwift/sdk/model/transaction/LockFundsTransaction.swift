// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/**
 * Lock funds transaction is used before sending an Aggregate bonded transaction, as a deposit to announce the transaction.
 * When aggregate bonded transaction is confirmed funds are returned to LockFundsTransaction signer.
 *
 */
public class LockFundsTransaction: Transaction {
    /// Locked mosaic.
    public let mosaic: Mosaic
    /// Funds lock duration in number of blocks.
    public let duration: UInt64
    /// Signed transaction for which funds are locked.
    public let signedTransaction: SignedTransaction

    init(base: Transaction,
         mosaic: Mosaic,
         duration: UInt64,
         signedTransaction: SignedTransaction) {

        self.mosaic = mosaic
        self.duration = duration
        self.signedTransaction = signedTransaction

        super.init(base: base)
    }

    /**
     * Create a lock funds transaction object.
     *
     * - parameter mosaic:            Locked mosaic.
     * - parameter duration:          Funds lock duration in number of blocks.
     * - parameter signedTransaction: Signed transaction for which funds are locked.
     * - parameter networkType:       Network type.
     * - parameter deadline:          Deadline to include the transaction.(Optional. The default is 1 hour from now.)
     * - returns: LockFundsTransaction
     */
    public static func create(
            mosaic: Mosaic,
            duration: UInt64,
            signedTransaction: SignedTransaction,
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60)) throws -> LockFundsTransaction {

        guard signedTransaction.type == .aggregateBonded else {
            throw Nem2SdkSwiftError.illegalArgument("Signed transaction must be Aggregate Bonded Transaction");
        }

        let base = Transaction(type: .lock, networkType: networkType, version: 3, deadline: deadline)
        return LockFundsTransaction(base: base, mosaic: mosaic, duration: duration, signedTransaction: signedTransaction)
    }

    override func getTransactionBodyBytes() -> [UInt8] {
        return self.mosaic.id.id.bytes + // mosaic id 8 bytes
                self.mosaic.amount.bytes + // mosaic amount 8 bytes
                self.duration.bytes + // duration 8 bytes
                self.signedTransaction.hash // hash 32 bytes
    }
}
