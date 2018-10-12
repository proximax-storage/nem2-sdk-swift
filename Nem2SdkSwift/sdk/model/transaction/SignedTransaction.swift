// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The signed transaction object is used to transfer the transaction data and the signature to NIS
public struct SignedTransaction {
    // MARK: Properties
    /// Transaction serialized data.
    public let payload: [UInt8]
    /// Transaction hash.
    public let hash: [UInt8]
    /// Transaction type.
    public let type: TransactionType
}
