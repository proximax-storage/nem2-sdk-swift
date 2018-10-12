// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation


struct CosignatureSignedTransactionDTO: Codable {
    let parentHash: String
    let signature: String
    let signer: String
}