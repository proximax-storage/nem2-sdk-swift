// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


class KeyPairTest: XCTestCase {

    func testCorCanCreateNewKeyPair() {
        // Act:
        let kp = KeyPair()

        // Assert:
        XCTAssertTrue(kp.privateKey.bytes.count > 0)
        XCTAssertTrue(kp.publicKey.bytes.count > 0)
    }


    func testCtorCanCreateKeyPairAroundPrivateKey() {
        // Arrange:
        let kp1 = KeyPair()

        // Act:
        let kp2 = KeyPair(privateKey: kp1.privateKey)

        // Assert:
        XCTAssertEqual(kp2.privateKey, kp1.privateKey)
        XCTAssertEqual(kp2.publicKey, kp1.publicKey)
    }


    func testCtorCreatesDifferentInstancesWithDifferentKeys() {
        // Act:
        let kp1 = KeyPair()
        let kp2 = KeyPair()

        // Assert:
        XCTAssertNotEqual(kp2.privateKey, kp1.privateKey)
        XCTAssertNotEqual(kp2.publicKey, kp1.publicKey)
    }
}
