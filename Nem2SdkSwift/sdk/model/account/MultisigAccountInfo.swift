// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// The multisig account info structure describes information of a multisig account.
public struct MultisigAccountInfo: Equatable {
    // MARK: Properties
    /// Account multisig public account.
    public let account: PublicAccount
    /// Number of signatures needed to approve a transaction.
    public let minApproval: Int
    /// Number of signatures needed to remove a cosignatory.
    public let minRemoval: Int
    /// Multisig account cosignatories.
    public let cosignatories: [PublicAccount]
    /// Multisig accounts this account is cosigner of.
    public let multisigAccounts: [PublicAccount]

    /// if the account is a multisig account.
    public var isMultisig: Bool {
        return minApproval != 0 && minRemoval != 0
    }

    // MARK: Methods

    /// :nodoc:
    public init(account: PublicAccount, minApproval: Int, minRemoval: Int, cosignatories: [PublicAccount], multisigAccounts: [PublicAccount]) {
        self.account = account
        self.minApproval = minApproval
        self.minRemoval = minRemoval
        self.cosignatories = cosignatories
        self.multisigAccounts = multisigAccounts
    }

    /**
     * Checks if an account is cosignatory of the multisig account.
     *
     * - parameter account: PublicAccount
     * - returns: boolean
     */
    public func hasCosigner(account: PublicAccount) -> Bool {
        return self.cosignatories.contains(account)
    }

    /**
     * Checks if the multisig account is cosignatory of an account.
     *
     * - parameter account: PublicAccount
     * - returns: boolean
     */
    public func isCosignerOf(account: PublicAccount) -> Bool {
        return self.multisigAccounts.contains(account)
    }

    /// :nodoc:
    public static func ==(lhs: MultisigAccountInfo, rhs: MultisigAccountInfo) -> Bool {
        return lhs.account == rhs.account &&
                lhs.minApproval == rhs.minApproval &&
                lhs.minRemoval == rhs.minRemoval &&
                lhs.cosignatories == rhs.cosignatories &&
                lhs.multisigAccounts == rhs.multisigAccounts
    }
}
