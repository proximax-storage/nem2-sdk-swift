// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// Enum containing transaction type constants.
public enum TransactionType: UInt16 {
    /// Aggregate complete transaction type.
    case aggregateComplete = 0x4141
    /// Aggregate bonded transaction type
    case aggregateBonded = 0x4241
    /// Mosaic definition transaction type.
    case mosaicDefinition = 0x414d
    /// Mosaic supply change
    case mosaicSupplyChange = 0x424d
    /// Modify multisig account
    case modifyMultisigAccount = 0x4155
    /// Register namespace transaction type.
    case registerNamespace = 0x414e
    /// Transfer Transaction transaction type.
    case transfer = 0x4154
    /// Lock transaction type
    case lock = 0x414C
    /// Secret Lock Transaction type
    case secretLock = 0x424C
    /// Secret Proof transaction type
    case secretProof = 0x434C
}
