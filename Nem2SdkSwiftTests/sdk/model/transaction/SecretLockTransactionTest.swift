// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

public class SecretLockTransactionTest: XCTestCase {
    let account = try! Account(privateKeyHexString: "787225aaff3d2c71f4ffa32d4f19ec4922f3cd869747f267378f81f8e3fcb12d", networkType: .mijinTest)


    func testSerialization() {
        // Generated at nem2-library-js/test/transactions/SecretLockTransaction.spec.js
        let expected: [UInt8] = [234,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,3,144,76,66,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,41,207,
            95,217,65,173,37,213,128,150,152,0,0,0,0,0,100,0,0,0,0,0,0,0,0,183,120,
            163,154,54,99,113,157,252,94,72,201,215,132,49,177,228,92,42,249,223,83,135,130,191,25,156,24,
            157,171,234,199,104,10,218,87,220,236,142,238,145,196,227,191,59,250,154,246,255,
            222,144,205,29,36,157,28,97,33,215,183,89,160,1,177,144,232,254,189,103,29,212,27,238,148,
            236,59,165,131,28,182,8,163,18,194,242,3,186,132,172]

        let secret = "b778a39a3663719dfc5e48c9d78431b1e45c2af9df538782bf199c189dabeac7680ada57dcec8eee91c4e3bf3bfa9af6ffde90cd1d249d1c6121d7b759a001b1".toBytesFromHexString()!
        let secretLock = SecretLockTransaction.create(
                mosaic: XEM.of(xemAmount: 10),
                duration: 100,
                hashType: .sha3_512,
                secret: secret,
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                networkType: .mijinTest,
                deadline: FakeDeadline()
        )

        var actual = secretLock.signWith(account: Account(networkType: .mijinTest)).payload
        // clear signature and signer
        for i in 4..<100 {
            actual[i] = 0
        }
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)
    }

    func testToAggregate() {
        let expected: [UInt8] = [-102,0,0,0,-102,73,54,100,6,-84,-87,82,-72,-117,-83,-11,-15,-23,-66,108,-28,-106,-127,
                                 65,3,90,96,-66,80,50,115,-22,101,69,107,36,3,144,76,66,41,207,
                                 95,217,65,173,37,213,128,150,152,0,0,0,0,0,100,0,0,0,0,0,0,0,0,183,120,
                                 163,154,54,99,113,157,252,94,72,201,215,132,49,177,228,92,42,249,223,83,135,130,191,25,156,24,
                                 157,171,234,199,104,10,218,87,220,236,142,238,145,196,227,191,59,250,154,246,255,
                                 222,144,205,29,36,157,28,97,33,215,183,89,160,1,177,144,232,254,189,103,29,212,27,238,148,
                                 236,59,165,131,28,182,8,163,18,194,242,3,186,132,172].map {
            if $0 < 0 {
                return UInt8(bitPattern: Int8($0))
            } else {
                return UInt8($0)
            }
        }

        let secret = "b778a39a3663719dfc5e48c9d78431b1e45c2af9df538782bf199c189dabeac7680ada57dcec8eee91c4e3bf3bfa9af6ffde90cd1d249d1c6121d7b759a001b1".toBytesFromHexString()!
        let secretLock = SecretLockTransaction.create(
                mosaic: XEM.of(xemAmount: 10),
                duration: 100,
                hashType: .sha3_512,
                secret: secret,
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                networkType: .mijinTest,
                deadline: FakeDeadline()
        )


        let actual = try! secretLock.toAggregate(signer: try! PublicAccount(publicKeyHexString: "9A49366406ACA952B88BADF5F1E9BE6CE4968141035A60BE503273EA65456B24", networkType: .mijinTest)).toAggregateTransactionBytes()
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)
    }

    func testSerializeAndSignTransaction() {
        let secret = "b778a39a3663719dfc5e48c9d78431b1e45c2af9df538782bf199c189dabeac7680ada57dcec8eee91c4e3bf3bfa9af6ffde90cd1d249d1c6121d7b759a001b1".toBytesFromHexString()!
        let secretLock = SecretLockTransaction.create(
                mosaic: XEM.of(xemAmount: 10),
                duration: 100,
                hashType: .sha3_512,
                secret: secret,
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                networkType: .mijinTest,
                deadline: FakeDeadline()
        )


        let signedTransaction = secretLock.signWith(account: account);
        XCTAssertEqual("EA0000005A3B75AE172855381353250EA9A1DFEB86E9280C0006B8FD997C2FCECF211C9A260E76CB704A22EAD4648F18E6931381921A4EDC7D309C32275D0147E9BAD3051026D70E1954775749C6811084D6450A3184D977383F0E4282CD47118AF3775503904C420000000000000000010000000000000029CF5FD941AD25D58096980000000000640000000000000000B778A39A3663719DFC5E48C9D78431B1E45C2AF9DF538782BF199C189DABEAC7680ADA57DCEC8EEE91C4E3BF3BFA9AF6FFDE90CD1D249D1C6121D7B759A001B190E8FEBD671DD41BEE94EC3BA5831CB608A312C2F203BA84AC", signedTransaction.payload.hexString.uppercased())
        XCTAssertEqual("B3AF46027909CD24204AF4E7B5B43C3116307D90A1F83A5DE6DBDF1F7759ABC5", signedTransaction.hash.hexString.uppercased())
    }
}


