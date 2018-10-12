// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
@testable import Nem2SdkSwift

class FakeTransferTransaction: Transaction {

    init(networkType: NetworkType, version: UInt8, deadline: Deadline, fee: UInt64, signature: String? = nil, signer: PublicAccount? = nil, transactionInfo: TransactionInfo? = nil) {
        super.init(type: .transfer,
                networkType: networkType,
                version: version,
                deadline: deadline,
                fee: fee,
                signature: signature,
                signer: signer,
                transactionInfo: transactionInfo)
    }

    override func getTransactionBodyBytes() -> [UInt8] {
        fatalError("Method no implemented")
    }
}
