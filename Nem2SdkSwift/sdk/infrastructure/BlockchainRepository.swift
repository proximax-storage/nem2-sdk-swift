// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation
import RxSwift

/// Blockchain interface repository
public protocol BlockchainRepository {
    /**
     * Gets a BlockInfo for a given block height.
     *
     * - parameter height: Block height
     * - returns: Observable of BlockInfo
     */
    func getBlock(height: UInt64) -> Single<BlockInfo>

    /**
     * Gets list of transactions included in a block for a block height.
     *
     * - parameter height: Block height
     * - parameter pageSize: The number of transactions to return for each request. The default value is 10, the minimum is 10 and the maximum is 100. (optional)
     * - parameter id: The identifier of the transaction after which we want the transactions to be returned. If not supplied the most recent transactions are returned. (optional)
     * - returns: Observable of [Transaction]
     */
    func getBlockTransactions(height: UInt64, pageSize: Int?, id: String?) -> Single<[Transaction]>

    /**
     * Gets current blockchain height.
     *
     * - returns: Observable of UInt64
     */
    func getBlockchainHeight() -> Single<UInt64>

    /**
     * Gets current blockchain score.
     *
     * - returns: Observable of BlockchainScore
     */
    func getBlockchainScore() -> Single<BlockchainScore>

    /**
     * Gets blockchain storage info.
     *
     * - returns: Observable of BlockchainStorageInfo
     */
    func getBlockchainStorage() -> Single<BlockchainStorageInfo>
}


extension BlockchainRepository {
    func getBlockTransactions(height: UInt64, pageSize: Int? = nil, id: String? = nil) -> Single<[Transaction]> {
        return getBlockTransactions(height: height, pageSize: pageSize, id: id)
    }
}