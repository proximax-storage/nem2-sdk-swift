// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class RegisterNamespaceTransactionTest: XCTestCase {

    func testCreateANamespaceCreationRootNamespaceTransactionViaStaticConstructor() {
        let registerNamespaceTransaction = try! RegisterNamespaceTransaction.createRootNamespace(
                namespaceName: "newnamespace",
                duration: 2000,
                networkType: .mijinTest,
                deadline: Deadline(fromNow: 2 * 60 * 60))

        XCTAssertEqual(NetworkType.mijinTest, registerNamespaceTransaction.networkType)
        XCTAssertEqual(2, registerNamespaceTransaction.version)
        XCTAssertTrue(Date() < registerNamespaceTransaction.deadline.date)
        XCTAssertEqual(0, registerNamespaceTransaction.fee)
        XCTAssertEqual("newnamespace", registerNamespaceTransaction.namespaceName)
        XCTAssertEqual(NamespaceType.rootNamespace, registerNamespaceTransaction.namespaceType)
        XCTAssertEqual(4635294387305441662, registerNamespaceTransaction.namespaceId.id)
        XCTAssertEqual(2000, registerNamespaceTransaction.duration)
    }

    func testCreateANamespaceCreationSubNamespaceTransactionViaStaticConstructor() {
        let registerNamespaceTransaction = try! RegisterNamespaceTransaction.createSubNamespace(
                namespaceName: "newnamespace",
                parentId: NamespaceId(id: 4635294387305441662),
                networkType: .mijinTest,
                deadline: Deadline(fromNow: 2 * 60 * 60))


        XCTAssertEqual(NetworkType.mijinTest, registerNamespaceTransaction.networkType)
        XCTAssertEqual(2, registerNamespaceTransaction.version)
        XCTAssertTrue(Date() < registerNamespaceTransaction.deadline.date)
        XCTAssertEqual(0, registerNamespaceTransaction.fee)
        XCTAssertEqual("newnamespace", registerNamespaceTransaction.namespaceName)
        XCTAssertEqual(NamespaceType.subNamespace, registerNamespaceTransaction.namespaceType)
        XCTAssertEqual(UInt64(bitPattern: -7487193294859220686), registerNamespaceTransaction.namespaceId.id)
        XCTAssertEqual(4635294387305441662, registerNamespaceTransaction.parentId?.id)
    }

    func testSerializationRootNamespace() {
        // Generated at nem2-library-js/test/transactions/RegisterNamespaceTransaction.spec.js
        let expected: [UInt8] = [150,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                 2, 144, 78, 65, 0, 0, 0, 0, 0, 0, 0, 0,1,0,0,0,0,0,0,0,0,16,39,0,0,0,0,0,0,126,233,179,184,175,223,83,64,12,110,101,119,110,97,109,101,115,112,97,99,101]

        let registerNamespaceTransaction = try! RegisterNamespaceTransaction.createRootNamespace(
                namespaceName: "newnamespace",
                duration: 10000,
                networkType: .mijinTest,
                deadline: FakeDeadline())

        var actual = registerNamespaceTransaction.signWith(account: Account(networkType: .mijinTest)).payload
        // clear signature and signer
        for i in 4..<100 {
            actual[i] = 0
        }
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)
    }

    func testSerializationSubNamespace() {
        // Generated at nem2-library-js/test/transactions/RegisterNamespaceTransaction.spec.js
        let expected: [UInt8] = [150,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                 2,144,78,65,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,126,233,179,184,175,223,83,64,3,18,152,27,120,121,163,113,12,115,117,98,110,97,109,101,115,112,97,99,101]

        let registerNamespaceTransaction = try! RegisterNamespaceTransaction.createSubNamespace(
                namespaceName: "subnamespace",
                parentId: NamespaceId(id: 4635294387305441662),
                networkType: .mijinTest,
                deadline: FakeDeadline())

        var actual = registerNamespaceTransaction.signWith(account: Account(networkType: .mijinTest)).payload
        // clear signature and signer
        for i in 4..<100 {
            actual[i] = 0
        }
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)

}
}
