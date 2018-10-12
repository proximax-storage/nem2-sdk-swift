// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import RxSwift

/// Account interface repository.
public protocol AccountRepository {
    /**
     * Gets an AccountInfo for an account.
     *
     * - parameter address Address
     * - returns: Observable of AccountInfo
     */
    func getAccountInfo(address: Address) -> Single<AccountInfo>

    /**
     * Gets AccountsInfo for different accounts.
     *
     * - parameter addresses List of Address
     * - returns: Observable of [AccountInfo]
     */
    func getAccountsInfo(addresses: [Address]) -> Single<[AccountInfo]>

    /**
     * Gets a MultisigAccountInfo for an account.
     *
     * - parameter address Address
     * - returns: Observable of MultisigAccountInfo
     */
    func getMultisigAccountInfo(address: Address) -> Single<MultisigAccountInfo>

    /**
     * Gets a MultisigAccountGraphInfo for an account.
     *
     * - parameter address Address
     * - returns: Observable of MultisigAccountGraphInfo
     */
    func getMultisigAccountGraphInfo(address: Address) -> Single<MultisigAccountGraphInfo>

    /**
     * Gets an list of confirmed transactions for which an account is signer or receiver.
     *
     * - parameter publicAccount: PublicAccount
     * - parameter pageSize: The number of transactions to return for each request. The default value is 10, the minimum is 10 and the maximum is 100. (optional)
     * - parameter id: The identifier of the transaction after which we want the transactions to be returned. If not supplied the most recent transactions are returned. (optional)
     * - returns: Observable of [Transaction]
     */
    func transactions(publicAccount: PublicAccount, pageSize: Int?, id: String?) -> Single<[Transaction]>

    /**
     * Gets an list of transactions for which an account is the recipient of a transaction.
     * A transaction is said to be incoming with respect to an account if the account is the recipient of a transaction.
     *
     * - parameter publicAccount: PublicAccount
     * - parameter pageSize: The number of transactions to return for each request. The default value is 10, the minimum is 10 and the maximum is 100. (optional)
     * - parameter id: The identifier of the transaction after which we want the transactions to be returned. If not supplied the most recent transactions are returned. (optional)
     * - returns: Observable of [Transaction]
     */
    func incomingTransactions(publicAccount: PublicAccount, pageSize: Int?, id: String?) -> Single<[Transaction]>

    /**
     * Gets an list of transactions for which an account is the sender a transaction.
     * A transaction is said to be outgoing with respect to an account if the account is the sender of a transaction.
     *
     * - parameter publicAccount: PublicAccount
     * - parameter pageSize: The number of transactions to return for each request. The default value is 10, the minimum is 10 and the maximum is 100. (optional)
     * - parameter id: The identifier of the transaction after which we want the transactions to be returned. If not supplied the most recent transactions are returned. (optional)
     * - returns: Observable of [Transaction]
     */
    func outgoingTransactions(publicAccount: PublicAccount, pageSize: Int?, id: String?) -> Single<[Transaction]>

    /**
     * Gets an list of transactions for which an account is the sender or has sign the transaction.
     * A transaction is said to be aggregate bonded with respect to an account if there are missing signatures.
     *
     * - parameter publicAccount: PublicAccount
     * - parameter pageSize: The number of transactions to return for each request. The default value is 10, the minimum is 10 and the maximum is 100. (optional)
     * - parameter id: The identifier of the transaction after which we want the transactions to be returned. If not supplied the most recent transactions are returned. (optional)
     * - returns: Observable of [AggregateTransaction]
     */
    func aggregateBondedTransactions(publicAccount: PublicAccount, pageSize: Int?, id: String?) -> Single<[AggregateTransaction]>

    /**
     * Gets the list of transactions for which an account is the sender or receiver and which have not yet been included in a block.
     * Unconfirmed transactions are those transactions that have not yet been included in a block.
     * Unconfirmed transactions are not guaranteed to be included in any block.
     *
     * - parameter publicAccount: PublicAccount
     * - parameter pageSize: The number of transactions to return for each request. The default value is 10, the minimum is 10 and the maximum is 100. (optional)
     * - parameter id: The identifier of the transaction after which we want the transactions to be returned. If not supplied the most recent transactions are returned. (optional)
     * - returns: Observable of [Transaction]
     */
    func unconfirmedTransactions(publicAccount: PublicAccount, pageSize: Int?, id: String?) -> Single<[Transaction]>
}

public extension AccountRepository {
    func transactions(publicAccount: PublicAccount, pageSize: Int? = nil, id: String? = nil) -> Single<[Transaction]> {
        return transactions(publicAccount: publicAccount, pageSize: pageSize, id: id)
    }

    func incomingTransactions(publicAccount: PublicAccount, pageSize: Int? = nil, id: String? = nil) -> Single<[Transaction]> {
        return incomingTransactions(publicAccount: publicAccount, pageSize: pageSize, id: id)
    }

    func outgoingTransactions(publicAccount: PublicAccount, pageSize: Int? = nil, id: String? = nil) -> Single<[Transaction]> {
        return outgoingTransactions(publicAccount: publicAccount, pageSize: pageSize, id: id)
    }

    func aggregateBondedTransactions(publicAccount: PublicAccount, pageSize: Int? = nil, id: String? = nil) -> Single<[AggregateTransaction]> {
        return aggregateBondedTransactions(publicAccount: publicAccount, pageSize: pageSize, id: id)
    }

    func unconfirmedTransactions(publicAccount: PublicAccount, pageSize: Int? = nil, id: String? = nil) -> Single<[Transaction]> {
        return unconfirmedTransactions(publicAccount: publicAccount, pageSize: pageSize, id: id)
    }
}
