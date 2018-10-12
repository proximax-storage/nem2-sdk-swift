// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import RxSwift

/// Account http repository
public class AccountHttp: Http, AccountRepository {
    /**
     * Constructs with host.
     *
     * - parameter url: Host url.
     */
    public override init(url: URL) {
        super.init(url: url)
    }

    /// :nodoc:
    public func getAccountInfo(address: Address) -> Single<AccountInfo> {
        let builder = AccountRoutesAPI.getAccountInfoWithRequestBuilder(accountId: address.plain).with(url: url)
        return builder.rxSend().map { try $0.toModel() }
    }

    /// :nodoc:
    public func getAccountsInfo(addresses: [Address]) -> Single<[AccountInfo]> {
        let builder = AccountRoutesAPI.getAccountsInfoWithRequestBuilder(
                addresses: Addresses(addresses: addresses.map { $0.plain })).with(url: url)
        return builder.rxSend().map { try $0.map { try $0.toModel() } }
    }

    /// :nodoc:
    public func getMultisigAccountInfo(address: Address) -> Single<MultisigAccountInfo> {
        let builder = AccountRoutesAPI.getAccountMultisigWithRequestBuilder(accountId: address.plain).with(url: url)
        return Single.zip( getNetworkType(), builder.rxSend()).map { (networkType, dto) in try dto.toModel(in: networkType) }
    }

    /// :nodoc:
    public func getMultisigAccountGraphInfo(address: Address) -> Single<MultisigAccountGraphInfo> {
        let builder = AccountRoutesAPI.getAccountMultisigGraphWithRequestBuilder(accountId: address.plain).with(url: url)
        return Single.zip( getNetworkType(), builder.rxSend()).map { (networkType, dto) in try dto.toModel(in: networkType) }
    }

    /// :nodoc:
    public func transactions(publicAccount: PublicAccount, pageSize: Int?, id: String?) -> Single<[Transaction]> {
        let builder = AccountRoutesAPI.transactionsWithRequestBuilder(publicKey: publicAccount.publicKey.description, pageSize: pageSize, id: id).with(url: url)
        return builder.rxSend().map { dto in
            return try dto.map { transaction in
                try TransactionMapping.apply(transaction)
            }
        }
    }

    /// :nodoc:
    public func incomingTransactions(publicAccount: PublicAccount, pageSize: Int?, id: String?) -> Single<[Transaction]> {
        let builder = AccountRoutesAPI.incomingTransactionsWithRequestBuilder(publicKey: publicAccount.publicKey.description, pageSize: pageSize, id: id).with(url: url)
        return builder.rxSend().map { dto in
            return try dto.map { transaction in
                try TransactionMapping.apply(transaction)
            }
        }
    }

    /// :nodoc:
    public func outgoingTransactions(publicAccount: PublicAccount, pageSize: Int?, id: String?) -> Single<[Transaction]> {
        let builder = AccountRoutesAPI.outgoingTransactionsWithRequestBuilder(publicKey: publicAccount.publicKey.description, pageSize: pageSize, id: id).with(url: url)
        return builder.rxSend().map { dto in
            return try dto.map { transaction in
                try TransactionMapping.apply(transaction)
            }
        }
    }

    /// :nodoc:
    public func aggregateBondedTransactions(publicAccount: PublicAccount, pageSize: Int?, id: String?) -> Single<[AggregateTransaction]> {
        let builder = AccountRoutesAPI.partialTransactionsWithRequestBuilder(publicKey: publicAccount.publicKey.description, pageSize: pageSize, id: id).with(url: url)
        return builder.rxSend().map { dto in
            return try dto.map { transaction in
                guard let aggregateTransaction = try TransactionMapping.apply(transaction) as? AggregateTransaction else {
                    throw Nem2SdkSwiftError.parseError("Other type of transactions are returned though aggregate bonded transactions are required.")
                }
                return aggregateTransaction
            }
        }
    }

    /// :nodoc:
    public func unconfirmedTransactions(publicAccount: PublicAccount, pageSize: Int?, id: String?) -> Single<[Transaction]> {
        let builder = AccountRoutesAPI.unconfirmedTransactionsWithRequestBuilder(publicKey: publicAccount.publicKey.description, pageSize: pageSize, id: id).with(url: url)
        return builder.rxSend().map { dto in
            return try dto.map { transaction in
                try TransactionMapping.apply(transaction)
            }
        }
    }
}


extension AccountInfoDTO {
    func toModel() throws -> AccountInfo {
        return AccountInfo(
                address: try Address(encodedAddress: account.address),
                addressHeight: account.addressHeight.uint64Value,
                publicKey: account.publicKey,
                publicKeyHeight: account.publicKeyHeight.uint64Value,
                importance: account.importance.uint64Value,
                importanceHeight: account.importanceHeight.uint64Value,
                mosaics: account.mosaics.map { $0.toModel() })
    }
}

extension MosaicDTO {
    func toModel() -> Mosaic {
        return Mosaic(id: MosaicId(id: id.uint64Value), amount: amount.uint64Value)
    }
}

extension MultisigAccountInfoDTO {
    func toModel(in networkType: NetworkType) throws -> MultisigAccountInfo {
        return MultisigAccountInfo(
                account: try PublicAccount(publicKeyHexString: self.multisig.account, networkType: networkType),
                minApproval: multisig.minApproval,
                minRemoval: multisig.minRemoval,
                cosignatories: try multisig.cosignatories.map { try PublicAccount(publicKeyHexString: $0, networkType: networkType)},
                multisigAccounts: try multisig.multisigAccounts.map { try PublicAccount(publicKeyHexString: $0, networkType: networkType)} )
    }
}

extension Array where Element == MultisigAccountGraphInfoDTO {
    func toModel(in networkType: NetworkType) throws -> MultisigAccountGraphInfo {
        return MultisigAccountGraphInfo(
                multisigAccounts: Dictionary(
                        uniqueKeysWithValues: try map { graphEntry in
                            return (graphEntry.level,
                                    try graphEntry.multisigEntries.map {
                                        try $0.toModel(in: networkType)
                                    })
                        }))
    }
}

