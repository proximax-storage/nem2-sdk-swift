// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

public class CosignatureTransactionTest: XCTestCase {
    let account = try! Account(privateKeyHexString: "26b64cb10f005e5988a36744ca19e20d835ccc7c105aaa5f3b212da593180930", networkType: .mijinTest)

    func testCreateACosignatureTransactionViaConstructor() {
        let dtoString = "{\"meta\":{\"hash\":\"671653C94E2254F2A23EFEDB15D67C38332AED1FBD24B063C0A8E675582B6A96\",\"height\":[18160,0],\"id\":\"5A0069D83F17CF0001777E55\",\"index\":0,\"merkleComponentHash\":\"81E5E7AE49998802DABC816EC10158D3A7879702FF29084C2C992CD1289877A7\"},\"transaction\":{\"cosignatures\":[{\"signature\":\"5780C8DF9D46BA2BCF029DCC5D3BF55FE1CB5BE7ABCF30387C4637DDEDFC2152703CA0AD95F21BB9B942F3CC52FCFC2064C7B84CF60D1A9E69195F1943156C07\",\"signer\":\"A5F82EC8EBB341427B6785C8111906CD0DF18838FB11B51CE0E18B5E79DFF630\"}],\"deadline\":[3266625578,11],\"fee\":[0,0],\"signature\":\"939673209A13FF82397578D22CC96EB8516A6760C894D9B7535E3A1E068007B9255CFA9A914C97142A7AE18533E381C846B69D2AE0D60D1DC8A55AD120E2B606\",\"signer\":\"7681ED5023141D9CDCF184E5A7B60B7D466739918ED5DA30F7E71EA7B86EFF2D\",\"transactions\":[{\"meta\":{\"aggregateHash\":\"3D28C804EDD07D5A728E5C5FFEC01AB07AFA5766AE6997B38526D36015A4D006\",\"aggregateId\":\"5A0069D83F17CF0001777E55\",\"height\":[18160,0],\"id\":\"5A0069D83F17CF0001777E56\",\"index\":0},\"transaction\":{\"message\":{\"payload\":\"746573742D6D657373616765\",\"type\":0},\"mosaics\":[{\"amount\":[3863990592,95248],\"id\":[3646934825,3576016193]}],\"recipient\":\"9050B9837EFAB4BBE8A4B9BB32D812F9885C00D8FC1650E142\",\"signer\":\"B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF\",\"type\":16724,\"version\":36867}}],\"type\":16705,\"version\":36867}}"

        let decoder = JSONDecoder()

        let decoded = try! decoder.decode(AnyObjectDictionary.self, from: dtoString.data(using: .utf8)!)

        let aggregateTransaction = try! TransactionMapping.apply(decoded) as! AggregateTransaction

        let cosignatureTransaction = try! CosignatureTransaction(transactionToCosign: aggregateTransaction)

        let cosignatureSignedTransaction = account.sign(cosignatureTransaction: cosignatureTransaction)

        XCTAssertNotNil(aggregateTransaction.transactionInfo?.hash)
        XCTAssertEqual(aggregateTransaction.transactionInfo?.hash, cosignatureSignedTransaction.parentHash)
        XCTAssertEqual("bf3bc39f2292c028cb0ffa438a9f567a7c4d793d2f8522c8deac74befbcb61af6414adf27b2176d6a24fef612aa6db2f562176a11c46ba6d5e05430042cb5705".toBytesFromHexString()!, cosignatureSignedTransaction.signature)
        XCTAssertEqual("671653C94E2254F2A23EFEDB15D67C38332AED1FBD24B063C0A8E675582B6A96".toBytesFromHexString()!, cosignatureTransaction.transactionToCosign.transactionInfo?.hash)
    }

    func testShouldThrowExceptionWhenTransactionToCosignHasNotBeenAnnounced() {
        let aggregateTransaction = try! AggregateTransaction.createComplete(
                innerTransactions: [],
                networkType: .mijinTest,
                deadline: Deadline(fromNow: 2 * 60 * 60))

        TestUtils.expectIllegalArgument(message: "Transaction to cosign should be announced before being able to cosign it") {
            _ = try CosignatureTransaction(transactionToCosign: aggregateTransaction)
        }
    }
}
