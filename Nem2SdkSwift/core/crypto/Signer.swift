// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation


class Signer {

    private let keyPair: KeyPair
    private static let signatureSize = 64

    init(keyPair: KeyPair) {
        self.keyPair = keyPair
    }

    func sign(message: [UInt8]) -> [UInt8] {
        var signature = [UInt8](repeating: 0, count: Signer.signatureSize)
        var messageVar = message
        var publicVar = keyPair.publicKey.bytes
        var privateVar = keyPair.nativePrivateKey

        ed25519_sha3_sign(&signature,
                &messageVar,
                message.count,
                &publicVar,
                &privateVar)

        return signature
    }

}