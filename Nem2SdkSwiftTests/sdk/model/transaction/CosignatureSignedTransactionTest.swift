// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


public class CosignatureSignedTransactionTest: XCTestCase {

    func testCreateACosignatureSignedTransactionViaConstructor() {
        let parentHash = Array("parentHash".utf8)
        let signature = Array("signature".utf8)
        let signer = Array("signer".utf8)

        let cosignatureSignedTransaction = CosignatureSignedTransaction(parentHash: parentHash, signature: signature, signer: signer)

        XCTAssertEqual(parentHash, cosignatureSignedTransaction.parentHash)
        XCTAssertEqual(signature, cosignatureSignedTransaction.signature)
        XCTAssertEqual(signer, cosignatureSignedTransaction.signer)
    }
}
