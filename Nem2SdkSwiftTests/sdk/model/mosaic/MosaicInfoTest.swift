// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class MosaicInfoTest: XCTestCase {
    func createMosaicInfo(
            isActive: Bool = true,
            index: Int = 0,
            metaId: String = "5A3CD9B09CD1E8000159249B",
            namespaceId: NamespaceId = NamespaceId(id: TestUtils.nemId),
            mosaicId: MosaicId = MosaicId(id: TestUtils.xemId),
            supply: UInt64 = 100,
            height: UInt64 = 0,
            owner: PublicAccount = try! PublicAccount(publicKeyHexString: "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF", networkType: .mijinTest),
            properties: MosaicProperties = MosaicProperties(isSupplyMutable: true, isTransferable: true, isLevyMutable: true, divisibility: 3, duration: 10)
    ) -> MosaicInfo {

        return MosaicInfo(isActive: isActive, index: index, metaId: metaId, namespaceId: namespaceId, mosaicId: mosaicId, supply: supply, height: height, owner: owner, properties: properties )
    }


    func testCreateAMosaicInfoViaConstructor() {
        let mosaicInfo = createMosaicInfo()

        XCTAssertEqual(true, mosaicInfo.isActive)
        XCTAssertEqual(0, mosaicInfo.index)
        XCTAssertEqual("5A3CD9B09CD1E8000159249B", mosaicInfo.metaId)
        XCTAssertEqual(NamespaceId(id: TestUtils.nemId),mosaicInfo.namespaceId)
        XCTAssertEqual(MosaicId(id: TestUtils.xemId), mosaicInfo.mosaicId)
        XCTAssertEqual(100, mosaicInfo.supply)
        XCTAssertEqual(0, mosaicInfo.height)
        XCTAssertEqual(try! PublicAccount(publicKeyHexString: "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF", networkType: .mijinTest), mosaicInfo.owner)
        XCTAssertTrue(mosaicInfo.isSupplyMutable)
        XCTAssertTrue(mosaicInfo.isTransferable)
        XCTAssertTrue(mosaicInfo.isLevyMutable)
        XCTAssertEqual(3, mosaicInfo.divisibility)
        XCTAssertEqual(10, mosaicInfo.duration)
    }

    func testShouldReturnIsSupplyMutableWhenIsImmutable() {
        let mosaicProperties = MosaicProperties(isSupplyMutable: false, isTransferable: true, isLevyMutable: true, divisibility: 3, duration: 10)
        let mosaicInfo = createMosaicInfo(properties: mosaicProperties)

        XCTAssertFalse(mosaicInfo.isSupplyMutable)
    }


    func testShouldReturnIsTransferableWhenItsNotTransferable() {
        let mosaicProperties = MosaicProperties(isSupplyMutable: true, isTransferable: false, isLevyMutable: true, divisibility: 3, duration: 10)
        let mosaicInfo = createMosaicInfo(properties: mosaicProperties)

        XCTAssertFalse(mosaicInfo.isTransferable)
    }

    func testShouldReturnIsLevyMutableWhenLevyIsImmutable() {
        let mosaicProperties = MosaicProperties(isSupplyMutable: true, isTransferable: true, isLevyMutable: false, divisibility: 3, duration: 10)
        let mosaicInfo = createMosaicInfo(properties: mosaicProperties)

        XCTAssertFalse(mosaicInfo.isLevyMutable)
    }
}