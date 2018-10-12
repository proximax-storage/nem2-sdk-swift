// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


class MosaicSupplyChangeTransactionTest: XCTestCase {

    func testCreateAMosaicSupplyChangeTransactionViaConstructor() {
        let mosaicSupplyChangeTx = MosaicSupplyChangeTransaction.create(
                mosaicId: MosaicId(id: 6300565133566699912),
                mosaicSupplyType: .increase,
                delta: 10,
                networkType: .mijinTest,
                deadline: Deadline(fromNow: 2 * 60 * 60))

        XCTAssertEqual(NetworkType.mijinTest, mosaicSupplyChangeTx.networkType)
        XCTAssertEqual(2, mosaicSupplyChangeTx.version)
        XCTAssertTrue(Date() < mosaicSupplyChangeTx.deadline.date)
        XCTAssertEqual(0, mosaicSupplyChangeTx.fee)

        XCTAssertEqual(6300565133566699912, mosaicSupplyChangeTx.mosaicId.id)
        XCTAssertEqual(MosaicSupplyType.increase, mosaicSupplyChangeTx.mosaicSupplyType)
        XCTAssertEqual(10, mosaicSupplyChangeTx.delta)
    }

    func testSerialization() {
        // Generated at nem2-library-js/test/transactions/MosaicSupplyChangeTransaction.spec.js
        let expected: [UInt8] = [137,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                 2,144,77,66,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,136,105,116,110,155,26,112,87,1,10,0,0,0,0,0,0,0]

        let mosaicSupplyChangeTransaction = MosaicSupplyChangeTransaction.create(
                mosaicId: MosaicId(id: 6300565133566699912),
                mosaicSupplyType: .increase,
                delta: 10,
                networkType: .mijinTest,
                deadline: FakeDeadline())

        var actual = mosaicSupplyChangeTransaction.signWith(account: Account(networkType: .mijinTest)).payload
        // clear signature and signer
        for i in 4..<100 {
            actual[i] = 0
        }
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)
    }
}
