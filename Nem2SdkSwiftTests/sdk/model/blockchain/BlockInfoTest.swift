// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


class BlockInfoTest: XCTestCase {

    func testCreateANewBlockInfo() {
        let blockInfo = BlockInfo(
                hash: "24E92B511B54EDB48A4850F9B42485FDD1A30589D92C775632DDDD71D7D1D691",
                generationHash: "57F7DA205008026C776CB6AED843393F04CD458E0AA2D9F1D5F31A402072B2D6",
                totalFee: 0,
                numTransactions: 25,
                signature: "37351C8244AC166BE6664E3FA954E99A3239AC46E51E2B32CEA1C72DD0851100A7731868E932E1A9BEF8A27D48E1" + "FFEE401E933EB801824373E7537E51733E0F",
                signer: try! PublicAccount(publicKeyHexString: "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF", networkType: .mijinTest),
                networkType: .mijinTest,
                version: 3,
                type: 32768,
                height: 1,
                timestamp: 0,
                difficulty: 0x23283276447232,
                previousBlockHash: "702090BA31CEF9E90C62BBDECC0CCCC0F88192B6625839382850357F70DD68A0",
                blockTransactionHash: "0000000000000000000000000000000000000000000000000000000000000000")

        XCTAssertEqual("24E92B511B54EDB48A4850F9B42485FDD1A30589D92C775632DDDD71D7D1D691", blockInfo.hash)
        XCTAssertEqual("57F7DA205008026C776CB6AED843393F04CD458E0AA2D9F1D5F31A402072B2D6", blockInfo.generationHash)
        XCTAssertEqual(0, blockInfo.totalFee)
        XCTAssertEqual(25, blockInfo.numTransactions)
        XCTAssertEqual("37351C8244AC166BE6664E3FA954E99A3239AC46E51E2B32CEA1C72DD0851100A7731868E932E1A9BEF8A27D48E1" +
                "FFEE401E933EB801824373E7537E51733E0F", blockInfo.signature)
        XCTAssertEqual(try! PublicAccount(publicKeyHexString: "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF", networkType: .mijinTest),
                blockInfo.signer)

        XCTAssertEqual(NetworkType.mijinTest, blockInfo.networkType)
        XCTAssertEqual(3, blockInfo.version)
        XCTAssertEqual(32768, blockInfo.type)
        XCTAssertEqual(1, blockInfo.height)
        XCTAssertEqual(0, blockInfo.timestamp)
        XCTAssertEqual(0x23283276447232, blockInfo.difficulty)
        XCTAssertEqual("702090BA31CEF9E90C62BBDECC0CCCC0F88192B6625839382850357F70DD68A0", blockInfo.previousBlockHash)
        XCTAssertEqual("0000000000000000000000000000000000000000000000000000000000000000", blockInfo.blockTransactionHash)
    }
}

