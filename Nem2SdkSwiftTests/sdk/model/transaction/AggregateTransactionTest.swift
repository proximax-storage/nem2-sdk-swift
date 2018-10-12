// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

public class AggregateTransactionTest: XCTestCase {

    func testCreateAAggregateTransactionViaStaticConstructor() {
        let transferTx = TransferTransaction.create(
                        recipient: try! Address(rawAddress: "SDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26"),
                        mosaics: [],
                        message: PlainMessage.empty,
                        networkType: .mijinTest,
                        deadline: Deadline(fromNow: 2 * 60 * 60))
                .toAggregate(signer: try! PublicAccount(publicKeyHexString: "9A49366406ACA952B88BADF5F1E9BE6CE4968141035A60BE503273EA65456B24", networkType: .mijinTest))

        let aggregateTx = try! AggregateTransaction.createComplete(
                innerTransactions: [transferTx],
                networkType: .mijinTest,
                deadline: Deadline(fromNow: 2 * 60 * 60))

        XCTAssertEqual(NetworkType.mijinTest, aggregateTx.networkType)
        XCTAssertEqual(2, aggregateTx.version)
        XCTAssertTrue(Date() < aggregateTx.deadline.date)
        XCTAssertEqual(0, aggregateTx.fee)
        XCTAssertEqual(1, aggregateTx.innerTransactions.count)
    }

    func testSerialization() {
        // Generated at nem2-library-js/test/transactions/RegisterNamespaceTransaction.spec.js
        let expected: [UInt8] = [209, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                 2, 144, 65, 65, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 85, 0, 0, 0, 85, 0, 0, 0, 132, 107, 68, 57, 21, 69, 121, 165, 144, 59, 20, 89,
                                 201, 207, 105, 203, 129, 83, 246, 208, 17, 10, 122, 14, 214, 29, 226, 154,
                                 228, 129, 11, 242, 3, 144, 84, 65, 144, 80, 185, 131, 126, 250, 180,
                                 187, 232, 164, 185, 187, 50, 216, 18, 249, 136, 92, 0, 216, 252,
                                 22, 80, 225, 66, 1, 0, 1, 0, 41, 207, 95, 217, 65, 173, 37, 213, 128, 150, 152, 0, 0, 0, 0, 0]

        let transferTx = TransferTransaction.create(
                        recipient: try! Address(rawAddress: "SBILTA367K2LX2FEXG5TFWAS7GEFYAGY7QLFBYKC"),
                        mosaics: [XEM.of(microXemAmount: 10000000)],
                        message: PlainMessage.empty,
                        networkType: .mijinTest,
                        deadline: FakeDeadline())

                .toAggregate(signer: try! PublicAccount(publicKeyHexString: "846B4439154579A5903B1459C9CF69CB8153F6D0110A7A0ED61DE29AE4810BF2", networkType: .mijinTest))

        let aggregateTx = try! AggregateTransaction.createComplete(
                innerTransactions: [transferTx],
                networkType: .mijinTest,
                deadline: FakeDeadline())

        var actual = aggregateTx.signWith(account: Account(networkType: .mijinTest)).payload
        // clear signature and signer
        for i in 4..<100 {
            actual[i] = 0
        }
        XCTAssertEqual(expected.count, actual.count)
        XCTAssertEqual(expected, actual)
    }

    func testShouldCreateAggregateTransactionAndSignWithMultipleCosignatories() {
        let transferTx = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SBILTA367K2LX2FEXG5TFWAS7GEFYAGY7QLFBYKC"),
                mosaics: [],
                message: PlainMessage(text: "test-message"),
                networkType: .mijinTest,
                deadline: FakeDeadline())
                .toAggregate(signer: try! PublicAccount(publicKeyHexString: "B694186EE4AB0558CA4AFCFDD43B42114AE71094F5A1FC4A913FE9971CACD21D", networkType: .mijinTest))

        let aggregateTx = try! AggregateTransaction.createComplete(
                innerTransactions: [transferTx],
                networkType: .mijinTest,
                deadline: FakeDeadline())

        let cosignatoryAccount = try! Account(privateKeyHexString: "2a2b1f5d366a5dd5dc56c3c757cf4fe6c66e2787087692cf329d7a49a594658b", networkType: .mijinTest)
        let cosignatoryAccount2 = try! Account(privateKeyHexString: "b8afae6f4ad13a1b8aad047b488e0738a437c7389d4ff30c359ac068910c1d59", networkType: .mijinTest)

        let signedTransaction = cosignatoryAccount.sign(aggregateTransaction: aggregateTx, with: [cosignatoryAccount2])

        XCTAssertEqual("2d010000", Array(signedTransaction.payload[0..<4]).hexString)
        XCTAssertEqual("5100000051000000", Array(signedTransaction.payload[120..<128]).hexString)
        //assertEquals("039054419050B9837EFAB4BBE8A4B9BB32D812F9885C00D8FC1650E1420D000000746573742D6D65737361676568B3FBB18729C1FDE225C57F8CE080FA828F0067E451A3FD81FA628842B0B763", signedTransaction.getPayload().substring(320, 474));
    }

    func testShouldFindAccountInAsASignerOfTheTransaction() {
        let dtoString = "{\"meta\":{\"hash\":\"671653C94E2254F2A23EFEDB15D67C38332AED1FBD24B063C0A8E675582B6A96\",\"height\":[18160,0],\"id\":\"5A0069D83F17CF0001777E55\",\"index\":0,\"merkleComponentHash\":\"81E5E7AE49998802DABC816EC10158D3A7879702FF29084C2C992CD1289877A7\"},\"transaction\":{\"cosignatures\":[{\"signature\":\"5780C8DF9D46BA2BCF029DCC5D3BF55FE1CB5BE7ABCF30387C4637DDEDFC2152703CA0AD95F21BB9B942F3CC52FCFC2064C7B84CF60D1A9E69195F1943156C07\",\"signer\":\"A5F82EC8EBB341427B6785C8111906CD0DF18838FB11B51CE0E18B5E79DFF630\"}],\"deadline\":[3266625578,11],\"fee\":[0,0],\"signature\":\"939673209A13FF82397578D22CC96EB8516A6760C894D9B7535E3A1E068007B9255CFA9A914C97142A7AE18533E381C846B69D2AE0D60D1DC8A55AD120E2B606\",\"signer\":\"7681ED5023141D9CDCF184E5A7B60B7D466739918ED5DA30F7E71EA7B86EFF2D\",\"transactions\":[{\"meta\":{\"aggregateHash\":\"3D28C804EDD07D5A728E5C5FFEC01AB07AFA5766AE6997B38526D36015A4D006\",\"aggregateId\":\"5A0069D83F17CF0001777E55\",\"height\":[18160,0],\"id\":\"5A0069D83F17CF0001777E56\",\"index\":0},\"transaction\":{\"message\":{\"payload\":\"746573742D6D657373616765\",\"type\":0},\"mosaics\":[{\"amount\":[3863990592,95248],\"id\":[3646934825,3576016193]}],\"recipient\":\"9050B9837EFAB4BBE8A4B9BB32D812F9885C00D8FC1650E142\",\"signer\":\"B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF\",\"type\":16724,\"version\":36867}}],\"type\":16705,\"version\":36867}}"

        let decoder = JSONDecoder()

        let decoded = try! decoder.decode(AnyObjectDictionary.self, from: dtoString.data(using: .utf8)!)

        let aggregateTransferTransaction = try! TransactionMapping.apply(decoded) as! AggregateTransaction

        XCTAssertTrue(aggregateTransferTransaction.signedByAccount(
                publicAccount: try! PublicAccount(publicKeyHexString: "A5F82EC8EBB341427B6785C8111906CD0DF18838FB11B51CE0E18B5E79DFF630", networkType: .mijinTest)))

        XCTAssertTrue(aggregateTransferTransaction.signedByAccount(
                publicAccount: try! PublicAccount(publicKeyHexString: "7681ED5023141D9CDCF184E5A7B60B7D466739918ED5DA30F7E71EA7B86EFF2D", networkType: .mijinTest)))

        XCTAssertFalse(aggregateTransferTransaction.signedByAccount(
                publicAccount: try! PublicAccount(publicKeyHexString: "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF", networkType: .mijinTest)))
    }

}
