// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation


enum ListenerMessage {
    case block(BlockInfo)
    case confirmedAdded(Transaction)
    case unconfirmedAdded(Transaction)
    case unconfirmedRemoved([UInt8])
    case partialAdded(AggregateTransaction)
    case partialRemoved([UInt8])
    case cosignature(CosignatureSignedTransaction)
    case status(TransactionStatusError)
}
