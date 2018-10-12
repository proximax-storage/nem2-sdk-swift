// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


class LockFundsTransactionTest: XCTestCase {
    private let account = try! Account(privateKeyHexString: "787225aaff3d2c71f4ffa32d4f19ec4922f3cd869747f267378f81f8e3fcb12d", networkType: .mijinTest)


    func testSerialization() {
        // Generated at nem2-library-js/test/transactions/LockFundsTransaction.spec.js
        let expected: [UInt8] = [176,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,3,144,76,65,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,41,207,95,
            217,65,173,37,213,128,150,152,0,0,0,0,0,100,0,0,0,0,0,0,0,132,
            152,179,141,137,193,220,138,68,142,165,130,73,
            56,255,130,137,38,205,159,119,71,177,132,75,89,180,182,
            128,126,135,139]

        let signedTransaction = SignedTransaction(
                payload: Array("payload".utf8),
                hash: "8498B38D89C1DC8A448EA5824938FF828926CD9F7747B1844B59B4B6807E878B".toBytesFromHexString()!,
                type: .aggregateBonded)
        let lockFunds = try! LockFundsTransaction.create(
                mosaic: XEM.of(xemAmount: Decimal(10)),
                duration: 100,
                signedTransaction: signedTransaction,
                networkType: .mijinTest,
                deadline: FakeDeadline()
        )

        var actual = lockFunds.signWith(account: account).payload
        // clear signature and signer
        for i in 4..<100 { actual[i] = 0 }
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)
    }

    func testToAggregate() {
        let expected: [UInt8] = [96,0,0,0,-102,73,54,100,6,-84,-87,82,-72,-117,-83,-11,-15,-23,-66,108,-28,-106,-127,
                                     65,3,90,96,-66,80,50,115,-22,101,69,107,36,3,144,76,65,41,207,95,
                                     217,65,173,37,213,128,150,152,0,0,0,0,0,100,0,0,0,0,0,0,0,132,
                                     152,179,141,137,193,220,138,68,142,165,130,73,
                                     56,255,130,137,38,205,159,119,71,177,132,75,89,180,182,
                                     128,126,135,139].map {
            if $0 < 0 {
                return UInt8(bitPattern: Int8($0))
            } else {
                return UInt8($0)
            }
        }

        let signedTransaction = SignedTransaction(
                payload: Array("payload".utf8),
                hash: "8498B38D89C1DC8A448EA5824938FF828926CD9F7747B1844B59B4B6807E878B".toBytesFromHexString()!,
                type: .aggregateBonded)

        let lockFunds = try! LockFundsTransaction.create(
                mosaic: XEM.of(xemAmount: Decimal(10)),
                duration: 100,
                signedTransaction: signedTransaction,
                networkType: .mijinTest,
                deadline: FakeDeadline()
        )

        let actual = try! lockFunds.toAggregate(signer: try! PublicAccount(publicKeyHexString: "9A49366406ACA952B88BADF5F1E9BE6CE4968141035A60BE503273EA65456B24", networkType: .mijinTest)).toAggregateTransactionBytes()
        XCTAssertEqual(expected, actual)
    }

    func testSerializeAndSignTransaction() {
        let signedTransaction = SignedTransaction(
                payload: Array("payload".utf8),
                hash: "8498B38D89C1DC8A448EA5824938FF828926CD9F7747B1844B59B4B6807E878B".toBytesFromHexString()!,
                type: .aggregateBonded)

        let lockFunds = try! LockFundsTransaction.create(
                mosaic: XEM.of(xemAmount: Decimal(10)),
                duration: 100,
                signedTransaction: signedTransaction,
                networkType: .mijinTest,
                deadline: FakeDeadline()
        )

        let lockFundsTransactionSigned = lockFunds.signWith(account: account)
        XCTAssertEqual("B0000000D079047B87DCEDA0DE68558C1322A453D55D52BDA2778D66C5344BF79EE9E946C731F9ED565E5A854AFC0A1E1476B571940F920F33ADD9BAC245DB46A59794051026D70E1954775749C6811084D6450A3184D977383F0E4282CD47118AF3775503904C410000000000000000010000000000000029CF5FD941AD25D5809698000000000064000000000000008498B38D89C1DC8A448EA5824938FF828926CD9F7747B1844B59B4B6807E878B", lockFundsTransactionSigned.payload.hexString.uppercased())
        XCTAssertEqual("1F8A695B23F595646D43307DE0C6487AC642520FD31ACC6E6F8163AD2DD98B5A", lockFundsTransactionSigned.hash.hexString.uppercased())
    }


    func testShouldThrowExceptionWhenSignedTransactionIsNotTypeAggregateBonded() {
        let signedTransaction = SignedTransaction(
                payload: Array("payload".utf8),
                hash: "8498B38D89C1DC8A448EA5824938FF828926CD9F7747B1844B59B4B6807E878B".toBytesFromHexString()!,
                type: .transfer)

        TestUtils.expectIllegalArgument(message: "Signed transaction must be Aggregate Bonded Transaction") {
            _ = try LockFundsTransaction.create(
                    mosaic: XEM.of(xemAmount: Decimal(10)),
                    duration: 100,
                    signedTransaction: signedTransaction,
                    networkType: .mijinTest,
                    deadline: FakeDeadline()
            )
        }
    }
}

