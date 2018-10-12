// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation


/// An abstract transaction class that serves as the base class of all NEM transactions.
public class Transaction {
    // MARK: Properties
    /// Transaction type.
    public let type: TransactionType
    /// Network type.
    public let networkType: NetworkType
    /// Transaction version.
    public let version: UInt8
    /// Deadline to include the transaction.
    public let deadline: Deadline
    /// Fee for the transaction. The higher the fee, the higher the priority of the transaction. Transactions with high priority get included in a block before transactions with lower priority.
    public let fee: UInt64
    /// Transaction signature (missing if part of an aggregate transaction).
    public let signature: String?
    /// Transaction creator public account.
    public private(set) var signer: PublicAccount?
    /// Meta data object contains additional information about the transaction.
    public let transactionInfo: TransactionInfo?

    /// If a transaction is pending to be included in a block.
    public var isUnconfirmed: Bool {
        guard let transactionInfo = self.transactionInfo else {
            return false
        }
        return transactionInfo.height == 0 && transactionInfo.hash == transactionInfo.merkleComponentHash
    }

    /// If a transaction is included in a block.
    public var isConfirmed: Bool {
        return transactionInfo != nil && transactionInfo!.height > 0
    }

    /// if a transaction has missing signatures.
    public var hasMissingSignatures: Bool {
        guard let transactionInfo = self.transactionInfo else {
            return false
        }
        return transactionInfo.height == 0 && transactionInfo.hash != transactionInfo.merkleComponentHash
    }

    /// If a transaction is not known by the network.
    public var isUnannounced: Bool {
        return self.transactionInfo == nil
    }

    // MARK: Methods
    /**
     * Constructor
     *
     * - parameter type:            Transaction type.
     * - parameter networkType:     Network type.
     * - parameter version:         Transaction version.
     * - parameter deadline:        Transaction deadline.
     * - parameter fee:             Transaction fee.
     * - parameter signature:       Transaction signature.
     * - parameter signer:          Transaction signer.
     * - parameter transactionInfo: Transaction meta data info.
     */
    init(type: TransactionType,
         networkType: NetworkType,
         version: UInt8,
         deadline: Deadline,
         fee: UInt64 = 0,
         signature: String? = nil,
         signer: PublicAccount? = nil,
         transactionInfo: TransactionInfo? = nil) {
        self.type = type
        self.networkType = networkType
        self.version = version
        self.deadline = deadline
        self.fee = fee
        self.signature = signature
        self.signer = signer
        self.transactionInfo = transactionInfo
    }

    init(base: Transaction) {
        self.type = base.type
        self.networkType = base.networkType
        self.version = base.version
        self.deadline = base.deadline
        self.fee = base.fee
        self.signature = base.signature
        self.signer = base.signer
        self.transactionInfo = base.transactionInfo
    }

    /**
     * Generates hash for a serialized transaction payload.
     *
     * - parameter signature: Signature bytes
     * - parameter signer: Signer bytes
     * - parameter message: Message bytes to be signed.
     * - returns: Generated transaction hash.
     */
    static func createTransactionHash(signature: [UInt8], signer: [UInt8], message: [UInt8]) -> [UInt8] {
        return Hashes.sha3_256(Array(signature[0..<32]) + signer + message)
    }


    // abstract function to create transaction payload bytes
    func getTransactionBodyBytes() -> [UInt8] {
        return []
    }


    /**
     * Serialize and sign transaction creating a new SignedTransaction.
     *
     * - parameter account: The account to sign the transaction.
     * - returns: Signed transaction.
     */
    public func signWith(account: Account) -> SignedTransaction {
        let signer = Signer(keyPair: account.keyPair)

        let body = getTransactionBodyBytes()

        let signingBytes = self.version.bytes + // version 1 byte
                self.networkType.rawValue.bytes + // network type 1 byte
                self.type.rawValue.bytes + // type 2 bytes
                self.fee.bytes + // fee 8 bytes
                self.deadline.timestamp.bytes + // deadline 8 bytes
                body // and actual data

        let signature = signer.sign(message: signingBytes)
        let signerBytes = account.keyPair.publicKey.bytes

        let hash = Transaction.createTransactionHash(
                signature: signature,
                signer: signerBytes,
                message: signingBytes)

        let payload = signature + // signature 64 bytes
                signerBytes + // signer 32 bytes
                signingBytes // message bytes to be singed


        let size = UInt32(payload.count + 4) // size including the size of itself
        return SignedTransaction(payload: size.bytes + payload, hash: hash, type: type)
    }

    /**
     * Takes a transaction and formats bytes to be included in an aggregate transaction.
     *
     * - returns: transaction with signer serialized to be part of an aggregate transaction
     */
    func toAggregateTransactionBytes() throws -> [UInt8] {
        guard let signer = self.signer else {
            throw Nem2SdkSwiftError.serializeError("Failed to serialize transaction as aggregate inner transaction because it has no signer.")
        }

        let signerBytes = signer.publicKey.bytes

        let body = getTransactionBodyBytes()

        let resultBytes = signerBytes +
                self.version.bytes + // version 1 byte
                self.networkType.rawValue.bytes + // network type 1 byte
                self.type.rawValue.bytes + // type 2 bytes
                body // and actual data

        let size = UInt32(resultBytes.count + 4) // size including the size of itself
        return size.bytes + resultBytes
    }

    /**
     * Convert an aggregate transaction to an inner transaction including transaction signer.
     *
     * - parameter signer: Transaction signer.
     * - returns: instance of Transaction with signer
     */
    public func toAggregate(signer: PublicAccount) -> Transaction {
        self.signer = signer
        return self
    }
}