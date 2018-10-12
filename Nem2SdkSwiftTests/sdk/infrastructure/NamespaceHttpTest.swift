// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
import RxBlocking
@testable import Nem2SdkSwift

class NamespaceHttpTest: XCTestCase {
    private var namespaceHttp: NamespaceHttp!

    override func setUp() {
        super.setUp()
        namespaceHttp = NamespaceHttp(url: TestSettings.url)
    }

    func testGetNamespace() {
        let namespaceInfo = try! namespaceHttp.getNamespace(namespaceId: XEM.namespaceId).toBlocking().first()!
        XCTAssertEqual(1, namespaceInfo.startHeight)
        XCTAssertEqual(UInt64.max, namespaceInfo.endHeight)
        XCTAssertEqual(XEM.namespaceId, namespaceInfo.levels[0])
    }

    func testGetNamespacesFromAccount() {
        let namespaceInfo = try! namespaceHttp.getNamespacesFromAccount(address: try! Address(rawAddress: TestSettings.nemesisSigner)).toBlocking().first()!

        XCTAssertEqual(1, namespaceInfo.count)
        XCTAssertEqual(1, namespaceInfo[0].startHeight)
        XCTAssertEqual(UInt64.max, namespaceInfo[0].endHeight)
        XCTAssertEqual(XEM.namespaceId, namespaceInfo[0].levels[0])
    }

    func testGetNamespacesFromAccounts() {
        let namespaceInfo = try! namespaceHttp.getNamespacesFromAccounts(addresses: [try! Address(rawAddress: TestSettings.nemesisSigner)]).toBlocking().first()!

        XCTAssertEqual(1, namespaceInfo.count)
        XCTAssertEqual(1, namespaceInfo[0].startHeight)
        XCTAssertEqual(UInt64.max, namespaceInfo[0].endHeight)
        XCTAssertEqual(XEM.namespaceId, namespaceInfo[0].levels[0])
    }

    func testGetNamespaceNames() {
        let namespaceNames = try! namespaceHttp.getNamespaceNames(namespaceIds: [XEM.namespaceId]).toBlocking().first()!

        XCTAssertEqual(1, namespaceNames.count)
        XCTAssertEqual("nem", namespaceNames[0].name)
        XCTAssertEqual(XEM.namespaceId, namespaceNames[0].namespaceId)
    }

    func testThrowExceptionWhenNamespaceDoesNotExists() {
        TestUtils.expectResponseError(code: 404) {
            _ = try namespaceHttp.getNamespace(namespaceId: try! NamespaceId(fullName: "nonregisterednamespace")).toBlocking().first()!
        }
    }
}
