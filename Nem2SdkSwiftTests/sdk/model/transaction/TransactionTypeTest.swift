// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class TransactionTypeTest: XCTestCase {
    func testAggregateCompleteType() {
        let transactionType = TransactionType.aggregateComplete
        XCTAssertEqual(0x4141, transactionType.rawValue)
        XCTAssertEqual(16705, transactionType.rawValue)
        XCTAssertEqual(TransactionType.aggregateComplete, TransactionType(rawValue: 16705))
    }

    func testAggregateBondedType() {
        let transactionType = TransactionType.aggregateBonded
        XCTAssertEqual(0x4241, transactionType.rawValue)
        XCTAssertEqual(16961, transactionType.rawValue)
        XCTAssertEqual(TransactionType.aggregateBonded, TransactionType(rawValue: 16961))
    }

    func testMosaicCreationType() {
        let transactionType = TransactionType.mosaicDefinition
        XCTAssertEqual(0x414d, transactionType.rawValue)
        XCTAssertEqual(16717, transactionType.rawValue)
        XCTAssertEqual(TransactionType.mosaicDefinition, TransactionType(rawValue: 16717))
    }

    func testMosaicSupplyChangeType() {
        let transactionType = TransactionType.mosaicSupplyChange
        XCTAssertEqual(0x424d, transactionType.rawValue)
        XCTAssertEqual(16973, transactionType.rawValue)
        XCTAssertEqual(TransactionType.mosaicSupplyChange, TransactionType(rawValue: 16973))
    }

    func testMultisigModificationType() {
        let transactionType = TransactionType.modifyMultisigAccount
        XCTAssertEqual(0x4155, transactionType.rawValue)
        XCTAssertEqual(16725, transactionType.rawValue)
        XCTAssertEqual(TransactionType.modifyMultisigAccount, TransactionType(rawValue: 16725))
    }

    func testNamespaceCreationType() {
        let transactionType = TransactionType.registerNamespace
        XCTAssertEqual(0x414e, transactionType.rawValue)
        XCTAssertEqual(16718, transactionType.rawValue)
        XCTAssertEqual(TransactionType.registerNamespace, TransactionType(rawValue: 16718))
    }

    func testTransferType() {
        let transactionType = TransactionType.transfer
        XCTAssertEqual(0x4154, transactionType.rawValue)
        XCTAssertEqual(16724, transactionType.rawValue)
        XCTAssertEqual(TransactionType.transfer, TransactionType(rawValue: 16724))
    }

    func testLockFundsType() {
        let transactionType = TransactionType.lock
        XCTAssertEqual(0x414C, transactionType.rawValue)
        XCTAssertEqual(16716, transactionType.rawValue)
        XCTAssertEqual(TransactionType.lock, TransactionType(rawValue: 16716))
    }

    func testSecretLockType() {
        let transactionType = TransactionType.secretLock
        XCTAssertEqual(0x424C, transactionType.rawValue)
        XCTAssertEqual(16972, transactionType.rawValue)
        XCTAssertEqual(TransactionType.secretLock, TransactionType(rawValue: 16972))
    }

    func testSecretProofType() {
        let transactionType = TransactionType.secretProof
        XCTAssertEqual(0x434C, transactionType.rawValue)
        XCTAssertEqual(17228, transactionType.rawValue)
        XCTAssertEqual(TransactionType.secretProof, TransactionType(rawValue: 17228))
    }
}