// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

public class HexEncoderTest: XCTestCase {

    private static func assertGetBytesConversion(_ input: String, _ expectedOutput: [UInt8]) {
        // Act:
        let output = input.toBytesFromHexString()!

        // Assert:
        XCTAssertEqual(output, expectedOutput)
    }


    private static func assertGetStringConversion(_ input: [UInt8], _ expectedOutput: String) {
        // Act:
        let output = input.hexString

        // Assert:
        XCTAssertEqual(output, expectedOutput)
    }

    func testGetBytesCanConvertValidStringToByteArray() {
        // Assert:
        HexEncoderTest.assertGetBytesConversion(
                "4e454d465457",
                [0x4e, 0x45, 0x4d, 0x46, 0x54, 0x57])
    }

    func testGetBytesCanConvertValidStringWithOddLengthToByteArray() {
        // Assert:
        HexEncoderTest.assertGetBytesConversion(
                "e454d465457",
                [0x0e, 0x45, 0x4d, 0x46, 0x54, 0x57])
    }

    func testGetBytesCanConvertValidStringWithLeadingZerosToByteArray() {
        // Assert:
        HexEncoderTest.assertGetBytesConversion(
                "00000d465457",
                [0x00, 0x00, 0x0d, 0x46, 0x54, 0x57])
    }


    func testGetStringCanConvertBytesToHexString() {
        // Assert:
        HexEncoderTest.assertGetStringConversion(
                [0x4e, 0x45, 0x4d, 0x46, 0x54, 0x57],
                "4e454d465457")
    }


    func testGetStringCanConvertBytesWithLeadingZerosToHexString() {
        // Assert:
        HexEncoderTest.assertGetStringConversion(
                [0x00, 0x00, 0x0d, 0x46, 0x54, 0x57],
                "00000d465457")
    }
}
