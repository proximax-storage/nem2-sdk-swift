// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class MosaicPropertiesTest: XCTestCase {

    func testShouldCreateMosaicPropertiesViaConstructor() {
        let mosaicProperties = MosaicProperties(isSupplyMutable: true, isTransferable: true, isLevyMutable: true, divisibility: 1, duration: 1000)

        XCTAssertTrue(mosaicProperties.isSupplyMutable)
        XCTAssertTrue(mosaicProperties.isTransferable)
        XCTAssertTrue(mosaicProperties.isLevyMutable)
        XCTAssertEqual(1, mosaicProperties.divisibility)
        XCTAssertEqual(1000, mosaicProperties.duration)
    }
}
