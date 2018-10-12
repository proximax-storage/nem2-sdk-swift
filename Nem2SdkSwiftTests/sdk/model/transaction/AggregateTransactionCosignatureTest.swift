// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


public class AggregateTransactionCosignatureTest: XCTestCase {

    func testCreateAnAggregateCosignatureViaConstructor() {
        let signature = Array("signature".utf8)

        let aggregateTransactionCosignature = AggregateTransactionCosignature(signature: signature, signer: try! PublicAccount(publicKeyHexString: "9A49366406ACA952B88BADF5F1E9BE6CE4968141035A60BE503273EA65456B24", networkType: .mijinTest))

        XCTAssertEqual(signature, aggregateTransactionCosignature.signature)
        XCTAssertEqual(try! PublicAccount(publicKeyHexString: "9A49366406ACA952B88BADF5F1E9BE6CE4968141035A60BE503273EA65456B24", networkType: .mijinTest), aggregateTransactionCosignature.signer)
    }
}
