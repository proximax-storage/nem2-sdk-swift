// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class HashesTest: XCTestCase {


    private let SHA3_256_TESTER = HashTester(hashFunction: Hashes.sha3_256, expectedHashLength: 32)
    private let SHA3_512_TESTER = HashTester(hashFunction: Hashes.sha3_512, expectedHashLength: 64)
    private let RIPEMD160_TESTER = HashTester(hashFunction: Hashes.ripemd160, expectedHashLength: 20)


    private class HashTester {
        private let hashFunction: ([UInt8]) -> [UInt8]
        private let expectedHashLength: Int

        init(hashFunction: @escaping ([UInt8]) -> [UInt8], expectedHashLength: Int) {
            self.hashFunction = hashFunction
            self.expectedHashLength = expectedHashLength
        }

        func assertHashHasExpectedLength() {
            // Arrange:
            let input = TestUtils.generateRandomBytes()

            // Act:
            let hash = self.hashFunction(input)

            // Assert:
            XCTAssertEqual(hash.count, self.expectedHashLength)
        }

        func assertHashIsSameForSameInputs() {
            // Arrange:
            let input = TestUtils.generateRandomBytes()

            // Act:
            let hash1 = self.hashFunction(input)
            let hash2 = self.hashFunction(input)

            // Assert:
            XCTAssertEqual(hash2, hash1)
        }


        func assertHashIsDifferentForDifferentInputs() {
            // Arrange:
            let input1 = TestUtils.generateRandomBytes()
            let input2 = TestUtils.generateRandomBytes()

            // Act:
            let hash1 = self.hashFunction(input1)
            let hash2 = self.hashFunction(input2)

            // Assert:
            XCTAssertNotEqual(hash2, hash1)
        }
    }


    static func assertHashesAreDifferent(
            _ hashFunction1: ([UInt8]) -> [UInt8],
            _ hashFunction2: ([UInt8]) -> [UInt8]) {
        // Arrange:
        let input = TestUtils.generateRandomBytes()

        // Act:
        let hash1 = hashFunction1(input)
        let hash2 = hashFunction2(input)

        // Assert:
        XCTAssertNotEqual(hash2, hash1)
    }


    func testSha3_256HashHasExpectedByteLength() {
        // Assert:
        SHA3_256_TESTER.assertHashHasExpectedLength()
    }


    func testSha3_256GeneratesSameHashForSameInputs() {
        // Assert:
        SHA3_256_TESTER.assertHashIsSameForSameInputs()
    }


    func testSha3_256GeneratesDifferentHashForDifferentInputs() {
        // Assert:
        SHA3_256_TESTER.assertHashIsDifferentForDifferentInputs()
    }

    func testSha3_512HashHasExpectedByteLength() {
        // Assert:
        SHA3_512_TESTER.assertHashHasExpectedLength()
    }


    func testSha3_512GeneratesSameHashForSameInputs() {
        // Assert:
        SHA3_512_TESTER.assertHashIsSameForSameInputs()
    }


    func testSha3_512GeneratesDifferentHashForDifferentInputs() {
        // Assert:
        SHA3_512_TESTER.assertHashIsDifferentForDifferentInputs()
    }

    func testRipemd160HashHasExpectedByteLength() {
        // Assert:
        RIPEMD160_TESTER.assertHashHasExpectedLength()
    }


    func testRipemd160GeneratesSameHashForSameInputs() {
        // Assert:
        RIPEMD160_TESTER.assertHashIsSameForSameInputs()
    }


    func testRipemd160GeneratesDifferentHashForDifferentInputs() {
        // Assert:
        RIPEMD160_TESTER.assertHashIsDifferentForDifferentInputs()
    }

    func testSha3_256AndRipemd160GenerateDifferentHashForSameInputs() {
        // Assert:
        HashesTest.assertHashesAreDifferent(Hashes.sha3_256, Hashes.ripemd160)
    }

    func testSha3_256AndSha3_512GenerateDifferentHashForSameInputs() {
        // Assert:
        HashesTest.assertHashesAreDifferent(Hashes.sha3_256, Hashes.sha3_512)
    }


    func testSha3_512AndRipemd160GenerateDifferentHashForSameInputs() {
        // Assert:
        HashesTest.assertHashesAreDifferent(Hashes.sha3_512, Hashes.ripemd160)
    }
}
