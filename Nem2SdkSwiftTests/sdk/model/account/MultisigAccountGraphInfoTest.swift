// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class MultisigAccountGraphInfoTest: XCTestCase {

    func testReturnTheLevels() {
        var info: [Int: [MultisigAccountInfo]] = [:]
        let multisigAccountInfo = MultisigAccountInfo(
                account: try! PublicAccount(
                        publicKeyHexString: "5D58EC16F07BF00BDE9B040E7451A37F9908C59E143A01438C04345D8E9DDF39",
                        networkType: .mijinTest),
                minApproval: 1,
                minRemoval: 1,
                cosignatories: [
                    try! PublicAccount(
                            publicKeyHexString: "1674016C27FE2C2EB5DFA73996FA54A183B38AED0AA64F756A3918BAF08E061B",
                            networkType: .mijinTest)
                ],
                multisigAccounts: [])
        info[-3] = [multisigAccountInfo]

        let multisigAccountGraphInfo = MultisigAccountGraphInfo(multisigAccounts: info)

        XCTAssertEqual([-3] as Set<Int>, multisigAccountGraphInfo.levelsNumber)
        XCTAssertEqual(multisigAccountInfo, multisigAccountGraphInfo.multisigAccounts[-3]![0])
    }
}