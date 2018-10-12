// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


class MosaicDefinitionTransactionTest: XCTestCase {

    func testCreateAMosaicCreationTransactionViaStaticConstructor() {
        let mosaicCreation = try! MosaicDefinitionTransaction.create(
                mosaicName: "mosaicname",
                namespaceFullName: "namespacename",
                mosaicProperties: MosaicProperties(isSupplyMutable: true, isTransferable: false, isLevyMutable: true, divisibility: 3, duration: 10),
                networkType: .mijinTest,
                deadline: Deadline(fromNow: 2 * 60 * 60)
        )

        XCTAssertEqual(NetworkType.mijinTest, mosaicCreation.networkType)
        XCTAssertEqual(2, mosaicCreation.version)
        XCTAssertEqual("mosaicname", mosaicCreation.mosaicName)
        XCTAssertTrue(Date() < mosaicCreation.deadline.date)
        XCTAssertEqual(0, mosaicCreation.fee)
        XCTAssertEqual(0, mosaicCreation.fee)
        XCTAssertEqual(6396233739721801544, mosaicCreation.namespaceId.id)
        XCTAssertEqual(UInt64(bitPattern: -5158169874280477899), mosaicCreation.mosaicId.id)

        XCTAssertEqual(true, mosaicCreation.mosaicProperties.isSupplyMutable)
        XCTAssertEqual(false, mosaicCreation.mosaicProperties.isTransferable)
        XCTAssertEqual(true, mosaicCreation.mosaicProperties.isLevyMutable)
        XCTAssertEqual(3, mosaicCreation.mosaicProperties.divisibility)
        XCTAssertEqual(10, mosaicCreation.mosaicProperties.duration)
    }

    func testSerialization() {
        let expected: [UInt8] = [ 156, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                  2,  144, 77, 65, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,  155,  138, 22, 28,  245, 9, 35,  144, 21,  153, 17,  174,  167, 46,  189, 60, 7, 1, 7, 4, 109, 111, 115, 97, 105, 99, 115, 2, 16, 39, 0, 0, 0, 0, 0, 0]

        let mosaicCreation = try! MosaicDefinitionTransaction.create(
                mosaicName: "mosaics",
                namespaceFullName: "sname",
                mosaicProperties: MosaicProperties(isSupplyMutable: true, isTransferable: true, isLevyMutable: true, divisibility: 4, duration: 10000),
                networkType: .mijinTest,
                deadline: FakeDeadline()
        )


        var actual = mosaicCreation.signWith(account: Account(networkType: .mijinTest)).payload
        // clear signature and signer
        for i in 4..<100 {
            actual[i] = 0
        }
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)
    }
}
