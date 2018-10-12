// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class AccountTest: XCTestCase {

    func testShouldCreateAccountViaConstructor() {
        let account = try! Account(
                privateKeyHexString: "787225aaff3d2c71f4ffa32d4f19ec4922f3cd869747f267378f81f8e3fcb12d",
                networkType: .mijinTest)

        XCTAssertEqual("SDRDGFTDLLCB67D4HPGIMIHPNSRYRJRT7DOBGWZY", account.address.plain);
        XCTAssertEqual("1026D70E1954775749C6811084D6450A3184D977383F0E4282CD47118AF37755", account.publicKeyHexString)
        XCTAssertEqual("787225AAFF3D2C71F4FFA32D4F19EC4922F3CD869747F267378F81F8E3FCB12D", account.privateKeyHexString)
    }


    func testShouldCreateAccountWithUppercasePrivateKey() {
        let account = try! Account(
                privateKeyHexString: "787225AAFF3D2C71F4FFA32D4F19EC4922F3CD869747F267378F81F8E3FCB12D",
                networkType: .mijinTest)

        XCTAssertEqual("SDRDGFTDLLCB67D4HPGIMIHPNSRYRJRT7DOBGWZY", account.address.plain);
        XCTAssertEqual("1026D70E1954775749C6811084D6450A3184D977383F0E4282CD47118AF37755", account.publicKeyHexString)
        XCTAssertEqual("787225AAFF3D2C71F4FFA32D4F19EC4922F3CD869747F267378F81F8E3FCB12D", account.privateKeyHexString)
    }


    func testShouldCreateAccountViaConstructor2() {
        let account = try! Account(
                privateKeyHexString: "5098D500390934F81EA416D9A2F50F276DE446E28488E1801212931E3470DA31",
                networkType: .mijinTest)
        XCTAssertEqual("5098D500390934F81EA416D9A2F50F276DE446E28488E1801212931E3470DA31", account.privateKeyHexString)
        XCTAssertEqual("9B800145F7228CE0014FC6FB44AD899BFCAD7B0CDF48DB63A7CC7299E373D734", account.publicKeyHexString)
        XCTAssertEqual("SAQC5A-K6X2K6-YYAI4L-2TQI2T-4ZRWAO-URYDYT-UO77", account.address.pretty)
    }

    func testShouldCreateAccountViaConstructor3() {
        let account = try! Account(
                privateKeyHexString: "B8AFAE6F4AD13A1B8AAD047B488E0738A437C7389D4FF30C359AC068910C1D59",
                networkType: .mijinTest)
        XCTAssertEqual("B8AFAE6F4AD13A1B8AAD047B488E0738A437C7389D4FF30C359AC068910C1D59", account.privateKeyHexString)
        XCTAssertEqual("68B3FBB18729C1FDE225C57F8CE080FA828F0067E451A3FD81FA628842B0B763", account.publicKeyHexString)
        XCTAssertEqual("SBE6CS7LZKJXLDVTNAC3VZ3AUVZDTF3PACNFIXFN", account.address.plain)
    }

    func testShouldSignTransaction() {
        let account = try! Account(privateKeyHexString: "787225aaff3d2c71f4ffa32d4f19ec4922f3cd869747f267378f81f8e3fcb12d", networkType: .mijinTest)
        let transferTransaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                mosaics: [Mosaic(id: MosaicId(id: 95442763262823), amount: 100)],
                message: PlainMessage.empty,
                networkType: .mijinTest,
                deadline: FakeDeadline())

        let signedTransaction = account.sign(transaction: transferTransaction)
        XCTAssertEqual("A5000000773891AD01DD4CDF6E3A55C186C673E256D7DF9D471846F1943CC3529E4E02B38B9AF3F8D13784645FF5FAAFA94A321B94933C673D12DE60E4BC05ABA56F750E1026D70E1954775749C6811084D6450A3184D977383F0E4282CD47118AF37755039054410000000000000000010000000000000090E8FEBD671DD41BEE94EC3BA5831CB608A312C2F203BA84AC01000100672B0000CE5600006400000000000000", signedTransaction.payload.hexString.uppercased())
        XCTAssertEqual("350AE56BC97DB805E2098AB2C596FA4C6B37EF974BF24DFD61CD9F77C7687424", signedTransaction.hash.hexString.uppercased())
    }
}