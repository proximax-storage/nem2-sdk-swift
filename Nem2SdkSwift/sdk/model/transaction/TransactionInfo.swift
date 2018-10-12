// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The transaction information model included in all transactions.
public struct TransactionInfo {
    // MARK: Properties
    /// Block height in which the transaction was included.
    public let height: UInt64
    /// Index representing either transaction index/position within block or within an aggregate transaction.
    public let index: Int?
    /// Transaction id.
    public let id: String?
    /// Transaction hash.
    public let hash: [UInt8]?
    /// Transaction merkle component hash.
    public let merkleComponentHash: [UInt8]?
    /// Hash of the aggregate transaction.
    public let aggregateHash: [UInt8]?
    /// Id of the aggregate transaction.
    public let aggregateId: String?

    private init(height: UInt64,
                 index: Int? = nil,
                 id: String? = nil,
                 hash: [UInt8]? = nil,
                 merkleComponentHash: [UInt8]? = nil,
                 aggregateHash: [UInt8]? = nil,
                 aggregateId: String? = nil) {
        self.height = height
        self.index = index
        self.id = id
        self.hash = hash
        self.merkleComponentHash = merkleComponentHash
        self.aggregateHash = aggregateHash
        self.aggregateId = aggregateId
    }

    // MARK: Methods
    /**
     * Create transaction info object for aggregate transaction inner transaction.
     *
     * - parameter height:        Block height in which the transaction was included.
     * - parameter index:         The transaction index.
     * - parameter id:            transaction id.
     * - parameter aggregateHash: The hash of the aggregate transaction.
     * - parameter aggregateId:   The id of the aggregate transaction.
     * - returns: Instance of TransactionInfo
     */
    public static func createAggregate(height: UInt64, index: Int, id: String, aggregateHash: [UInt8], aggregateId: String) -> TransactionInfo {
        return TransactionInfo(height: height, index: index, id: id, aggregateHash: aggregateHash, aggregateId: aggregateId)
    }

    /**
     * Create transaction info object for a transaction.
     *
     * - parameter height:              Block height in which the transaction was included.
     * - parameter index:               The transaction index.
     * - parameter id:                  transaction id.
     * - parameter hash:                The transaction hash.
     * - parameter merkleComponentHash: The transaction merkle component hash.
     * - returns: Instance of TransactionInfo
     */
    public static func create(height: UInt64, index: Int, id: String, hash: [UInt8], merkleComponentHash: [UInt8]) -> TransactionInfo {
        return TransactionInfo(height: height, index: index, id: id, hash: hash, merkleComponentHash: merkleComponentHash)
    }

    /**
     * Create transaction info retrieved by listener.
     *
     * - parameter height:              Block height in which the transaction was included.
     * - parameter hash:                The transaction hash
     * - parameter merkleComponentHash: The transaction merkle component hash.
     * - returns: Instance of TransactionInfo
     */
    public static func create(height: UInt64, hash: [UInt8], merkleComponentHash: [UInt8]) ->  TransactionInfo {
        return TransactionInfo(height: height, hash: hash, merkleComponentHash: merkleComponentHash)
    }

}
