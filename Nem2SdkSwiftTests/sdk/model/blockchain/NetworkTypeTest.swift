// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

public class NetworkTypeTest: XCTestCase {

    func testMAIN_NETIs0x68() {
        XCTAssertEqual(0x68, NetworkType.mainNet.rawValue)
        XCTAssertEqual(104, NetworkType.mainNet.rawValue)
    }

    func testTEST_NETIs0x98() {
        XCTAssertEqual(0x98, NetworkType.testNet.rawValue)
        XCTAssertEqual(152, NetworkType.testNet.rawValue)
    }

    func testMIJINIs0x60() {
        XCTAssertEqual(0x60, NetworkType.mijin.rawValue)
        XCTAssertEqual(96, NetworkType.mijin.rawValue)
    }

    func testMIJIN_TESTIs0x90() {
        XCTAssertEqual(0x90, NetworkType.mijinTest.rawValue)
        XCTAssertEqual(144, NetworkType.mijinTest.rawValue)
    }
}
