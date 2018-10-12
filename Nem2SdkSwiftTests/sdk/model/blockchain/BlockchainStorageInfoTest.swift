// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class BlockchainStorageInfoTest: XCTestCase {

    func testCreateANewBlockchainStorageInfo() {
        let blockchainStorageInfo = BlockchainStorageInfo(numAccounts: 1, numBlocks: 2, numTransactions: 3)

        XCTAssertEqual(blockchainStorageInfo.numAccounts, 1)
        XCTAssertEqual(blockchainStorageInfo.numBlocks, 2)
        XCTAssertEqual(blockchainStorageInfo.numTransactions, 3)
    }
}