// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class PrivateKeyTest: XCTestCase {
    func padBytes(_ count: Int) -> [UInt8] {
        return [UInt8](repeating: 0, count: count)
    }

    func padHex(_ count: Int) -> String {
        return [String](repeating: "0", count: count).joined(separator: "")
    }

    func testCanCreateFromBytes() {
        // Arrange:
        let key = try! PrivateKey(bytes: [0x02, 0xAB, 0x45, 0x90] +  padBytes(28))

        // Assert:
        XCTAssertEqual(key.bytes,  [0x02, 0xAB, 0x45, 0x90] +  padBytes(28))
    }


    func testCanCreateFromHexString() {
        // Arrange:
        let key = try! PrivateKey(hexString: "227F" + padHex(60))

        // Assert:
        XCTAssertEqual(key.bytes, [0x22, 0x7f]  + padBytes(30))
    }


    func testCanCreateFromOddLengthHexString() {
        // Arrange:
        let key = try! PrivateKey(hexString: "ABC" + padHex(60))

        // Assert:
        XCTAssertEqual(key.bytes, [0x0A, 0xBC]  + padBytes(30))
    }

    func testCanCreateFromNegativeHexString() {
        // Arrange:
        let key = try! PrivateKey(hexString: "8000" + padHex(60))

        // Assert:
        XCTAssertEqual(key.bytes, [0x80, 0x00] + padBytes(30))
    }


    func testCannotCreateAroundMalformedHexString() {
        // Act:
        XCTAssertThrowsError(try PrivateKey(hexString: "022G75" + padHex(58))) { error in
            if  case Nem2SdkSwiftError.illegalArgument(_) = error {
            } else {
                XCTFail("Unexpected Error.")
            }
        }
    }

    func testCannotCreateAroundInvalidHexLength() {
        // Act:
        XCTAssertThrowsError(try PrivateKey(hexString: "01234567")) { error in
            if  case Nem2SdkSwiftError.illegalArgument(_) = error {
            } else {
                XCTFail("Unexpected Error.")
            }
        }
    }


    func testEqualsOnlyReturnsTrueForEquivalentObjects() {
        // Arrange:
        let key = try! PrivateKey(bytes: [0x02, 0xAB, 0x45, 0x90] + padBytes(28))

        // Assert:
        XCTAssertEqual(try! PrivateKey(bytes: [0x02, 0xAB, 0x45, 0x90] + padBytes(28)), key)
        XCTAssertEqual(try! PrivateKey(hexString: "02AB4590" + padHex(56)), key)
        XCTAssertNotEqual(try! PrivateKey(hexString: "02AB4591" + padHex(56)), key)
        XCTAssertNotEqual(try! PrivateKey(bytes: [0x02, 0xAB, 0x45, 0x91] + padBytes(28)), key)
    }

    func testDescriptionReturnsHexRepresentation() {
        // Assert:
        XCTAssertEqual((try! PrivateKey(hexString: "2275" + padHex(60))).description, "2275" + padHex(60))
        XCTAssertNotEqual((try! PrivateKey(hexString: "2275" + padHex(60))).description, "08e3" + padHex(60))
    }
}
