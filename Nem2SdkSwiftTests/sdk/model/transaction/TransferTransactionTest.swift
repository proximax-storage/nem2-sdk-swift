// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


class TransferTransactionTest: XCTestCase {
    var account: Account!

    override func setUp() {
        super.setUp()
        account = try! Account(privateKeyHexString: "787225aaff3d2c71f4ffa32d4f19ec4922f3cd869747f267378f81f8e3fcb12d", networkType: .mijinTest)
    }

    func testCreateATransferTransactionViaStaticConstructor() {
        let transaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26"),
                mosaics: [],
                message: PlainMessage.empty,
                networkType: .mijinTest,
                deadline: Deadline(fromNow: 60 * 60 * 2))

        XCTAssertEqual(NetworkType.mijinTest, transaction.networkType)
        XCTAssertEqual(3, transaction.version)
        XCTAssertTrue(Date() < transaction.deadline.date)
        XCTAssertEqual(0, transaction.fee)
        XCTAssertEqual(try! Address(rawAddress: "SDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26"), transaction.recipient)
        XCTAssertEqual(0, transaction.mosaics.count)
        XCTAssertNotNil(transaction.message)
    }


    func testSerialization() {
        // Generated at nem2-library-js/test/transactions/TransferTransaction.spec.js
        let expected: [UInt8] = [165, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                 3, 144, 84, 65, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 144, 232, 254, 189, 103, 29, 212, 27, 238, 148, 236, 59, 165, 131, 28, 182, 8, 163, 18, 194, 242, 3, 186, 132, 172,
                                 1, 0, 1, 0, 103, 43, 0, 0, 206, 86, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0]

        let transferTransaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                mosaics: [Mosaic(id: MosaicId(id: 95442763262823), amount: 100)],
                message: PlainMessage.empty,
                networkType: .mijinTest,
                deadline: FakeDeadline())

        var actual = transferTransaction.signWith(account: account).payload
        // clear signature and signer
        for i in 4..<100 {
            actual[i] = 0
        }
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)
    }


    func testToAggregate() {
        let expectedOriginal: [Int8] = [85,0,0,0,-102,73,54,100,6,-84,-87,82,-72,-117,-83,-11,-15,-23,-66,108,-28,-106,-127,
                                 65,3,90,96,-66,80,50,115,-22,101,69,107,36,3,-112,84,65,-112,-24,-2,-67,103,29,-44,27,-18,-108,-20,59,
                                 -91,-125,28,-74,8,-93,18,-62,-14,3,-70,-124,-84,1,0,1,0,103,43,0,0,-50,86,0,0,100,0,0,0,0,0,0,0]

        let expected: [UInt8] = expectedOriginal.map { UInt8(bitPattern: $0)}

        let transferTransaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                mosaics: [Mosaic(id: MosaicId(id: 95442763262823), amount: 100)],
                message: PlainMessage.empty,
                networkType: .mijinTest,
                deadline: FakeDeadline())
                .toAggregate(signer: try! PublicAccount(publicKeyHexString: "9A49366406ACA952B88BADF5F1E9BE6CE4968141035A60BE503273EA65456B24", networkType: .mijinTest))

        let actual = try! transferTransaction.toAggregateTransactionBytes()
        XCTAssertEqual(actual.count, expected.count)
        XCTAssertEqual(actual, expected)
    }

    func testSerializeAndSignTransaction() {
        let transferTransaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                mosaics: [Mosaic(id: MosaicId(id: 95442763262823), amount: 100)],
                message: PlainMessage.empty,
                networkType: .mijinTest,
                deadline: FakeDeadline())

        let signedTransaction = transferTransaction.signWith(account: account);
        XCTAssertEqual("A5000000773891AD01DD4CDF6E3A55C186C673E256D7DF9D471846F1943CC3529E4E02B38B9AF3F8D13784645FF5FAAFA94A321B94933C673D12DE60E4BC05ABA56F750E1026D70E1954775749C6811084D6450A3184D977383F0E4282CD47118AF37755039054410000000000000000010000000000000090E8FEBD671DD41BEE94EC3BA5831CB608A312C2F203BA84AC01000100672B0000CE5600006400000000000000", signedTransaction.payload.hexString.uppercased())
        XCTAssertEqual("350AE56BC97DB805E2098AB2C596FA4C6B37EF974BF24DFD61CD9F77C7687424", signedTransaction.hash.hexString.uppercased())
    }
}
