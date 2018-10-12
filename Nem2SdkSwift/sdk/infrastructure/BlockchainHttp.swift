// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import RxSwift

/// Blockchain http repository
public class BlockchainHttp: Http, BlockchainRepository {
    /**
     * Constructs with host.
     *
     * - parameter url: Host url.
     */
    public override init(url: URL) {
        super.init(url: url)
    }

    /// :nodoc:
    public func getBlock(height: UInt64) -> Single<BlockInfo> {
        let builder = BlockchainRoutesAPI.getBlockByHeightWithRequestBuilder(height: Int64(height)).with(url: url)
        return Single.zip( getNetworkType(), builder.rxSend()).map { (networkType, dto) in try dto.toModel(in: networkType) }
    }

    /// :nodoc:
    public func getBlockTransactions(height: UInt64, pageSize: Int?, id: String?) -> Single<[Transaction]> {
        let builder = BlockchainRoutesAPI.getBlockTransactionsWithRequestBuilder(height: Int64(height), pageSize: pageSize, id: id).with(url: url)
        return builder.rxSend().map { dto in
            return try dto.map { transaction in
                try TransactionMapping.apply(transaction)
            }
        }
    }

    /// :nodoc:
    public func getBlockchainHeight() -> Single<UInt64> {
        let builder = BlockchainRoutesAPI.getBlockchainHeightWithRequestBuilder().with(url: url)
        return builder.rxSend().map { $0.height.uint64Value }
    }

    /// :nodoc:
    public func getBlockchainScore() -> Single<BlockchainScore> {
        let builder = BlockchainRoutesAPI.getBlockchainScoreWithRequestBuilder().with(url: url)
        return builder.rxSend().map { $0.toModel() }
    }

    /// :nodoc:
    public func getBlockchainStorage() -> Single<BlockchainStorageInfo> {
        let builder = BlockchainRoutesAPI.getDiagnosticStorageWithRequestBuilder().with(url: url)
        return builder.rxSend().map { $0.toModel() }
    }
}

extension BlockInfoDTO {
    func toModel(in networkType: NetworkType) throws -> BlockInfo {
        let signer = try PublicAccount(publicKeyHexString: block.signer, networkType: networkType)
        let version = Int(block.version) & 0xFF
        return BlockInfo(
                hash: meta.hash,
                generationHash: meta.generationHash,
                totalFee: meta.totalFee.uint64Value,
                numTransactions: Int(meta.numTransactions),
                signature: block.signature,
                signer: signer,
                networkType: networkType,
                version: version,
                type: Int(block.type),
                height: block.height.uint64Value,
                timestamp: block.timestamp.uint64Value,
                difficulty: block.difficulty.uint64Value,
                previousBlockHash: block.previousBlockHash,
                blockTransactionHash: block.blockTransactionsHash)
    }
}

extension BlockchainScoreDTO {
    func toModel() -> BlockchainScore {
        return BlockchainScore(scoreLow: scoreLow.uint64Value, scoreHigh: scoreHigh.uint64Value)
    }
}

extension BlockchainStorageInfoDTO {
    func toModel() -> BlockchainStorageInfo {
        return BlockchainStorageInfo(numAccounts: numAccounts, numBlocks: numBlocks, numTransactions: numTransactions)
    }
}