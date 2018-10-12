// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class MosaicTest: XCTestCase {

    func testCreateANewMosaicViaConstructor() {
        let mosaicId = MosaicId(id: 0xD525AD41D95FCF29)
        let mosaic = Mosaic(id: mosaicId, amount: 24)
        XCTAssertEqual(mosaic.id, mosaicId)
        XCTAssertEqual(mosaic.amount, 24)
    }
}