// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class NamespaceIdTest: XCTestCase {

    func testCreateANamespaceIdFromRootNamespaceNameViaConstructor() {
        let namespaceId = try! NamespaceId(fullName: "nem")

        XCTAssertEqual(namespaceId.id, TestUtils.nemId)
        XCTAssertEqual(namespaceId.fullName, "nem")
    }

    func testCreateANamespaceIdFromSubNamespaceNameViaConstructor() {
        let namespaceId = try! NamespaceId(fullName: "nem.xem")

        XCTAssertEqual(namespaceId.id, TestUtils.xemId)
        XCTAssertEqual(namespaceId.fullName, "nem.xem")
    }

    func testCreateANamespaceIdFromIdViaConstructor() {
        let namespaceId = NamespaceId(id: TestUtils.nemId)
        XCTAssertEqual(namespaceId.id, TestUtils.nemId)
        XCTAssertNil(namespaceId.fullName)
    }


    func testShouldCompareNamespaceIdsForEquality() {
        let namespaceId1 = NamespaceId(id: TestUtils.nemId)
        let namespaceId2 = try! NamespaceId(fullName: "nem")
        XCTAssertEqual(namespaceId1, namespaceId2)
    }
}
