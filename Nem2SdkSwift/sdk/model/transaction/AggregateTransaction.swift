// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The aggregate innerTransactions contain multiple innerTransactions that can be initiated by different accounts.
public class AggregateTransaction: Transaction {
    // MARK: Properties
    /// List of innerTransactions included in the aggregate transaction.
    public let innerTransactions: [Transaction]
    /// List of transaction cosigners signatures.
    public let cosignatures: [AggregateTransactionCosignature]

    // MARK: Methods
    init(base: Transaction,
         innerTransactions: [Transaction],
         cosignatures: [AggregateTransactionCosignature]) {

        self.innerTransactions = innerTransactions
        self.cosignatures = cosignatures

        super.init(base: base)
    }

    /**
     * Create an aggregate complete transaction object
     *
     * - parameter deadline:          The deadline to include the transaction.
     * - parameter innerTransactions: The list of inner innerTransactions.
     * - parameter networkType:       The network type.
     * - returns: AggregateTransaction
     */
    public static func createComplete(
            innerTransactions: [Transaction],
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60) ) throws -> AggregateTransaction {

        if innerTransactions.contains(where: {$0.signer == nil}) {
            throw Nem2SdkSwiftError.illegalArgument("Inner transaction must have a signer.")
        }

        let base = Transaction(type: .aggregateComplete, networkType: networkType, version: 2, deadline: deadline)
        return AggregateTransaction(base: base, innerTransactions: innerTransactions, cosignatures: []);
    }

    /**
     * Create an aggregate bonded transaction object
     *
     * - parameter innerTransactions: The list of inner innerTransactions.
     * - parameter networkType:       The network type.
     * - parameter deadline:          The deadline to include the transaction.
     * - returns: AggregateTransaction
     */
    public static func createBonded(
            innerTransactions: [Transaction],
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60 ) ) throws -> AggregateTransaction {
        if innerTransactions.contains(where: {$0.signer == nil}) {
            throw Nem2SdkSwiftError.illegalArgument("Inner transaction must have a signer.")
        }

        let base = Transaction(type: .aggregateBonded, networkType: networkType, version: 2, deadline: deadline)
        return AggregateTransaction(base: base, innerTransactions: innerTransactions, cosignatures: []);
    }

    override func getTransactionBodyBytes() -> [UInt8] {
        let transactionBytes = self.innerTransactions.reduce([]) { (current: [UInt8], transaction: Transaction) in
            if let aggregateTransactionBytes = try? transaction.toAggregateTransactionBytes() {
                return current + aggregateTransactionBytes
            } else {
                return current
            }

        }
        return UInt32(transactionBytes.count).bytes + transactionBytes
    }

    /**
     * Sign transaction with cosignatories creating a new SignedTransaction.
     *
     * - parameter initiatorAccount: Initiator account
     * - parameter cosignatories:    The list of accounts that will cosign the transaction
     * - returns: Signed transaction
     */
    public func signWith(initiatorAccount: Account, cosignatories: [Account] ) -> SignedTransaction  {
        let signedTransaction = self.signWith(account: initiatorAccount)
        var payloadBytes = signedTransaction.payload

        for cosignatory in cosignatories {
            let signer = Signer(keyPair: cosignatory.keyPair)
            let bytes = signedTransaction.hash
            let signatureBytes = signer.sign(message: bytes)
            payloadBytes += cosignatory.publicKeyBytes + signatureBytes
        }

        let payload = UInt64(payloadBytes.count).bytes + Array(payloadBytes[8..<payloadBytes.count]) // Overwrite bytes with the size

        return SignedTransaction(payload: payload, hash: signedTransaction.hash, type: type)
    }

    /**
     * Check if account has signed transaction.
     *
     * - parameter publicAccount: Signer public account
     * - returns: boolean
     */
    public func signedByAccount(publicAccount: PublicAccount) -> Bool {
        return self.signer == publicAccount || cosignatures.contains(where: {$0.signer == publicAccount})
    }
}