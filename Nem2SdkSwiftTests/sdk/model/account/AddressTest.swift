// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class AddressTest: XCTestCase {
    func testAddressCreation() {
        let address = try! Address(address: "SDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26", networkType: .mijinTest)
        XCTAssertEqual("SDGLFWDSHILTIUHGIBH5UGX2VYF5VNJEKCCDBR26", address.plain)
    }


    func testAddressWithSpacesCreation() {
        let address = try! Address(address: " SDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26 ", networkType: .mijinTest)
        XCTAssertEqual("SDGLFWDSHILTIUHGIBH5UGX2VYF5VNJEKCCDBR26", address.plain)
    }


    func testLowerCaseAddressCreation() {
        let address = try! Address(address: "sdglfw-dshilt-iuhgib-h5ugx2-vyf5vn-jekccd-br26", networkType: .mijinTest)
        XCTAssertEqual("SDGLFWDSHILTIUHGIBH5UGX2VYF5VNJEKCCDBR26", address.plain)
    }

    func testAddressInPrettyFormat() {
        let address = try! Address(address: "SDRDGF-TDLLCB-67D4HP-GIMIHP-NSRYRJ-RT7DOB-GWZY", networkType: .mijinTest)
        XCTAssertEqual("SDRDGF-TDLLCB-67D4HP-GIMIHP-NSRYRJ-RT7DOB-GWZY", address.pretty)
    }


    func testEquality() {
        let address1 = try! Address(address: "SDRDGF-TDLLCB-67D4HP-GIMIHP-NSRYRJ-RT7DOB-GWZY", networkType: .mijinTest)
        let address2 = try! Address(address: "SDRDGFTDLLCB67D4HPGIMIHPNSRYRJRT7DOBGWZY", networkType: .mijinTest)
        XCTAssertEqual(address1, address2)
    }

    func testNoEquality() {
        let address1 = try! Address(address: "SRRRRR-TTTTTT-555555-GIMIHP-NSRYRJ-RT7DOB-GWZY", networkType: .mijinTest)
        let address2 = try! Address(address: "SDRDGF-TDLLCB-67D4HP-GIMIHP-NSRYRJ-RT7DOB-GWZY", networkType: .mijinTest)
        XCTAssertNotEqual(address1, address2);
    }
}



struct AddressTestFixture {
    let address: String
    let network: NetworkType
}


class AddressValidTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { AddressValidTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                AddressTestFixture(address: "SDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26", network: .mijinTest),
                AddressTestFixture(address: "MDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26", network: .mijin),
                AddressTestFixture(address: "TDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26", network: .testNet),
                AddressTestFixture(address: "NDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26", network: .mainNet)
            ]
        }
    }

    func testAddress() {
        let fixture = self.fixture as! AddressTestFixture
        let address = try! Address(address: fixture.address, networkType: fixture.network)
        XCTAssertEqual(fixture.network, address.networkType)
    }
}

class AddressExceptionTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { AddressExceptionTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                AddressTestFixture(address: "SDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26", network: .mijin),
                AddressTestFixture(address: "MDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26", network: .mainNet),
                AddressTestFixture(address: "TDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26", network: .mainNet),
                AddressTestFixture(address: "NDGLFW-DSHILT-IUHGIB-H5UGX2-VYF5VN-JEKCCD-BR26", network: .testNet)
            ]
        }
    }

    func testAddress() {
        let fixture = self.fixture as! AddressTestFixture
        TestUtils.expectIllegalArgument {
            _ = try Address(address: fixture.address, networkType: fixture.network)
        }
    }
}



struct AddressPublicKeyTestFixture {
    let publicKey: String
    let network: NetworkType
    let address: String
}

class AddressPublicKeyTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { AddressPublicKeyTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                AddressPublicKeyTestFixture(publicKey: "b4f12e7c9f6946091e2cb8b6d3a12b50d17ccbbf646386ea27ce2946a7423dcf", network: .mijinTest, address: "SARNASAS2BIAB6LMFA3FPMGBPGIJGK6IJETM3ZSP"),
                AddressPublicKeyTestFixture(publicKey: "b4f12e7c9f6946091e2cb8b6d3a12b50d17ccbbf646386ea27ce2946a7423dcf", network: .mijin, address: "MARNASAS2BIAB6LMFA3FPMGBPGIJGK6IJE5K5RYU"),
                AddressPublicKeyTestFixture(publicKey: "b4f12e7c9f6946091e2cb8b6d3a12b50d17ccbbf646386ea27ce2946a7423dcf", network: .testNet, address: "TARNASAS2BIAB6LMFA3FPMGBPGIJGK6IJE47FYR3"),
                AddressPublicKeyTestFixture(publicKey: "b4f12e7c9f6946091e2cb8b6d3a12b50d17ccbbf646386ea27ce2946a7423dcf", network: .mainNet, address: "NARNASAS2BIAB6LMFA3FPMGBPGIJGK6IJFJKUV32"),
            ]
        }
    }

    func testAddress() {
        let fixture = self.fixture as! AddressPublicKeyTestFixture
        let address = try! Address(publicKeyHexString: fixture.publicKey, networkType: fixture.network)
        XCTAssertEqual(fixture.address, address.plain)
    }
}

