// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
import RxBlocking
@testable import Nem2SdkSwift


class MosaicHttpTest: XCTestCase {
    private var mosaicHttp: MosaicHttp!

    override func setUp() {
        super.setUp()
        mosaicHttp = MosaicHttp(url: TestSettings.url)
    }

    func testGetMosaic() {
        let mosaicInfo = try! mosaicHttp.getMosaic(mosaicId: XEM.mosaicId).toBlocking().first()!
        XCTAssertEqual(1, mosaicInfo.height)
        XCTAssertEqual(XEM.namespaceId, mosaicInfo.namespaceId)
        XCTAssertEqual(XEM.mosaicId, mosaicInfo.mosaicId)
    }

    func testGetMosaics() {
        let mosaicInfo = try! mosaicHttp.getMosaics(mosaicIds: [XEM.mosaicId]).toBlocking().first()!

        XCTAssertEqual(XEM.namespaceId, mosaicInfo[0].namespaceId)
        XCTAssertEqual(XEM.mosaicId, mosaicInfo[0].mosaicId)
    }

    func testGetMosaicsFromNamespace() {
        let mosaicInfo = try! mosaicHttp.getMosaicsFromNamespace(namespaceId: XEM.namespaceId).toBlocking().first()!

        XCTAssertEqual(XEM.namespaceId, mosaicInfo[0].namespaceId)
        XCTAssertEqual(XEM.mosaicId, mosaicInfo[0].mosaicId)
    }

    func testGetMosaicNames() {
        let mosaicNames = try! mosaicHttp.getMosaicNames(mosaicIds: [XEM.mosaicId]).toBlocking().first()!

        XCTAssertEqual("xem", mosaicNames[0].name)
        XCTAssertEqual(XEM.mosaicId, mosaicNames[0].mosaicId)
    }

    func testThrowExceptionWhenMosaicDoesNotExists() {
        TestUtils.expectResponseError(code: 404) {
            _ = try mosaicHttp.getMosaic(mosaicId: try! MosaicId(fullName: "nem:nem")).toBlocking().first()
        }
    }
}
