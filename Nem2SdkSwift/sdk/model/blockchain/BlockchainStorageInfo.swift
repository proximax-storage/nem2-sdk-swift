// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// The blockchain storage info structure describes stored data.
public struct BlockchainStorageInfo {
    // MARK: Properties
    /// Number of accounts published in the blockchain.
    public let numAccounts: Int
    /// Number of confirmed blocks.
    public let numBlocks: Int
    /// Number of confirmed transactions.
    public let numTransactions: Int

    /// :nodoc:
    public init(numAccounts: Int, numBlocks: Int, numTransactions: Int) {
        self.numAccounts = numAccounts
        self.numBlocks = numBlocks
        self.numTransactions = numTransactions
    }
}