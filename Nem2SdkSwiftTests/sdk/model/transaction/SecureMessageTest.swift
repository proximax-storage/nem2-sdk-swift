// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import XCTest
@testable import Nem2SdkSwift

class SecureMessageTest: XCTestCase {

    private let testSenderPrivateKey = "8374B5915AEAB6308C34368B15ABF33C79FD7FEFC0DEAF9CC51BA57F120F1190"
    private let testSenderPublicKey = "9E7930144DA0845361F650BF78A36791ABF2577E251706ECA45480998FE61D18"

    private let testRecipientPrivateKey = "369CB3195F88A16F8326DABBD37DA5F8458B55AA5DA6F7E2F756A12BE6CAA546"
    private let testRecipientPublicKey = "8E1A94D534EA6A3B02B0B967701549C21724C7644B2E4C20BF15D01D50097ACB"

    private let testOtherPrivateKey = "8534E476C13A736645035D535EDF2759295FF1EF65E7FFBDA31501A3C1F3CB99"
    private let testOtherPublicKey = "10F3D152493F173EC9ED55F70606392FFB4E21A333EDD192AD4770AA8DF911ED"

    private var sampleEncodedPayload: [UInt8] {
        return try! SecureMessage(
                decodedPayload: Array("test-message".utf8),
                privateKey: try! PrivateKey(hexString: testSenderPrivateKey),
                publicKey: try! PublicKey(hexString: testRecipientPublicKey)).payload

    }

    func testShouldCreateSecureMessageFromDecodedPayload() {
        let secureMessage = try! SecureMessage(
                decodedPayload: Array("test-message".utf8),
                privateKey: try! PrivateKey(hexString: testSenderPrivateKey),
                publicKey: try! PublicKey(hexString: testRecipientPublicKey))

        XCTAssertEqual("test-message", String(bytes: try! secureMessage.getDecodedPayload(
                privateKey: try! PrivateKey(hexString: testSenderPrivateKey),
                publicKey: try! PublicKey(hexString: testRecipientPublicKey)), encoding: .utf8))

        XCTAssertNotNil(secureMessage.payload)
        XCTAssertEqual(MessageType.secure, secureMessage.type)
    }

    func testShouldRetrieveDecodedPayloadUsingSenderPrivateKey() {
        let payload = sampleEncodedPayload
        let secureMessage = SecureMessage(encodedPayload: payload)

        XCTAssertEqual("test-message", String(bytes: try! secureMessage.getDecodedPayload(
                privateKey: try! PrivateKey(hexString: testSenderPrivateKey),
                publicKey: try! PublicKey(hexString: testRecipientPublicKey)), encoding: .utf8))

        XCTAssertEqual(payload, secureMessage.payload)
        XCTAssertEqual(MessageType.secure, secureMessage.type)
    }

    func testShouldRetrieveDecodedPayloadUsingRecipientPrivateKey() {
        let payload = sampleEncodedPayload
        let secureMessage = SecureMessage(encodedPayload: payload)

        XCTAssertEqual("test-message", String(bytes: try! secureMessage.getDecodedPayload(
                privateKey: try! PrivateKey(hexString: testRecipientPrivateKey),
                publicKey: try! PublicKey(hexString: testSenderPublicKey)), encoding: .utf8))

        XCTAssertEqual(payload, secureMessage.payload)
        XCTAssertEqual(MessageType.secure, secureMessage.type)
    }

    func testFailRetrievingDecodedPayloadUsingWrongPrivateKey() {
        let secureMessage = SecureMessage(encodedPayload: sampleEncodedPayload)

        // Expect an error or invalid result
        do {
            let decoded = try! secureMessage.getDecodedPayload(
                    privateKey: try! PrivateKey(hexString: testOtherPrivateKey),
                    publicKey: try! PublicKey(hexString: testRecipientPublicKey))
            XCTAssertNotEqual(Array("test-message".utf8), decoded)
        } catch let error{
            if case Nem2SdkSwiftError.messageEncryptionError(_) = error {
            } else {
                XCTFail("UnexpectedError")
            }
        }
    }

    func testFailRetrievingDecodedPayloadUsingWrongPublicKey() {
        let secureMessage = SecureMessage(encodedPayload: sampleEncodedPayload)

        // Expect an error or invalid result
        do {
            let decoded = try! secureMessage.getDecodedPayload(
                    privateKey: try! PrivateKey(hexString: testSenderPrivateKey),
                    publicKey: try! PublicKey(hexString: testOtherPublicKey))
            XCTAssertNotEqual(Array("test-message".utf8), decoded)
        } catch let error{
            if case Nem2SdkSwiftError.messageEncryptionError(_) = error {
            } else {
                XCTFail("UnexpectedError")
            }
        }
    }

    func testFailRetrievingDecodedPayloadUsingWrongBothKeys() {
        let secureMessage = SecureMessage(encodedPayload: sampleEncodedPayload)

        // Expect an error or invalid result
        do {
            let decoded = try! secureMessage.getDecodedPayload(
                    privateKey: try! PrivateKey(hexString: testOtherPrivateKey),
                    publicKey: try! PublicKey(hexString: testOtherPublicKey))
            XCTAssertNotEqual(Array("test-message".utf8), decoded)
        } catch let error{
            if case Nem2SdkSwiftError.messageEncryptionError(_) = error {
            } else {
                XCTFail("UnexpectedError")
            }
        }
    }

}