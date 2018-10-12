// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// Key pair of a private key and the public key
public class KeyPair {
    static let PUBLIC_KEY_SIZE = 32
    static let PRIVATE_KEY_SIZE = 64
    static let PRIVATE_KEY_SEED_SIZE = 32
    static let SIGNATURE_SIZE = 64

    // MARK: Properties
    /// Private key.
    public let privateKey: PrivateKey
    /// Public key.
    public let publicKey: PublicKey

    // :nodoc:
    let nativePrivateKey: [UInt8]

    // MARK: Methods
    /// Creates a random key pair.
    public convenience init() {
        var privateKeySeed = [UInt8](repeating: 0, count: KeyPair.PRIVATE_KEY_SEED_SIZE)
        ed25519_create_seed(&privateKeySeed)

        self.init(privateKey: try! PrivateKey(bytes: privateKeySeed))
    }

    /**
     * Creates a key pair around a private key.
     * The public key is calculated from the private key.
     *
     * - parameter privateKey: The private key.
     */
    public init(privateKey: PrivateKey) {
        var calculatedPrivateKey = [UInt8](repeating: 0, count: KeyPair.PRIVATE_KEY_SIZE)
        var publicKey = [UInt8](repeating: 0, count: KeyPair.PUBLIC_KEY_SIZE)
        var privateKeySeed = privateKey.bytes

        ed25519_sha3_create_keypair(&publicKey, &calculatedPrivateKey, &privateKeySeed)

        self.privateKey = privateKey
        self.publicKey = try! PublicKey(bytes: publicKey)
        self.nativePrivateKey = calculatedPrivateKey
    }
}