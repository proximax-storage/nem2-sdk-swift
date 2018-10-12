// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/**
 * The multisig cosignatory modifications are part of the NEM's multisig account system.
 * With a multisig cosignatory modification a cosignatory is added to or deleted from a multisig account.
 * Multisig cosignatory modifications are part of a modify multisig account transactions.
 */
public struct MultisigCosignatoryModification {
    /// Multisig modification type.
    public let type: MultisigCosignatoryModificationType
    /// Cosignatory public account.
    public let cosignatory: PublicAccount

    public init(type: MultisigCosignatoryModificationType, cosignatory: PublicAccount) {
        self.type = type
        self.cosignatory = cosignatory
    }
}
