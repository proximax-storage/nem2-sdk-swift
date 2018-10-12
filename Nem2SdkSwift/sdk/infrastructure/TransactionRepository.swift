// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation
import RxSwift

/// Transaction interface repository.
public protocol TransactionRepository {
    /**
     * Gets a transaction for a given hash.
     *
     * - parameter hash: Transaction hash.
     * - returns: Observable of Transaction
     */
    func getTransaction(hash: [UInt8]) -> Single<Transaction>
    /**
     * Gets an list of transactions for different transaction hashes.
     *
     * - parameter hashes: List of transaction hash string.
     * - returns: Observable of [Transaction]
     */
    func getTransactions(hashes: [[UInt8]] ) -> Single<[Transaction]>

    /**
     * Gets a transaction status for a transaction hash.
     *
     * - parameter hash: Transaction hash string
     * - returns: Observable of TransactionStatus
     */
    func getTransactionStatus(hash: [UInt8]) -> Single<TransactionStatus>

    /**
     * Gets an list of transaction status for different transaction hashes.
     *
     * - parameter hashes: List of transaction hash string
     * - returns: Observable of [TransactionStatus]
     */
    func getTransactionStatuses(hashes: [[UInt8]] ) -> Single<[TransactionStatus]>

    /**
     * Send a signed transaction.
     *
     * - parameter signedTransaction: SignedTransaction
     * - returns: Observable of TransactionAnnounceResponse
     */
    func announce(signedTransaction: SignedTransaction) -> Single<TransactionAnnounceResponse>

    /**
     * Send a signed transaction with missing signatures.
     *
     * - parameter signedTransaction: SignedTransaction
     * - returns: Observable of TransactionAnnounceResponse
     */
    func announceAggregateBonded(signedTransaction: SignedTransaction) -> Single<TransactionAnnounceResponse>

    /**
     * Send a cosignature signed transaction of an already announced transaction.
     *
     * - parameter cosignatureSignedTransaction: CosignatureSignedTransaction
     * - returns: Observable of TransactionAnnounceResponse
     */
    func announceAggregateBondedCosignature(cosignatureSignedTransaction: CosignatureSignedTransaction) -> Single<TransactionAnnounceResponse>
}
