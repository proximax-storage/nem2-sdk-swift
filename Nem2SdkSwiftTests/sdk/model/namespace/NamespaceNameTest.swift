// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class NamespaceNameTest: XCTestCase {

    func testCreateANamespaceName() {
        let namespaceId = NamespaceId(id: TestUtils.nemId)
        let namespaceName = NamespaceName(namespaceId: namespaceId, name: "nem", parentId: nil)

        XCTAssertEqual(namespaceId, namespaceName.namespaceId)
        XCTAssertEqual("nem", namespaceName.name)
        XCTAssertNil(namespaceName.parentId)
    }

    func testCreateANamespaceNameWithParentId() {
        let namespaceId = NamespaceId(id: TestUtils.nemId)
        let parentId = NamespaceId(id: TestUtils.xemId)
        let namespaceName = NamespaceName(namespaceId: namespaceId, name: "nem", parentId: parentId)

        XCTAssertEqual(namespaceId, namespaceName.namespaceId)
        XCTAssertEqual("nem", namespaceName.name)
        XCTAssertEqual(parentId, namespaceName.parentId)
    }
}

