// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

public class SignedTransactionTest: XCTestCase {

    func testCreateASignedTransactionViaConstructor() {
        let payload = Array("payload".utf8)
        let hash = Array("hash".utf8)
        let signedTransaction = SignedTransaction(payload: payload, hash: hash, type: .transfer)

        XCTAssertEqual(payload, signedTransaction.payload)
        XCTAssertEqual(hash, signedTransaction.hash)
        XCTAssertEqual(TransactionType.transfer, signedTransaction.type)
    }
}
