// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/**
 * Modify multisig account transactions are part of the NEM's multisig account system.
 * A modify multisig account transaction holds an array of multisig cosignatory modifications, min number of signatures to approve a transaction and a min number of signatures to remove a cosignatory.
 */
public class ModifyMultisigAccountTransaction: Transaction {
    // MARK: Properties
    /**
     * Number of signatures needed to approve a transaction.
     * If we are modifying and existing multi-signature account this indicates the relative change of the minimum cosignatories.
     */
    public let minApprovalDelta: Int8
    /**
     * Number of signatures needed to remove a cosignatory.
     * If we are modifying and existing multi-signature account this indicates the relative change of the minimum cosignatories.
     */
    public let minRemovalDelta: Int8
    /// List of cosigner accounts added or removed from the multi-signature account.
    public let modifications: [MultisigCosignatoryModification]

    // MARK: Methods
    init(base: Transaction,
         minApprovalDelta: Int8,
         minRemovalDelta: Int8,
         modifications: [MultisigCosignatoryModification]) {

        self.minApprovalDelta = minApprovalDelta
        self.minRemovalDelta = minRemovalDelta
        self.modifications = modifications

        super.init(base: base)
    }

    /**
     * Create a modify multisig account transaction object.
     *
     * - parameter minApprovalDelta: Min approval relative change.
     * - parameter minRemovalDelta:  Min removal relative change.
     * - parameter modifications:    List of modifications.
     * - parameter networkType:      Network type.
     * - parameter deadline:         Deadline to include the transaction.(Optional. The default is 1 hour from now.)
     * - returns: ModifyMultisigAccountTransaction
     */
    public static func create(
            minApprovalDelta: Int8,
            minRemovalDelta: Int8,
            modifications: [MultisigCosignatoryModification],
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60)) -> ModifyMultisigAccountTransaction {
        let base = Transaction(type: .modifyMultisigAccount, networkType: networkType, version: 3, deadline: deadline)
        return ModifyMultisigAccountTransaction(base: base, minApprovalDelta: minApprovalDelta, minRemovalDelta: minRemovalDelta, modifications: modifications)
    }

    override func getTransactionBodyBytes() -> [UInt8] {
        let modificationsBytes = self.modifications.reduce([]){ (current: [UInt8], modification: MultisigCosignatoryModification) in
            return current +
                    modification.type.rawValue.bytes + // modification type 1 byte
                    modification.cosignatory.publicKey.bytes // cosigner public key 32 bytes
        }

        return self.minRemovalDelta.bytes + // min removal delta 1 byte
                self.minApprovalDelta.bytes + // min approval delta 1 byte
                UInt8(self.modifications.count).bytes + // num modifications 1 byte
                modificationsBytes // modifications
    }

}
