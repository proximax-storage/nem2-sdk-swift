// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The transaction status error model returned by listeners.
public struct TransactionStatusError {
    /// Transaction hash.
    public let hash: [UInt8]
    /// Transaction status error when transaction fails.
    public let status: String
    /// Transaction deadline.
    public let deadline: Deadline
}
