// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The model representing cosignature of an aggregate transaction.
public struct AggregateTransactionCosignature {
    /// Signature of aggregate transaction done by the cosigner.
    public let signature: [UInt8]
    /// Cosigner public account.
    public let signer: PublicAccount
}

