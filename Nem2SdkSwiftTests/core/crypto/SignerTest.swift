// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class SignerTest: XCTestCase {

    func testSign() {
        let message = "039054410000000000000000010000000000000090E8FEBD671DD41BEE94EC3BA5831CB608A312C2F203BA84AC01000100672B0000CE5600006400000000000000".toBytesFromHexString()!
        let expectedSignature = "773891AD01DD4CDF6E3A55C186C673E256D7DF9D471846F1943CC3529E4E02B38B9AF3F8D13784645FF5FAAFA94A321B94933C673D12DE60E4BC05ABA56F750E"

        let keyPair = KeyPair(privateKey: try! PrivateKey(hexString: "787225aaff3d2c71f4ffa32d4f19ec4922f3cd869747f267378f81f8e3fcb12d"))

        let signer = Signer(keyPair: keyPair)

        let signature = signer.sign(message: message)

        XCTAssertEqual(expectedSignature, signature.hexString.uppercased())
    }
}