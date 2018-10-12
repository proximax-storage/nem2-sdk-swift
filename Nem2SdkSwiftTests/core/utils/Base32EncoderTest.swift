// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class Base32EncoderTest: XCTestCase {
    private let ENCODED_SIGMA_BYTES: [UInt8] = [0x53, 0x69, 0x67, 0x6D, 0x61]

    private let ENCODED_CURRENCY_SYMBOLS_BYTES: [UInt8] = [0x24, 0xC2, 0xA2, 0xE2, 0x82, 0xAC]


    func testStringCanBeConvertedToByteArray() {
        XCTAssertEqual(try! Base32Encoder.bytes(from: "KNUWO3LB"), ENCODED_SIGMA_BYTES)
        XCTAssertEqual(try! Base32Encoder.bytes(from: "ETBKFYUCVQ======"), ENCODED_CURRENCY_SYMBOLS_BYTES)
    }


    func testByteArrayCanBeConvertedToString() {
        XCTAssertEqual(Base32Encoder.base32String(from: ENCODED_SIGMA_BYTES), "KNUWO3LB")
        XCTAssertEqual(Base32Encoder.base32String(from: ENCODED_CURRENCY_SYMBOLS_BYTES), "ETBKFYUCVQ======")
    }


    func testMalformedStringCannotBeDecoded() {
        XCTAssertThrowsError(try Base32Encoder.bytes(from: "BAD STRING)(*&^%$#@!")) { error in
            if  case Nem2SdkSwiftError.illegalArgument(_) = error {
            } else {
                XCTFail("Unexpected Error.")
            }
        }

    }

    func testStringCanContainPaddingAndWhitespace() {
        XCTAssertEqual(try! Base32Encoder.bytes(from: "  ETBKFYUCVQ======  "), ENCODED_CURRENCY_SYMBOLS_BYTES)
    }

}
