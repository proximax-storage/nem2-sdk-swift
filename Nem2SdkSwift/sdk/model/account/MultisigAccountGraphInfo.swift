// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/**
 *
 *
 * @since 1.0
 */
/// The multisig account graph info structure describes the information of all the mutlisig levels an account is involved in.
public struct MultisigAccountGraphInfo {
    // MARK: Properties
    /// Multisig accounts.
    public let multisigAccounts: [Int:[MultisigAccountInfo]]

    /// Multisig accounts levels number.
    public var levelsNumber: Set<Int> {
        return Set<Int>(self.multisigAccounts.keys)
    }

    // MARK: Methods
    public init(multisigAccounts: [Int:[MultisigAccountInfo]]) {
        self.multisigAccounts = multisigAccounts
    }
}
