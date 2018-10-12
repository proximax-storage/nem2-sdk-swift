// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation
import RxSwift

/// Transaction http repository.
public class TransactionHttp: Http, TransactionRepository {
    /**
     * Constructs with host.
     *
     * - parameter url: Host url.
     */
    public override init(url: URL) {
        super.init(url: url)
    }

    /// :nodoc:
    public func getTransaction(hash: [UInt8]) -> Single<Transaction> {
        let builder = TransactionRoutesAPI.getTransactionWithRequestBuilder(transactionId: hash.hexString).with(url: url)
        return builder.rxSend().map { dto in try TransactionMapping.apply(dto)}
    }

    /// :nodoc:
    public func getTransactions(hashes: [[UInt8]]) -> Single<[Transaction]> {
        let builder = TransactionRoutesAPI.getTransactionsWithRequestBuilder(
                transactionIds: TransactionIds(transactionIds: hashes.map{ $0.hexString})).with(url: url)
        return builder.rxSend().map { dto in try dto.map { try TransactionMapping.apply($0)}}
    }

    /// :nodoc:
    public func getTransactionStatus(hash: [UInt8]) -> Single<TransactionStatus> {
        let builder = TransactionRoutesAPI.getTransactionStatusWithRequestBuilder(hash: hash.hexString).with(url: url)
        return builder.rxSend().map { dto in try dto.toModel() }
    }

    /// :nodoc:
    public func getTransactionStatuses(hashes: [[UInt8]]) -> Single<[TransactionStatus]> {
        let builder = TransactionRoutesAPI.getTransactionsStatusesWithRequestBuilder(
                transactionHashes: TransactionHashes(hashes: hashes.map{ $0.hexString })).with(url: url)
        return builder.rxSend().map { dto in try dto.map { try $0.toModel() }}
    }

    /// :nodoc:
    public func announce(signedTransaction: SignedTransaction) -> Single<TransactionAnnounceResponse> {
        let builder = TransactionRoutesAPI.announceTransactionWithRequestBuilder(
                payload: TransactionPayload(payload: signedTransaction.payload.hexString)).with(url: url)

        return builder.rxSend().map { dto in try TransactionAnnounceResponseMapping.apply(dto: dto)}
    }

    /// :nodoc:
    public func announceAggregateBonded(signedTransaction: SignedTransaction) -> Single<TransactionAnnounceResponse> {
        let builder = TransactionRoutesAPI.announcePartialTransactionWithRequestBuilder(
                payload: TransactionPayload(payload: signedTransaction.payload.hexString)).with(url: url)

        return builder.rxSend().map { dto in try TransactionAnnounceResponseMapping.apply(dto: dto)}

    }

    /// :nodoc:
    public func announceAggregateBondedCosignature(cosignatureSignedTransaction: CosignatureSignedTransaction) -> Single<TransactionAnnounceResponse> {

        let builder = TransactionRoutesAPI.announceCosignatureTransactionWithRequestBuilder(
                payload: CosignatureSignedTransactionDTO(
                        parentHash: cosignatureSignedTransaction.parentHash.hexString,
                        signature: cosignatureSignedTransaction.signature.hexString,
                        signer: cosignatureSignedTransaction.signer.hexString)).with(url: url)

        return builder.rxSend().map { dto in try TransactionAnnounceResponseMapping.apply(dto: dto)}
    }
}


extension TransactionStatusDTO {
    func toModel() throws -> TransactionStatus {
        return TransactionStatus(
                group: group,
                status: status,
                hash: hash == nil ? nil: try HexEncoder.toBytes(hash!),
                deadline: deadline == nil ? nil : Deadline(fromNemesis: TimeInterval(deadline!.uint64Value)),
                height: height?.uint64Value)
    }
}

class TransactionAnnounceResponseMapping {
    static func apply(dto: AnyObjectDictionary) throws -> TransactionAnnounceResponse {
        guard case .object(let object) = dto else {
            throw Nem2SdkSwiftError.parseError("Failed to parse transaction announce response.")
        }
        return TransactionAnnounceResponse(message: try object.getString("message"))
    }
}