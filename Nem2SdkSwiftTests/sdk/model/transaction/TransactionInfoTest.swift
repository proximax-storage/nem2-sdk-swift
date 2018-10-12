// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

public class TransactionInfoTest: XCTestCase {
    func testCreateATransactionInfoWithStaticConstructorCreateForTransactionsGetUsingListener() {
        let transactionInfo = TransactionInfo.create(
                height: 121855,
                hash: "B6C7648A3DDF71415650805E9E7801424FE03BBEE7D21F9C57B60220D3E95B2F".toBytesFromHexString()!,
                merkleComponentHash: "B6C7648A3DDF71415650805E9E7801424FE03BBEE7D21F9C57B60220D3E95B2E".toBytesFromHexString()!)

        XCTAssertEqual(121855, transactionInfo.height)
        XCTAssertNil(transactionInfo.index)
        XCTAssertNil(transactionInfo.id)
        XCTAssertEqual("B6C7648A3DDF71415650805E9E7801424FE03BBEE7D21F9C57B60220D3E95B2F".toBytesFromHexString()!, transactionInfo.hash)
        XCTAssertEqual("B6C7648A3DDF71415650805E9E7801424FE03BBEE7D21F9C57B60220D3E95B2E".toBytesFromHexString()!, transactionInfo.merkleComponentHash)
        XCTAssertNil(transactionInfo.aggregateHash)
        XCTAssertNil(transactionInfo.aggregateId)
    }

    func testCreateATransactionInfoWithStaticConstructorCreateForStandaloneTransactions() {
        let transactionInfo = TransactionInfo.create(
                height: 121855,
                index: 1,
                id: "5A3D23889CD1E800015929A9",
                hash: "B6C7648A3DDF71415650805E9E7801424FE03BBEE7D21F9C57B60220D3E95B2F".toBytesFromHexString()!,
                merkleComponentHash: "B6C7648A3DDF71415650805E9E7801424FE03BBEE7D21F9C57B60220D3E95B2E".toBytesFromHexString()!)

        XCTAssertEqual(121855, transactionInfo.height)
        XCTAssertEqual(1, transactionInfo.index)
        XCTAssertEqual("5A3D23889CD1E800015929A9", transactionInfo.id)
        XCTAssertEqual("B6C7648A3DDF71415650805E9E7801424FE03BBEE7D21F9C57B60220D3E95B2F".toBytesFromHexString()!, transactionInfo.hash)
        XCTAssertEqual("B6C7648A3DDF71415650805E9E7801424FE03BBEE7D21F9C57B60220D3E95B2E".toBytesFromHexString()!, transactionInfo.merkleComponentHash)
        XCTAssertNil(transactionInfo.aggregateHash)
        XCTAssertNil(transactionInfo.aggregateId)
    }

    func testCreateATransactionInfoWithStaticConstructorCreateForAggregateInnerTransactions() {
        let transactionInfo = TransactionInfo.createAggregate(
                height: 121855,
                index: 1,
                id: "5A3D23889CD1E800015929A9",
                aggregateHash: "3D28C804EDD07D5A728E5C5FFEC01AB07AFA5766AE6997B38526D36015A4D006".toBytesFromHexString()!,
                aggregateId: "5A0069D83F17CF0001777E55")

        XCTAssertEqual(121855, transactionInfo.height)
        XCTAssertEqual(1, transactionInfo.index)
        XCTAssertEqual("5A3D23889CD1E800015929A9", transactionInfo.id)
        XCTAssertNil(transactionInfo.hash)
        XCTAssertNil(transactionInfo.merkleComponentHash)
        XCTAssertEqual("3D28C804EDD07D5A728E5C5FFEC01AB07AFA5766AE6997B38526D36015A4D006".toBytesFromHexString(), transactionInfo.aggregateHash)
        XCTAssertEqual("5A0069D83F17CF0001777E55", transactionInfo.aggregateId)
    }
}