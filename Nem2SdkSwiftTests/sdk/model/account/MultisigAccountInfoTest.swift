// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class MultisigAccountInfoTest: XCTestCase {
    private let account1 = try! PublicAccount(publicKeyHexString: "b4f12e7c9f6946091e2cb8b6d3a12b50d17ccbbf646386ea27ce2946a7423dcf", networkType: .mijinTest)
    private let account2 = try! PublicAccount(publicKeyHexString: "846b4439154579a5903b1459c9cf69cb8153f6d0110a7a0ed61de29ae4810bf2", networkType: .mijinTest)
    private let account3 = try! PublicAccount(publicKeyHexString: "cf893ffcc47c33e7f68ab1db56365c156b0736824a0c1e273f9e00b8df8f01eb", networkType: .mijinTest)
    private let account4 = try! PublicAccount(publicKeyHexString: "68b3fbb18729c1fde225c57f8ce080fa828f0067e451a3fd81fa628842b0b763", networkType: .mijinTest)


    func testShouldBeCreated() {
        let multisigAccountInfo = MultisigAccountInfo(
                account: account1,
                minApproval: 2,
                minRemoval: 1,
                cosignatories: [account2],
                multisigAccounts: []
        )
        XCTAssertEqual(account1, multisigAccountInfo.account)
        XCTAssertEqual(2, multisigAccountInfo.minApproval)
        XCTAssertEqual(1, multisigAccountInfo.minRemoval)
        XCTAssertEqual(1, multisigAccountInfo.cosignatories.count)
    }

    func testIsCosignerShouldReturnTrueWhenTheAccountIsInTheCosignatoriesList() {
        let multisigAccountInfo = MultisigAccountInfo(
                account: account1,
                minApproval: 2,
                minRemoval: 1,
                cosignatories: [account2, account3],
                multisigAccounts: []
        )

        XCTAssertTrue(multisigAccountInfo.hasCosigner(account: account2))
    }

    func testIsCosignatoryShouldReturnFalseWhenTheAccountIsNotInTHeCosignatoriesList() {
        let multisigAccountInfo = MultisigAccountInfo(
                account: account1,
                minApproval: 2,
                minRemoval: 1,
                cosignatories: [account2, account3],
                multisigAccounts: []
        )
        XCTAssertFalse(multisigAccountInfo.hasCosigner(account: account4))
    }


    func testIsCosignerOfMultisigAccountShouldReturnTrueWhenItContainsThatAccountInMultisigList() {
        let multisigAccountInfo = MultisigAccountInfo(
                account: account1,
                minApproval: 2,
                minRemoval: 1,
                cosignatories: [],
                multisigAccounts: [account2, account3]
        )

        XCTAssertTrue(multisigAccountInfo.isCosignerOf(account: account2))
    }


    func testIsCosignerOfMultisigAccountShouldReturnFalseWhenItDoesNotContainsThatAccountInMultisigList() {
        let multisigAccountInfo = MultisigAccountInfo(
                account: account1,
                minApproval: 2,
                minRemoval: 1,
                cosignatories: [],
                multisigAccounts: [account2, account3]
        )

        XCTAssertFalse(multisigAccountInfo.isCosignerOf(account: account4))
    }

    func testReturnCosignersList() {
        let multisigAccountInfo = MultisigAccountInfo(
                account: account1,
                minApproval: 2,
                minRemoval: 1,
                cosignatories: [account2, account3],
                multisigAccounts: []
        )
        XCTAssertEqual([account2, account3], multisigAccountInfo.cosignatories)
    }


    func testReturnMultisigList() {
        let multisigAccountInfo = MultisigAccountInfo(
                account: account1,
                minApproval: 2,
                minRemoval: 1,
                cosignatories: [],
                multisigAccounts: [account2, account3]
        )
        XCTAssertEqual([account2, account3], multisigAccountInfo.multisigAccounts)
    }

    func testIsMultisigShouldReturnFalseWhenMinApprovalIs0() {
        let multisigAccountInfo = MultisigAccountInfo(
                account: account1,
                minApproval: 0,
                minRemoval: 1,
                cosignatories: [],
                multisigAccounts: [account2, account3]
        )
        XCTAssertFalse(multisigAccountInfo.isMultisig)
    }

    func testIsMultisigShouldReturnFalseWhenMinRemovalIs0() {
        let multisigAccountInfo = MultisigAccountInfo(
                account: account1,
                minApproval: 1,
                minRemoval: 0,
                cosignatories: [],
                multisigAccounts: [account2, account3]
        )
        XCTAssertFalse(multisigAccountInfo.isMultisig)
    }

    func testIsMultisigShouldReturnTrueWhenMinRemovalAndMinApprovalIsNot0() {
        let multisigAccountInfo = MultisigAccountInfo(
                account: account1,
                minApproval: 1,
                minRemoval: 1,
                cosignatories: [],
                multisigAccounts: [account2, account3]
        )
        XCTAssertTrue(multisigAccountInfo.isMultisig)
    }
}