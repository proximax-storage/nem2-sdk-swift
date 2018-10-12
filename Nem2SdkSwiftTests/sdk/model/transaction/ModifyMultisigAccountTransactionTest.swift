// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


class ModifyMultisigAccountTransactionTest: XCTestCase {

    func testCreateAMultisigModificationTransactionViaConstructor() {
        let modifyMultisigAccountTransaction = ModifyMultisigAccountTransaction.create(
                minApprovalDelta: 2,
                minRemovalDelta: 1,
                modifications: [MultisigCosignatoryModification(type: .add, cosignatory: try! PublicAccount(publicKeyHexString: "68b3fbb18729c1fde225c57f8ce080fa828f0067e451a3fd81fa628842b0b763", networkType: .mijinTest))],
                networkType: .mijinTest,
                deadline: Deadline(fromNow: 2 * 60 * 60))

        XCTAssertEqual(NetworkType.mijinTest, modifyMultisigAccountTransaction.networkType)
        XCTAssertEqual(3, modifyMultisigAccountTransaction.version)
        XCTAssertTrue(Date() < modifyMultisigAccountTransaction.deadline.date)
        XCTAssertEqual(0, modifyMultisigAccountTransaction.fee)

        XCTAssertEqual(2, modifyMultisigAccountTransaction.minApprovalDelta)
        XCTAssertEqual(1, modifyMultisigAccountTransaction.minRemovalDelta)

        XCTAssertEqual("68b3fbb18729c1fde225c57f8ce080fa828f0067e451a3fd81fa628842b0b763".uppercased(), modifyMultisigAccountTransaction.modifications[0].cosignatory.publicKey.description)
        XCTAssertEqual(MultisigCosignatoryModificationType.add, modifyMultisigAccountTransaction.modifications[0].type)
    }

    func testSerialization() {
        // Generated at nem2-library-js/test/transactions/ModifyMultisigAccountTransaction.spec.js
        let expected: [UInt8] = [ 189, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                  3,  144, 85, 65, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 0, 104,  179,  251,  177,  135, 41,  193,  253,  226, 37,  197, 127,  140,  224,  128,  250,  130,  143, 0, 103,  228, 81,  163,  253,  129,  250, 98,  136, 66,  176,  183, 99, 0,  207,  137, 63,  252,  196, 124, 51,  231,  246,  138,  177,  219, 86, 54, 92, 21, 107, 7, 54,  130, 74, 12, 30, 39, 63,  158, 0,  184,  223,  143, 1,  235]

        let modifyMultisigAccountTransaction = ModifyMultisigAccountTransaction.create(
                minApprovalDelta: 2,
                minRemovalDelta: 1,
                modifications: [
                    MultisigCosignatoryModification(type: .add, cosignatory: try! PublicAccount(publicKeyHexString: "68b3fbb18729c1fde225c57f8ce080fa828f0067e451a3fd81fa628842b0b763", networkType: .mijinTest)),
                    MultisigCosignatoryModification(type: .add, cosignatory: try! PublicAccount(publicKeyHexString: "cf893ffcc47c33e7f68ab1db56365c156b0736824a0c1e273f9e00b8df8f01eb", networkType: .mijinTest))
                ],
                networkType: .mijinTest,
                deadline: FakeDeadline())

        var actual = modifyMultisigAccountTransaction.signWith(account: Account(networkType: .mijinTest)).payload
        // clear signature and signer
        for i in 4..<100 {
            actual[i] = 0
        }
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)
}
}
