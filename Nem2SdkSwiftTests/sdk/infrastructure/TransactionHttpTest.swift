// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import XCTest
import RxBlocking
@testable import Nem2SdkSwift

class TransactionHttpTest: XCTestCase {
    private var transactionHttp: TransactionHttp!

    override func setUp() {
        super.setUp()
        transactionHttp = TransactionHttp(url: TestSettings.url)
    }

    func testGetTransaction() {
        let transaction: Transaction  = try! transactionHttp.getTransaction(hash: TestSettings.transactionHash).toBlocking().first()!

        XCTAssertEqual(TransactionType.transfer, transaction.type)
        XCTAssertEqual(TestSettings.transactionHash, transaction.transactionInfo?.hash)
    }

    func testGetTransactions()  {
        let transactions: [Transaction]  = try! transactionHttp.getTransactions(hashes: [TestSettings.transactionHash]).toBlocking().first()!

        XCTAssertEqual(1, transactions.count)
        XCTAssertEqual(TransactionType.transfer, transactions[0].type)
        XCTAssertEqual(TestSettings.transactionHash, transactions[0].transactionInfo?.hash)
    }

    func testGetTransactionStatus() {
        let transactionStatus: TransactionStatus  = try! transactionHttp.getTransactionStatus(hash: TestSettings.transactionHash).toBlocking().first()!

        XCTAssertEqual(TestSettings.transactionHash, transactionStatus.hash)
    }


    func testGetTransactionsStatuses() {
        let transactionStatuses: [TransactionStatus]  = try! transactionHttp.getTransactionStatuses(hashes: [TestSettings.transactionHash]).toBlocking().first()!

        XCTAssertEqual(TestSettings.transactionHash, transactionStatuses[0].hash)
    }

    func testThrowExceptionWhenTransactionStatusOfATransactionDoesNotExists() {
        TestUtils.expectResponseError(code: 404) {
            _ = try transactionHttp.getTransactionStatus(hash: [UInt8](repeating: 0, count: 32)).toBlocking().first()
        }
    }

    func testThrowExceptionWhenTransactionDoesNotExists() {
        TestUtils.expectResponseError(code: 404) {
            _ = try transactionHttp.getTransaction(hash: [UInt8](repeating: 0, count: 32)).toBlocking().first()
        }
    }
}