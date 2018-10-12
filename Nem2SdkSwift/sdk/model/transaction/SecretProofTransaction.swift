// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// Secret lock transaction
public class SecretProofTransaction: Transaction {
    // MARK: Properties

    /// Hash algorithm, secret is generated with.
    public let hashType: HashType
    /// Proof hashed.
    public let secret: [UInt8]
    /// Proof.
    public let proof: [UInt8]

    // MARK: Methods
    init(base: Transaction,
         hashType: HashType,
         secret: [UInt8],
         proof: [UInt8]) {

        self.hashType = hashType
        self.secret = secret
        self.proof = proof

        super.init(base: base)
    }


    /**
     * Create a secret proof transaction object.
     *
     * - parameter hashType:    Hash algorithm secret is generated with.
     * - parameter secret:      Proof hashed.
     * - parameter proof:       Proof.
     * - parameter recipient:   Recipient of the funds.
     * - parameter networkType: Network type.
     * - parameter deadline:    Deadline to include the transaction.(Optional. The default is 1 hour from now.)
     *
     * - returns:  a SecretProofTransaction instance
     */
    public static func create(
            hashType: HashType,
            secret: [UInt8],
            proof: [UInt8],
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60)) -> SecretProofTransaction {
        let base = Transaction(type: .secretProof, networkType: networkType, version: 3, deadline: deadline)
        return SecretProofTransaction(
                base: base,
                hashType: hashType,
                secret: secret,
                proof: proof)
    }

    override func getTransactionBodyBytes() -> [UInt8] {
        return self.hashType.rawValue.bytes + // hash algorithm 1 byte
                self.secret + // secret 64 byte
                UInt16(self.proof.count).bytes + // proof size 2 bytes
                self.proof // proof
    }
}
