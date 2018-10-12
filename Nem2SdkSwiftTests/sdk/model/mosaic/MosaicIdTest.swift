// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class MosaicIdTest: XCTestCase {
    func testCreateAMosaicIdFromMosaicNameViaConstructor() {
        let mosaicId = try! MosaicId(fullName: "nem:xem")
        XCTAssertEqual(mosaicId.id, TestUtils.xemId)
        XCTAssertEqual(mosaicId.fullName, "nem:xem")
    }

    func testCreateAMosaicIdFromIdViaConstructor() {
        let mosaicId = MosaicId(id: TestUtils.nemId)
        XCTAssertEqual(mosaicId.id, TestUtils.nemId)
        XCTAssertNil(mosaicId.fullName)
    }

    func testShouldCompareMosaicIdsForEquality() {
        let mosaicId = MosaicId(id: TestUtils.nemId)
        let mosaicId2 = MosaicId(id: TestUtils.nemId)
        XCTAssertEqual(mosaicId, mosaicId2)
    }
}


class MosaicIdExceptionTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { MosaicIdExceptionTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                "nem",
                "nem.xem",
                ":nem",
                "nem.xem:",
                "",
                "nem:xem:nem"
            ]
        }
    }

    func testThrowIllegalMosaicIdentifierExceptionWhenMosaicIsNotValid() {
        let fixture = self.fixture as! String
        TestUtils.expectIllegalArgument {
            _ = try MosaicId(fullName: fixture)
        }
    }
}