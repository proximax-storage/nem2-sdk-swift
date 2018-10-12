// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

public class TransactionTest: XCTestCase {
    private let signer = try! PublicAccount(publicKeyHexString: "b4f12e7c9f6946091e2cb8b6d3a12b50d17ccbbf646386ea27ce2946a7423dcf", networkType: .mijinTest)


    func separatePayload(_ payload: String) -> (signature: [UInt8], signer: [UInt8], message: [UInt8]) {
        let bytes = payload.toBytesFromHexString()!
        return (signature: Array(bytes[4..<68]), signer: Array(bytes[68..<100]), message: Array(bytes[100..<bytes.count]))
    }

    func testGenerateHashFromTransferTransactionPayload() {
        let args = separatePayload("C7000000D0B190DFEEAB0378F943F79CDB7BC44453491890FAA70F5AA95B909E67487408407956BDE32AC977D035FBBA575C11AA034B23402066C16FD6126893F3661B099A49366406ACA952B88BADF5F1E9BE6CE4968141035A60BE503273EA65456B24039054410000000000000000A76541BE0C00000090E8FEBD671DD41BEE94EC3BA5831CB608A312C2F203BA84AC03000300303064000000000000006400000000000000002F00FA0DEDD9086400000000000000443F6D806C05543A6400000000000000")
        let hash = Transaction.createTransactionHash(signature: args.signature, signer: args.signer, message: args.message)
        XCTAssertEqual("1105F408BA2C2B2769717197954F85DFC6C502C578CC9D0B8DD628BD88330EE7", hash.hexString.uppercased())
    }

    func testGenerateHashFromAggregateTransactionPayload() {
        let args = separatePayload("E9000000A37C8B0456474FB5E3E910E84B5929293C114E0AF97FEF0D940D3A2A2C337BAFA0C59538E5988229B65A3065B4E9BD57B1AFAEC64DFBE2211B8AF6E742801E08C2F93346E27CE6AD1A9F8F5E3066F8326593A406BDF357ACB041E2F9AB402EFE0390414100000000000000008EEAC2C80C0000006D0000006D000000C2F93346E27CE6AD1A9F8F5E3066F8326593A406BDF357ACB041E2F9AB402EFE0390554101020200B0F93CBEE49EEB9953C6F3985B15A4F238E205584D8F924C621CBE4D7AC6EC2400B1B5581FC81A6970DEE418D2C2978F2724228B7B36C5C6DF71B0162BB04778B4")
        let hash = Transaction.createTransactionHash(signature: args.signature, signer: args.signer, message: args.message)
        XCTAssertEqual("AED6DD7B9575FD29D604A4D3CE57A6F9BE7B88CC3AE0B6C5F3CB26C261592907", hash.hexString.uppercased());
    }

    func testShouldReturnTransactionIsUnannouncedWhenThereIsNoTransactionInfo() {
        let fakeTransaction = FakeTransferTransaction(networkType: .mijinTest, version: 1, deadline: FakeDeadline(), fee: 0)
        XCTAssertTrue(fakeTransaction.isUnannounced)
    }

    func testShouldReturnTransactionIsUnconfirmedWhenHeightIs0() {
        let fakeTransaction = FakeTransferTransaction(networkType: .mijinTest, version: 1, deadline: FakeDeadline(), fee: 0,
                signature: "signature",
                signer: signer,
                transactionInfo: TransactionInfo.create(height: 0, index: 1, id: "id_hash", hash: [], merkleComponentHash: [])
        )
        XCTAssertTrue(fakeTransaction.isUnconfirmed)
    }

    func testShouldReturnTransactionIsNotUnconfirmedWhenHeightIsNot0() {
        let fakeTransaction = FakeTransferTransaction(networkType: .mijinTest, version: 1, deadline: FakeDeadline(), fee: 0,
                signature: "signature",
                signer: signer,
                transactionInfo: TransactionInfo.create(height: 100, index: 1, id: "id_hash", hash: [], merkleComponentHash: [])
        )
        XCTAssertFalse(fakeTransaction.isUnconfirmed)
    }

    func testShouldReturnTransactionIsConfirmedWhenHeightIsNot0() {
        let fakeTransaction = FakeTransferTransaction(networkType: .mijinTest, version: 1, deadline: FakeDeadline(), fee: 0,
                signature: "signature",
                signer: signer,
                transactionInfo: TransactionInfo.create(height: 100, index: 1, id: "id_hash", hash: [], merkleComponentHash: [])
        )
        XCTAssertTrue(fakeTransaction.isConfirmed)
    }

    func testShouldReturnTransactionIsAggregateBondedWhenHeightIs0AndHashAndMerkleHashAreDifferent() {
        let fakeTransaction = FakeTransferTransaction(networkType: .mijinTest, version: 1, deadline: FakeDeadline(), fee: 0,
                signature: "signature",
                signer: signer,
                transactionInfo: TransactionInfo.create(height: 0, index: 1, id: "id_hash", hash: [0x00], merkleComponentHash: [0x01])
        )

        XCTAssertTrue(fakeTransaction.hasMissingSignatures)
    }
}