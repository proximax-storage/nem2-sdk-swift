// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// The account structure describes an account private key, public key, address and allows signing transactions.
public class Account {
    // MARK: Properties
    /// Account keyPair containing public and private key.
    public let keyPair: KeyPair
    /// Public account.
    public let publicAccount: PublicAccount

    /// Account address
    public var address: Address {
        return publicAccount.address
    }
    /// Account public key hex string
    public var publicKeyHexString: String {
        return keyPair.publicKey.description
    }
    /// Account public key bytes
    public var publicKeyBytes: [UInt8] {
        return keyPair.publicKey.bytes
    }

    /// Account private key hex string
    public var privateKeyHexString: String {
        return keyPair.privateKey.description
    }

    // MARK: Methods
    /**
     * Create an Account from a given private key hex string.
     *
     * - parameter privateKeyHexString: Private key hex string
     * - parameter networkType: NetworkType
     * - throws: Nem2SdkSwiftError.illegalArgument if the private key hex string is malformed.
     */
    public convenience init(privateKeyHexString: String, networkType: NetworkType) throws {
        let keyPair = KeyPair(privateKey: try PrivateKey(hexString: privateKeyHexString))
        self.init(keyPair: keyPair, networkType: networkType)
    }

    /**
     * Create an Account from a given private key.
     *
     * - parameter keyPair: Key pair
     * - parameter networkType: NetworkType
     */
    public init(keyPair: KeyPair, networkType: NetworkType) {
        self.keyPair = keyPair
        self.publicAccount = PublicAccount(publicKey: keyPair.publicKey, networkType: networkType)
    }

    /**
     * Create an Account with random generated private key.
     *
     * - parameter networkType: NetworkType
     */
    public convenience init(networkType: NetworkType) {
        self.init(keyPair: KeyPair(), networkType: networkType)
    }

    /**
     * Sign a transaction.
     *
     * - parameter transaction: The transaction to be signed.
     * - returns: SignedTransaction
     */
    public func sign(transaction: Transaction) -> SignedTransaction {
        return transaction.signWith(account: self)
    }


    /**
     * Sign aggregate signature transaction.
     *
     * - parameter cosignatureTransaction: The aggregate signature transaction.
     * - returns CosignatureSignedTransaction
     */
    public func sign(cosignatureTransaction: CosignatureTransaction) -> CosignatureSignedTransaction {
        return cosignatureTransaction.signWith(account: self)
    }

    /**
     * Sign transaction with cosignatories creating a new SignedTransaction.
     *
     * - parameter transaction:   The aggregate transaction to be signed.
     * - parameter cosignatories: The list of accounts that will cosign the transaction
     * - returns: SignedTransaction
     */
    public func sign(aggregateTransaction: AggregateTransaction, with cosignatories: [Account]) -> SignedTransaction {
        return aggregateTransaction.signWith(initiatorAccount: self, cosignatories: cosignatories)
    }
}
