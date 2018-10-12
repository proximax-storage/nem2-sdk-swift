// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


class PublicAccountTest: XCTestCase {
    private let publicKey = try! PublicKey(hexString: "b4f12e7c9f6946091e2cb8b6d3a12b50d17ccbbf646386ea27ce2946a7423dcf")
    private let address = "SARNASAS2BIAB6LMFA3FPMGBPGIJGK6IJETM3ZSP"

    func testShouldCreatePublicAccountViaConstructor() {
        let publicAccount = PublicAccount(publicKey: publicKey, networkType: .mijinTest)
        XCTAssertEqual(publicKey.description, publicAccount.publicKey.description)
        XCTAssertEqual(address, publicAccount.address.plain)
    }

    func testEqualityIsBasedOnPublicKeyAndNetwork() {
        let publicAccount = PublicAccount(publicKey: publicKey, networkType: .mijinTest)
        let publicAccount2 = PublicAccount(publicKey: publicKey, networkType: .mijinTest)
        XCTAssertEqual(publicAccount, publicAccount2)
    }

    func testEqualityReturnsFalseIfNetworkIsDifferent() {
        let publicAccount = PublicAccount(publicKey: publicKey, networkType: .mijinTest)
        let publicAccount2 = PublicAccount(publicKey: publicKey, networkType: .mainNet)
        XCTAssertNotEqual(publicAccount, publicAccount2)
    }
}