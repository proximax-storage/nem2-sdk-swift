// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import Security
import XCTest
import Nem2SdkSwift

class TestUtils {
    static let nemId: UInt64 = 0x84B3552D375FFA4B
    static let xemId: UInt64 = 0xD525AD41D95FCF29
    static let subNamespaceId: UInt64 = 0xF0E71AA92827CF29

    /**
     * Generates a random public key.
     *
     * @return A random public key.
     */
    //static func generateRandomPublicKey() -> PublicKey

    static func generateRandomId() -> UInt64 {
        let randomBytes = generateRandomBytes(8)
        var id: UInt64 = 0
        for i in 0..<8 {
            id = id << 8 + UInt64(randomBytes[i])
        }
        return id
    }

    /**
     * Generates a random signature.
     *
     * @return A random signature.
     */
    //static func Signature generateRandomSignature() {
    //    final byte[] bytes = Utils.generateRandomBytes(64);
    //    return new Signature(bytes);
    //}

    /**
     * Generates a byte array containing random data.
     *
     * @param numBytes The number of bytes to generate.
     * @return A byte array containing random data.
     */
    static func generateRandomBytes(_ count: Int = 214) -> [UInt8] {
        var randomBytes = [UInt8](repeating: 0, count: count)
        let _ = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes)
        return randomBytes
    }


    /**
     * Increments a single character in the specified string.
     *
     * @param s     The string
     * @param index The index of the character to increment
     * @return The resulting string
     */
    static func increment(_ s: String, at index: Int) -> String {

        var characters: [Character] = Array(s)

        let scalars = characters[index].unicodeScalars
        characters[index] = Character(UnicodeScalar(scalars.first!.value + 1)!)

        return String(characters)
    }

    /**
     * Changes a single character in the specified base 32 string.
     *
     * @param s     A base 32 string
     * @param index The index of the character to change
     * @return The resulting base 32 string
     */
    static func modifyBase32(_ s: String, at index: Int) -> String{
        var characters: [Character] = Array(s)

        let scalars = characters[index].unicodeScalars
        var newChar = Character(UnicodeScalar(scalars.first!.value + 1)!)

        switch String(newChar) {
        case "Z", "7": newChar = "A"
        default: break
        }

        characters[index] = newChar
        return String(characters)
    }

    /**
     * Increments a single byte in the specified byte array.
     *
     * @param bytes The byte array
     * @param index The index of the byte to increment
     * @return The resulting byte array
     */
    static func increment(_ bytes: [UInt8], at index: Int) -> [UInt8] {
        var rt = bytes
        rt[index] += 1
        return rt
    }

    /**
     * Creates a string initialized with a single character.
     *
     * @param ch       The character used in the string.
     * @param numChars The number of characters in hte string.
     * @return A string of length numChars initialized to ch.
    */
    static func createString(repeating char: String, count: Int) -> String {
        return String([Character](repeating: char.first!, count: count))
    }


    static func expectIllegalArgument(message: String? = nil, _ body: () throws -> Void) {
        XCTAssertThrowsError(try body()) { error in
            if case Nem2SdkSwiftError.illegalArgument(let resultMessage) = error {
                if message != nil {
                    XCTAssertEqual(message, resultMessage)
                }
            }
            else {
                XCTFail("Unexpected Error")
            }
        }
    }
    static func expectNetworkError(_ body: () throws -> Void) {
        XCTAssertThrowsError(try body()) { error in
            if case Nem2SdkSwiftError.networkError = error {
            }
            else {
                XCTFail("Unexpected Error")
            }
        }
    }

    static func expectResponseError(code: Int? = nil, message: String? = nil, _ body: () throws -> Void) {
        XCTAssertThrowsError(try body()) { error in
            if case Nem2SdkSwiftError.responseError(let resultCode, let resultMessage) = error {
                if code != nil {
                    XCTAssertEqual(code, resultCode)
                }
                if message != nil {
                    XCTAssertEqual(message, resultMessage)
                }
            }
            else {
                XCTFail("Unexpected Error")
            }
        }
    }

    static func expectMessageEncryptionError(message: String? = nil, _ body: () throws -> Void) {
        XCTAssertThrowsError(try body()) { error in
            if case Nem2SdkSwiftError.messageEncryptionError(let resultMessage) = error {
                if message != nil {
                    XCTAssertEqual(message, resultMessage)
                }
            }
            else {
                XCTFail("Unexpected Error")
            }
        }
    }

}
