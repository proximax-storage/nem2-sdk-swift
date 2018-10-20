// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import CryptoSwift
import CommonCrypto

public class SecureMessage: Message {
    private static let keyLength = 256 / 8
    private static let blockSize = 16

    // MARK: Properties
    /// Plain text message. Nil If loaded payload cannot be decoded as utf-8 string.

    /**
     * Constructor
     *
     * - parameter encodedPayload: Encoded(encrypted) payload
     */
    public init(encodedPayload: [UInt8]) {
        super.init(type: .secure, payload: encodedPayload)
    }

    /**
     * Constructor
     *
     * - parameter decodedPayload: Decoded(not encrypted) payload.
     * - parameter privateKey: Private key.
     * - parameter publicKey: Public key.
     */
    public init(decodedPayload: [UInt8], privateKey: PrivateKey, publicKey: PublicKey) throws {
        let salt = SecureMessage.createRandomBytesOf(SecureMessage.keyLength)
        let iv = SecureMessage.createRandomBytesOf(SecureMessage.blockSize)

        do {
            let keyPair = KeyPair(privateKey: privateKey)
            let sharedKey = SecureMessage.calculateSharedKey(keys: keyPair, peerPublicKey: publicKey.bytes, salt: salt)
            let aes = try AES(key: sharedKey, blockMode: CBC(iv: iv), padding: .pkcs7)

            let encryptedMessage = try aes.encrypt(decodedPayload)

            let encodedPayload = salt + iv + encryptedMessage

            super.init(type: .secure, payload: encodedPayload)
        } catch {
            throw Nem2SdkSwiftError.messageEncryptionError("Failed to encrypt message.")
        }
    }


    /**
     * Decodes the payload and returns is.
     *
     * - parameter privateKey: Private key.
     * - parameter publicKey: Public key.
     */
    public func getDecodedPayload(privateKey: PrivateKey, publicKey: PublicKey) throws -> [UInt8] {
        guard payload.count >= SecureMessage.keyLength + SecureMessage.blockSize else {
            throw Nem2SdkSwiftError.messageEncryptionError("Payload is too short to decode.")
        }

        let salt = payload[0..<SecureMessage.keyLength].map { $0 }
        let iv = payload[SecureMessage.keyLength..<SecureMessage.keyLength + SecureMessage.blockSize].map { $0 }
        let encryptedMessage = Array(payload.dropFirst(SecureMessage.keyLength + SecureMessage.blockSize))

        do {
            let keyPair = KeyPair(privateKey: privateKey)
            let sharedKey = SecureMessage.calculateSharedKey(keys: keyPair, peerPublicKey: publicKey.bytes, salt: salt)


            let aes = try AES(key: sharedKey, blockMode: CBC(iv: iv), padding: .pkcs7)

            let message = try aes.decrypt(encryptedMessage)

            return message
        } catch {
            throw Nem2SdkSwiftError.messageEncryptionError("Failed to decrypt message.")
        }
    }



    private static func calculateSharedKey(keys: KeyPair, peerPublicKey: [UInt8], salt: [UInt8]) -> [UInt8] {
        var sharedKey = [UInt8](repeating: 0, count: SecureMessage.keyLength)
        var varPeerPublicKey = peerPublicKey
        var varNativePrivateKey = keys.nativePrivateKey
        var varSalt = salt

        create_shared_key(&sharedKey, &varPeerPublicKey, &varNativePrivateKey, &varSalt)

        return sharedKey
    }

    private static func createRandomBytesOf(_ count: Int) -> [UInt8] {
        var randomBytes = [UInt8](repeating: 0, count: count)
        let _ = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes)
        return randomBytes
    }
}