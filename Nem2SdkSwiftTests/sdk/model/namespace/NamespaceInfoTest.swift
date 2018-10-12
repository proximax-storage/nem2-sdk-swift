// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class NamespaceInfoTest: XCTestCase {

    func testCreateANamespaceInfoViaConstructor() {
        let namespaceId = NamespaceId(id: TestUtils.nemId)
        let namespaceInfo = NamespaceInfo(
                isActive: true,
                index: 0,
                metaId: "5A3CD9B09CD1E8000159249B",
                type: .rootNamespace,
                depth: 1,
                levels: [namespaceId],
                parentId: NamespaceId(id: 0),
                owner: try! PublicAccount(publicKeyHexString: "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF", networkType: .mijinTest),
                startHeight: 1,
                endHeight: 100)

        XCTAssertEqual(namespaceInfo.isActive, true)
        XCTAssertEqual(namespaceInfo.index, 0)
        XCTAssertEqual("5A3CD9B09CD1E8000159249B", namespaceInfo.metaId)
        XCTAssertEqual(namespaceInfo.type, .rootNamespace)
        XCTAssertEqual(namespaceInfo.depth, 1)
        XCTAssertEqual(namespaceInfo.levels[0], namespaceId)

        XCTAssertEqual(try! PublicAccount(publicKeyHexString: "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF", networkType: .mijinTest), namespaceInfo.owner)
        XCTAssertEqual(1, namespaceInfo.startHeight)
        XCTAssertEqual(100, namespaceInfo.endHeight)
    }

    func testShouldReturnRootNamespaceId() {
        let namespaceInfo = createRootNamespaceInfo()
        XCTAssertEqual(TestUtils.nemId, namespaceInfo.id.id)
    }

    func testShouldReturnSubNamespaceId() {
        let namespaceInfo = createSubNamespaceInfo()
        XCTAssertEqual(TestUtils.subNamespaceId, namespaceInfo.id.id)
    }

    func testShouldReturnRootTrueWhenNamespaceInfoIsFromRootNamespace() {
        let namespaceInfo = createRootNamespaceInfo()
        XCTAssertTrue(namespaceInfo.isRoot)
    }

    func testShouldReturnRootFalseWhenNamespaceInfoIsFromSubNamespace() {
        let namespaceInfo = createSubNamespaceInfo()
        XCTAssertFalse(namespaceInfo.isRoot)
    }

    func testShouldReturnSubNamespaceFalseWhenNamespaceInfoIsFromRootNamespace() {
        let namespaceInfo = createRootNamespaceInfo()
        XCTAssertFalse(namespaceInfo.isSubNamespace)
    }

    func testShouldReturnSubNamespaceTrueWhenNamespaceInfoIsFromSubNamespace() {
        let namespaceInfo = createSubNamespaceInfo()
        XCTAssertTrue(namespaceInfo.isSubNamespace)
    }

    func testShouldReturnParentNamespaceIdWhenNamespaceInfoIsFromSubNamespace() {
        let namespaceInfo = createSubNamespaceInfo()
        XCTAssertEqual(TestUtils.xemId, namespaceInfo.parentId?.id)
    }

    func testShouldParentNamespaceIdThrowErrorWhenNamespaceInfoIsFromRootNamespace() {
        let namespaceInfo = createRootNamespaceInfo();
        XCTAssertNil(namespaceInfo.parentId)
    }


    func createRootNamespaceInfo() -> NamespaceInfo {
        return NamespaceInfo(
                isActive: true,
                index: 0,
                metaId: "5A3CD9B09CD1E8000159249B",
                type: .rootNamespace,
                depth: 1,
                levels: [NamespaceId(id: TestUtils.nemId)],
                parentId: nil,
                owner: try! PublicAccount(publicKeyHexString: "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF", networkType: .mijinTest),
                startHeight: 1,
                endHeight: 100)
    }

    func createSubNamespaceInfo() -> NamespaceInfo {
        return NamespaceInfo(
                isActive: true,
                index: 0,
                metaId: "5A3CD9B09CD1E8000159249B",
                type: .subNamespace,
                depth: 1,
                levels: [NamespaceId(id: TestUtils.xemId), NamespaceId(id: TestUtils.subNamespaceId)],
                parentId: NamespaceId(id: TestUtils.xemId),
                owner: try! PublicAccount(publicKeyHexString: "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF", networkType: .mijinTest),
                startHeight: 1,
                endHeight: 100)
    }
}
