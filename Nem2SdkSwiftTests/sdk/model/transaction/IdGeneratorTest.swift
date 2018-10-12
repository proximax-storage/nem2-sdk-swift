// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift


class IdGeneratorTest: XCTestCase {

    let nemId: UInt64 = 0x84B3552D375FFA4B
    let xemId: UInt64 = 0xD525AD41D95FCF29

    func testNamespacePathGeneratesCorrectWellKnownRootPath() {
        let ids = try! IdGenerator.generateNamespacePath(name: "nem")
        XCTAssertEqual(ids.count, 1)
        XCTAssertEqual(nemId, ids[0])
    }

    func testNamespacePathGeneratesCorrectWellKnownChildPath() {
        let ids = try! IdGenerator.generateNamespacePath(name: "nem.xem")

        XCTAssertEqual(ids.count, 2)
        XCTAssertEqual(nemId, ids[0])
        XCTAssertEqual(xemId, ids[1])
    }

    func testNamespacePathSupportsMultiLevelNamespaces() {
        var ids: [UInt64] = []
        ids.append(IdGenerator.generateId(name: "foo", parentId: 0))
        ids.append(IdGenerator.generateId(name: "bar", parentId: ids[0]))
        ids.append(IdGenerator.generateId(name: "baz", parentId: ids[1]))

        XCTAssertEqual(try! IdGenerator.generateNamespacePath(name: "foo.bar.baz"), ids)
    }


    func testNamespacePathRejectsNamesWithTooManyParts() {
        TestUtils.expectIllegalArgument(message: "too many parts") {
            _ = try IdGenerator.generateNamespacePath(name: "a.b.c.d")
        }
        TestUtils.expectIllegalArgument(message: "too many parts") {
            _ = try IdGenerator.generateNamespacePath(name: "a.b.c.d.e")
        }
    }

    func testMosaicIdGeneratesCorrectWellKnowId() {
        let id = try! IdGenerator.generateMosaicId(namespaceFullName: "nem", mosaicName: "xem")
        XCTAssertEqual(xemId, id)
    }

    func testMosaicIdSupportMultiLevelMosaics() {
        var ids: [UInt64] = []
        ids.append(IdGenerator.generateId(name: "foo", parentId: 0))
        ids.append(IdGenerator.generateId(name: "bar", parentId: ids[0]))
        ids.append(IdGenerator.generateId(name: "baz", parentId: ids[1]))
        ids.append(IdGenerator.generateId(name: "tokens", parentId: ids[2]))

        XCTAssertEqual(try! IdGenerator.generateMosaicId(namespaceFullName: "foo.bar.baz", mosaicName: "tokens"), ids[3])
    }

    func testNamespaceInvalid() {
        let invalidPatterns = [
            "",
            "alpha.bet@.zeta",
            "a!pha.beta.zeta",
            "alpha.beta.ze^a",
            ".",
            ".a",
            "a..a",
            "A"
        ]
        for pattern in invalidPatterns {
            TestUtils.expectIllegalArgument(message: "invalid namespace name") {
                _ = try IdGenerator.generateNamespacePath(name: pattern)
            }
        }
    }

    func testMosaicInvalid() {
        TestUtils.expectIllegalArgument(message: "having zero length") {
            _ = try IdGenerator.generateMosaicId(namespaceFullName: "a", mosaicName: "")
        }

        let invalidMosaics = [
            "A",
            "a..a",
            ".",
            "@lpha",
            "a!pha",
            "alph*",
            "alp^a",
        ]
        for mosaicName in invalidMosaics {
            TestUtils.expectIllegalArgument(message: "invalid mosaic name") {
                _ = try IdGenerator.generateMosaicId(namespaceFullName: "a", mosaicName: mosaicName)
            }
        }
    }
}
