// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


public class SecretProofTransactionTest: XCTestCase {
    let account = try! Account(privateKeyHexString: "787225aaff3d2c71f4ffa32d4f19ec4922f3cd869747f267378f81f8e3fcb12d", networkType: .mijinTest)

    func testSerialization() {
        // Generated at nem2-library-js/test/transactions/SecretProofTransaction.spec.js
        let expected: [UInt8] = [191, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                 0, 0, 0, 0, 0, 0, 0, 3, 144, 76, 67, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 183, 120, 163, 154, 54,
                                 99, 113, 157, 252, 94, 72, 201, 215, 132, 49, 177, 228, 92, 42, 249,
                                 223, 83, 135, 130, 191, 25, 156, 24, 157, 171, 234, 199, 104,
                                 10, 218, 87, 220, 236, 142, 238, 145, 196, 227, 191, 59, 250,
                                 154, 246, 255, 222, 144, 205, 29, 36, 157, 28, 97, 33, 215, 183, 89,
                                 160, 1, 177, 4, 0, 154, 73, 54, 100]

        let secret = "b778a39a3663719dfc5e48c9d78431b1e45c2af9df538782bf199c189dabeac7680ada57dcec8eee91c4e3bf3bfa9af6ffde90cd1d249d1c6121d7b759a001b1".toBytesFromHexString()!
        let secretSeed = "9a493664".toBytesFromHexString()!
        let secretProof = SecretProofTransaction.create(hashType: .sha3_512,
                secret: secret,
                proof: secretSeed,
                networkType: .mijinTest,
                deadline: FakeDeadline())

        var actual = secretProof.signWith(account: account).payload
        // clear signature and signer
        for i in 4..<100 {
            actual[i] = 0
        }
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)
    }

    func testToAggregate() {
        let expected: [UInt8] = [111,0,0,0,-102,73,54,100,6,-84,-87,82,-72,-117,-83,-11,-15,-23,-66,108,-28,-106,-127,
                                 65,3,90,96,-66,80,50,115,-22,101,69,107,36,3,144,76,67,0,183,120,163,154,54,
                                 99,113,157,252,94,72,201,215,132,49,177,228,92,42,249,
                                 223,83,135,130,191,25,156,24,157,171,234,199,104,
                                 10,218,87,220,236,142,238,145,196,227,191,59,250,
                                 154,246,255,222,144,205,29,36,157,28,97,33,215,183,89,
                                 160,1,177,4,0,154,73,54,100].map {
            if $0 < 0 {
                return UInt8(bitPattern: Int8($0))
            } else {
                return UInt8($0)
            }
        }
        let secret = "b778a39a3663719dfc5e48c9d78431b1e45c2af9df538782bf199c189dabeac7680ada57dcec8eee91c4e3bf3bfa9af6ffde90cd1d249d1c6121d7b759a001b1".toBytesFromHexString()!
        let secretSeed = "9a493664".toBytesFromHexString()!

        let secretProof = SecretProofTransaction.create(
                hashType: .sha3_512,
                secret: secret,
                proof: secretSeed,
                networkType: .mijinTest,
                deadline: FakeDeadline())

        let actual = try! secretProof.toAggregate(signer:try! PublicAccount(publicKeyHexString: "9A49366406ACA952B88BADF5F1E9BE6CE4968141035A60BE503273EA65456B24", networkType: .mijinTest)).toAggregateTransactionBytes()
        XCTAssertEqual(expected, actual)
    }

    func testSerializeAndSignTransaction() {
        let secret = "b778a39a3663719dfc5e48c9d78431b1e45c2af9df538782bf199c189dabeac7680ada57dcec8eee91c4e3bf3bfa9af6ffde90cd1d249d1c6121d7b759a001b1".toBytesFromHexString()!
        let secretSeed = "9a493664".toBytesFromHexString()!
        let secretProof = SecretProofTransaction.create(
                hashType: .sha3_512,
                secret: secret,
                proof: secretSeed,
                networkType: .mijinTest,
                deadline: FakeDeadline())

        let signedTransaction = secretProof.signWith(account: account)

        XCTAssertEqual("BF000000147827E5FDAB2201ABD3663964B0493166DA7DD18497718F53DF09AAFC55271B57A9E81B4E2F627FD19E9E9B77283D1620FB8E9E32BAC5AC265EB0B43C75B4071026D70E1954775749C6811084D6450A3184D977383F0E4282CD47118AF3775503904C430000000000000000010000000000000000B778A39A3663719DFC5E48C9D78431B1E45C2AF9DF538782BF199C189DABEAC7680ADA57DCEC8EEE91C4E3BF3BFA9AF6FFDE90CD1D249D1C6121D7B759A001B104009A493664", signedTransaction.payload.hexString.uppercased())
        XCTAssertEqual("1169864A7290940854D87C8818625A7A498E6550D19F9BFAF5BA7BEFEB9206D0", signedTransaction.hash.hexString.uppercased())
    }
}

