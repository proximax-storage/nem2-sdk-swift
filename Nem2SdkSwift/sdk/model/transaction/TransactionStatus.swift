// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation


/// The transaction status contains basic of a transaction announced to the blockchain.
public struct TransactionStatus {
    // MARK: Properties
    /// Transaction status group "failed", "unconfirmed", "confirmed", etc...
    public let group: String?
    /// Transaction status being the error name in case of failure and success otherwise.
    public let status: String
    /// Transaction hash.
    public let hash: [UInt8]?
    /// Transaction deadline.
    public let deadline: Deadline?
    /// Height of the block at which it was confirmed or rejected.
    public let height: UInt64?
}
