// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import XCTest
import RxBlocking
@testable import Nem2SdkSwift

class BlockchainHttpTest: XCTestCase {
    private var blockchainHttp: BlockchainHttp!

    override func setUp() {
        super.setUp()
        blockchainHttp = BlockchainHttp(url: TestSettings.url)
    }


    func testGetBlockByHeight() {
        let blockInfo = try! blockchainHttp.getBlock(height: 1).toBlocking().first()!

        XCTAssertEqual(1, blockInfo.height)
        XCTAssertEqual(0, blockInfo.timestamp)
    }


    func testGetBlockTransactions() {
        let transactions: [Transaction] = try! blockchainHttp.getBlockTransactions(height: 1).toBlocking().first()!

        XCTAssertEqual(10, transactions.count)

        let nextTransactions: [Transaction] = try! blockchainHttp.getBlockTransactions(height: 1, pageSize: 15, id: transactions[0].transactionInfo!.id!).toBlocking().first()!

        XCTAssertEqual(15, nextTransactions.count)
        XCTAssertEqual(transactions[1].transactionInfo?.hash!, nextTransactions[0].transactionInfo?.hash!)
    }

    func testGetBlockchainHeight() {
        let blockchainHeight = try! blockchainHttp.getBlockchainHeight().toBlocking().first()!

        XCTAssertGreaterThan(blockchainHeight, 0)
    }

    func testGetBlockchainScore() {
        let blockchainScore: BlockchainScore = try! blockchainHttp.getBlockchainScore().toBlocking().first()!

        XCTAssertTrue(blockchainScore.scoreLow != 0 || blockchainScore.scoreHigh != 0)
    }

    func testGetBlockchainStorage() {
        let blockchainStorage: BlockchainStorageInfo = try! blockchainHttp.getBlockchainStorage().toBlocking().first()!

        XCTAssertGreaterThan(blockchainStorage.numAccounts, 0)
        XCTAssertGreaterThan(blockchainStorage.numTransactions, 0)
        XCTAssertGreaterThan(blockchainStorage.numBlocks, 0)
    }

    func testThrowExceptionWhenBlockDoesNotExists() {
        TestUtils.expectResponseError(code: 404) {
            _ = try blockchainHttp.getBlock(height: 10000000000).toBlocking().first()
        }
    }
}
