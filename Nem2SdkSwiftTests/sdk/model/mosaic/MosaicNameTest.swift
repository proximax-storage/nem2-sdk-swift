// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class MosaicNameTest: XCTestCase {

    func testCreateAMosaicName() {
        let namespaceId = NamespaceId(id: TestUtils.nemId)
        let mosaicId = MosaicId(id: TestUtils.xemId)
        let mosaicName = MosaicName(mosaicId: mosaicId, name: "xem", parentId: namespaceId)

        XCTAssertEqual(mosaicId, mosaicName.mosaicId)
        XCTAssertEqual("xem", mosaicName.name)
        XCTAssertEqual(namespaceId, mosaicName.parentId)
    }
}