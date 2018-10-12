// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The cosignature transaction is used to sign an aggregate transactions with missing cosignatures.
public class CosignatureTransaction {
    // MARK: Properties
    /// Transaction to cosign.
    public let transactionToCosign: AggregateTransaction

    private let transactionToCosignHash: [UInt8]

    // MARK: Methods
    /**
     * Constructor
     *
     * - parameter transactionToCosign: Aggregate transaction that will be cosigned.
     */
    public init(transactionToCosign: AggregateTransaction) throws {
        guard let hash = transactionToCosign.transactionInfo?.hash else {
            throw Nem2SdkSwiftError.illegalArgument("Transaction to cosign should be announced before being able to cosign it")
        }
        self.transactionToCosign = transactionToCosign
        self.transactionToCosignHash = hash
    }

    /**
     * Serialize and sign transaction creating a new SignedTransaction.
     *
     * - parameter account: Account
     * - returns: CosignatureSignedTransaction
     */
    public func signWith(account: Account) -> CosignatureSignedTransaction {
        let signer = Signer(keyPair: account.keyPair)
        let bytes = self.transactionToCosignHash
        let signatureBytes = signer.sign(message: bytes)
        return CosignatureSignedTransaction(parentHash: transactionToCosignHash, signature: signatureBytes, signer: account.publicKeyBytes)
    }
}
