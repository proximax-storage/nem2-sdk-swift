// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import XCTest
import RxSwift
import RxBlocking
import Nem2SdkSwift

class E2ETest: XCTestCase {
    private let transactionHttp = TransactionHttp(url: TestSettings.url)
    private let accountHttp = AccountHttp(url: TestSettings.url)
    private let account = try! Account(privateKeyHexString: TestSettings.accountPrivateKey, networkType: .mijinTest)
    private let multisigAccount = try! Account(privateKeyHexString: TestSettings.multisigPrivateKey, networkType: .mijinTest)
    private let cosignatoryAccount1 = try! Account(privateKeyHexString: TestSettings.cosignatory1PrivateKey, networkType: .mijinTest)
    private let cosignatoryAccount2 = try! Account(privateKeyHexString: TestSettings.cosignatory2PrivateKey, networkType: .mijinTest)

    // nem2-cli transaction namespace -r -n "test-root-namespace" -d 1000
    private let namespaceId = try! NamespaceId(fullName: "test-root-namespace") // This namespace is created in functional testing
    private let namespaceName = "test-root-namespace"

    // nem2-cli transaction mosaic -m "test-mosaic" -n "test-root-namespace" -a 1000000 -t -s -l -d 0 -u 1000
    private let mosaicId = try! MosaicId(fullName: "test-root-namespace:test-mosaic") // This mosaic is created in functional testing
    private var listener: Listener!

    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        listener = Listener(url: TestSettings.url)
        disposeBag = DisposeBag()

        listener.error().subscribe(
                onNext: { error in
                    if case Nem2SdkSwiftError.parseError(let message) = error {
                        print(message)
                    } else {
                        print(error.localizedDescription)
                    }
                }
        ).disposed(by: disposeBag)

        _ = try! listener.open().toBlocking().first()

        watchTransactionError(account.address)

    }

    func testStandaloneTransferTransaction() {
        let transferTransaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SDRDGFTDLLCB67D4HPGIMIHPNSRYRJRT7DOBGWZY"),
                mosaics: [XEM.of(microXemAmount: 1)],
                message: PlainMessage(text: "message"),
                networkType: .mijinTest
        )

        let signedTransaction = account.sign(transaction: transferTransaction)
        announceAndValidateTransaction(signedTransaction, account.address)
    }

    func testAggregateTransferTransaction() {
        let transferTransaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SDRDGFTDLLCB67D4HPGIMIHPNSRYRJRT7DOBGWZY"),
                mosaics: [XEM.of(microXemAmount: 1)],
                message: PlainMessage(text: "messageloooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" +
                        "ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" +
                        "ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" +
                        "ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" +
                        "ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" +
                        "ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" +
                        "oooooooong"), // Use long message to test if size of inner transaction is calculated correctly
                networkType: .mijinTest)


        let aggregateTransaction = try! AggregateTransaction.createComplete(
                innerTransactions: [transferTransaction.toAggregate(signer: account.publicAccount)],
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: aggregateTransaction)

        announceAndValidateTransaction(signedTransaction, account.address)
    }

    func testStandaloneRootRegisterNamespaceTransaction() {
        let namespaceName = "test-root-namespace-\(arc4random())"

        let registerNamespaceTransaction = try! RegisterNamespaceTransaction.createRootNamespace(
                namespaceName: namespaceName,
                duration: 100,
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: registerNamespaceTransaction)

        announceAndValidateTransaction(signedTransaction, account.address)
    }

    func testAggregateRootRegisterNamespaceTransaction() {
        let namespaceName = "test-root-namespace-\(arc4random())"
        let registerNamespaceTransaction = try! RegisterNamespaceTransaction.createRootNamespace(
                namespaceName: namespaceName,
                duration: 100,
                networkType: .mijinTest)

        let aggregateTransaction = try! AggregateTransaction.createComplete(
                innerTransactions: [registerNamespaceTransaction.toAggregate(signer: account.publicAccount)],
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: aggregateTransaction)

        announceAndValidateTransaction(signedTransaction, account.address)
    }

    func testStandaloneSubNamespaceRegisterNamespaceTransaction() {
        let namespaceName = "test-sub-namespace-\(arc4random())"

        let registerNamespaceTransaction = try! RegisterNamespaceTransaction.createSubNamespace(
                namespaceName: namespaceName,
                parentId: namespaceId,
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: registerNamespaceTransaction)

        announceAndValidateTransaction(signedTransaction, account.address)
    }


    func testAggregateSubNamespaceRegisterNamespaceTransaction() {
        let namespaceName = "test-sub-namespace-\(arc4random())"

        let registerNamespaceTransaction = try! RegisterNamespaceTransaction.createSubNamespace(
                namespaceName: namespaceName,
                parentId: namespaceId,
                networkType: .mijinTest)

        let aggregateTransaction = try! AggregateTransaction.createComplete(
                innerTransactions: [registerNamespaceTransaction.toAggregate(signer: account.publicAccount)],
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: aggregateTransaction)

        announceAndValidateTransaction(signedTransaction, account.address)
    }


    func testStandaloneMosaicDefinitionTransaction() {
        let mosaicName = "test-mosaic-\(arc4random())"

        let mosaicDefinitionTransaction = try! MosaicDefinitionTransaction.create(
                mosaicName: mosaicName,
                namespaceFullName: namespaceName,
                mosaicProperties: MosaicProperties(
                        isSupplyMutable: true,
                        isTransferable: true,
                        isLevyMutable: true,
                        divisibility: 4,
                        duration: 100),
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: mosaicDefinitionTransaction)

        announceAndValidateTransaction(signedTransaction, account.address)
    }

    func testAggregateMosaicDefinitionTransaction() {
        let mosaicName = "test-mosaic-\(arc4random())"

        let mosaicDefinitionTransaction = try! MosaicDefinitionTransaction.create(
                mosaicName: mosaicName,
                namespaceFullName: namespaceName,
                mosaicProperties: MosaicProperties(
                        isSupplyMutable: true,
                        isTransferable: true,
                        isLevyMutable: true,
                        divisibility: 4,
                        duration: 100),
                networkType: .mijinTest)

        let aggregateTransaction = try! AggregateTransaction.createComplete(
                innerTransactions: [mosaicDefinitionTransaction.toAggregate(signer: account.publicAccount)],
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: aggregateTransaction)

        announceAndValidateTransaction(signedTransaction, account.address)
    }


    func testStandaloneMosaicSupplyChangeTransaction() {
        let mosaicSupplyChangeTransaction = MosaicSupplyChangeTransaction.create(
                mosaicId: mosaicId,
                mosaicSupplyType: .increase,
                delta: 10,
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: mosaicSupplyChangeTransaction)

        announceAndValidateTransaction(signedTransaction, account.address)
    }


    func testAggregateMosaicSupplyChangeTransaction() {
        let mosaicSupplyChangeTransaction = MosaicSupplyChangeTransaction.create(
                mosaicId: mosaicId,
                mosaicSupplyType: .increase,
                delta: 10,
                networkType: .mijinTest)

        let aggregateTransaction = try! AggregateTransaction.createComplete(
                innerTransactions: [mosaicSupplyChangeTransaction.toAggregate(signer: account.publicAccount)],
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: aggregateTransaction)

        announceAndValidateTransaction(signedTransaction, account.address)
    }

    func testShouldSignModifyMultisigAccountTransactionWithCosignatories() {
        watchTransactionError(cosignatoryAccount1.address)
        watchTransactionError(cosignatoryAccount2.address)

        let modifyMultisigAccountTransaction = ModifyMultisigAccountTransaction.create(
                minApprovalDelta: 0,
                minRemovalDelta: 0,
                modifications: [MultisigCosignatoryModification(
                        type: .add,
                        cosignatory: Account(networkType: .mijinTest).publicAccount)],
                networkType: .mijinTest)

        let aggregateTransaction = try! AggregateTransaction.createBonded(
                innerTransactions: [modifyMultisigAccountTransaction.toAggregate(signer: multisigAccount.publicAccount)],
                networkType: .mijinTest)

        let signedTransaction = cosignatoryAccount1.sign(transaction: aggregateTransaction)

        let lockFundsTransaction = try! LockFundsTransaction.create(
                mosaic: XEM.of(xemAmount: 10),
                duration: 100,
                signedTransaction: signedTransaction,
                networkType: .mijinTest)

        let lockFundsSignedTransaction = cosignatoryAccount1.sign(transaction: lockFundsTransaction)

        announceAndValidateTransaction(lockFundsSignedTransaction, cosignatoryAccount1.address)

        let announcedAggregateTransaction = announceAndValidateAggregateBondedTransaction(signedTransaction, cosignatoryAccount1.address)

        // confirm to unlock funds
        let cosignatureTransaction = try! CosignatureTransaction(transactionToCosign: announcedAggregateTransaction)
        let cosignatureSignedTransaction = cosignatoryAccount2.sign(cosignatureTransaction: cosignatureTransaction)
        _ = try! transactionHttp.announceAggregateBondedCosignature(cosignatureSignedTransaction: cosignatureSignedTransaction).toBlocking().first()!

        // waiting for confirmed for next test
        _ = try! listener.confirmed(address: cosignatoryAccount2.address).toBlocking().first()!

    }

    func testCosignatureTransaction() {
        let addresses = [multisigAccount.address, cosignatoryAccount1.address, cosignatoryAccount2.address]
        addresses.forEach {
            watchTransactionError($0)
            watchBondedAdded($0)
            watchConfirmed($0)
            watchUnconfirmed($0)
        }

        let transferTransaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SDRDGFTDLLCB67D4HPGIMIHPNSRYRJRT7DOBGWZY"),
                mosaics: [XEM.of(microXemAmount: 1)],
                message: PlainMessage(text: "message"),
                networkType: .mijinTest
        )

        let aggregateTransaction = try! AggregateTransaction.createBonded(
                innerTransactions: [transferTransaction.toAggregate(signer: multisigAccount.publicAccount)],
                networkType: .mijinTest)

        let signedTransaction = cosignatoryAccount1.sign(transaction: aggregateTransaction)

        let lockFundsTransaction = try! LockFundsTransaction.create(
                mosaic: XEM.of(xemAmount: 10),
                duration: 100,
                signedTransaction: signedTransaction,
                networkType: .mijinTest)

        let lockFundsSignedTransaction = cosignatoryAccount1.sign(transaction: lockFundsTransaction)

        announceAndValidateTransaction(lockFundsSignedTransaction, cosignatoryAccount1.address)

        let announcedAggregateTransaction = announceAndValidateAggregateBondedTransaction(signedTransaction, cosignatoryAccount1.address)

        let cosignatureTransaction = try! CosignatureTransaction(transactionToCosign: announcedAggregateTransaction)
        let cosignatureSignedTransaction = cosignatoryAccount2.sign(cosignatureTransaction: cosignatureTransaction)

        announceAndValidateAggregateBondedCosignatureTransaction(cosignatureSignedTransaction, cosignatoryAccount1.address)

        // waiting for confirmed for next test
        _ = try! listener.confirmed(address: cosignatoryAccount2.address).toBlocking().first()!
    }


    func testStandaloneLockFundsTransaction() {
        let aggregateTransaction = try! AggregateTransaction.createBonded(
                innerTransactions: [],
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: aggregateTransaction)

        let lockFundstx = try! LockFundsTransaction.create(
                mosaic: XEM.of(xemAmount: 10),
                duration: 100,
                signedTransaction: signedTransaction,
                networkType: .mijinTest)

        let lockFundsTransactionSigned = account.sign(transaction: lockFundstx)

        announceAndValidateTransaction(lockFundsTransactionSigned, account.address)
    }

    func testAggregateLockFundsTransaction() {
        let aggregateTransaction = try! AggregateTransaction.createBonded(
                innerTransactions: [],
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: aggregateTransaction)

        let lockFundstx = try! LockFundsTransaction.create(
                mosaic: XEM.of(xemAmount: 10),
                duration: 100,
                signedTransaction: signedTransaction,
                networkType: .mijinTest)

        let lockFundsAggregatetx = try! AggregateTransaction.createComplete(
                innerTransactions: [lockFundstx.toAggregate(signer: account.publicAccount)],
                networkType: .mijinTest)

        let lockFundsTransactionSigned = account.sign(transaction: lockFundsAggregatetx)

        announceAndValidateTransaction(lockFundsTransactionSigned, account.address)
    }

    func testStandaloneSecretLockTransaction() {
        var proof = [UInt8](repeating: 0, count: 20)
        _ = SecRandomCopyBytes(kSecRandomDefault, 20, &proof)

        let secret = Hashes.sha3_512(proof)

        let secretLocktx = SecretLockTransaction.create(
                mosaic: XEM.of(microXemAmount: 1),
                duration: 1,
                hashType: .sha3_512,
                secret: secret,
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                networkType: .mijinTest)

        let secretLockTransactionSigned = account.sign(transaction: secretLocktx)

        announceAndValidateTransaction(secretLockTransactionSigned, account.address)
    }

    func testAggregateSecretLockTransaction() {
        var proof = [UInt8](repeating: 0, count: 20)
        _ = SecRandomCopyBytes(kSecRandomDefault, 20, &proof)

        let secret = Hashes.sha3_512(proof)

        let secretLocktx = SecretLockTransaction.create(
                mosaic: XEM.of(microXemAmount: 1),
                duration: 1,
                hashType: .sha3_512,
                secret: secret,
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                networkType: .mijinTest)

        let secretLockAggregatetx = try! AggregateTransaction.createComplete(
                innerTransactions: [secretLocktx.toAggregate(signer: account.publicAccount)],
                networkType: .mijinTest)

        let secretLockTransactionSigned = account.sign(transaction: secretLockAggregatetx)

        announceAndValidateTransaction(secretLockTransactionSigned, account.address)
    }

    func testStandaloneSecretProofTransaction() {
        var proof = [UInt8](repeating: 0, count: 20)
        _ = SecRandomCopyBytes(kSecRandomDefault, 20, &proof)

        let secret = Hashes.sha3_512(proof)

        let secretLocktx = SecretLockTransaction.create(
                mosaic: XEM.of(microXemAmount: 1),
                duration: 10,
                hashType: .sha3_512,
                secret: secret,
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                networkType: .mijinTest)

        let lockFundsTransactionSigned = account.sign(transaction: secretLocktx)


        announceAndValidateTransaction(lockFundsTransactionSigned, account.address)

        let secretProoftx = SecretProofTransaction.create(
                hashType: .sha3_512,
                secret: secret,
                proof: proof,
                networkType: .mijinTest)

        let secretProofTransactionSigned = account.sign(transaction: secretProoftx)

        announceAndValidateTransaction(secretProofTransactionSigned, account.address)

    }

    func testAggregateSecretProofTransaction() {
        var proof = [UInt8](repeating: 0, count: 20)
        _ = SecRandomCopyBytes(kSecRandomDefault, 20, &proof)

        let secret = Hashes.sha3_512(proof)

        let secretLocktx = SecretLockTransaction.create(
                mosaic: XEM.of(microXemAmount: 1),
                duration: 10,
                hashType: .sha3_512,
                secret: secret,
                recipient: try! Address(rawAddress: "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"),
                networkType: .mijinTest)

        let lockFundsTransactionSigned = account.sign(transaction: secretLocktx)


        announceAndValidateTransaction(lockFundsTransactionSigned, account.address)

        let secretProoftx = SecretProofTransaction.create(
                hashType: .sha3_512,
                secret: secret,
                proof: proof,
                networkType: .mijinTest)

        let secretProofAggregatetx = try! AggregateTransaction.createComplete(
                innerTransactions: [secretProoftx.toAggregate(signer: account.publicAccount)],
                networkType: .mijinTest)

        let secretProofTransactionSigned = account.sign(transaction: secretProofAggregatetx)

        announceAndValidateTransaction(secretProofTransactionSigned, account.address)
    }

    func testEncryptAndDecryptMessage() {
        let transferTransaction = TransferTransaction.create(
                recipient: cosignatoryAccount1.address,
                mosaics: [XEM.of(microXemAmount: 1)],
                message: try! SecureMessage(
                        decodedPayload: Array("message".utf8),
                        privateKey: account.keyPair.privateKey,
                        publicKey: cosignatoryAccount1.keyPair.publicKey),
                networkType: .mijinTest
        )

        let signedTransaction = account.sign(transaction: transferTransaction)

        let confirmedObservable = listener.confirmed(address: account.address)

        _ = try! transactionHttp.announce(signedTransaction: signedTransaction).toBlocking().first()!

        let transaction = try! confirmedObservable.toBlocking().first()!

        XCTAssertEqual(signedTransaction.hash, transaction.transactionInfo!.hash!)

        guard let transfer = transaction as? TransferTransaction else {
            XCTFail("Transaction is not transfer")
            return
        }

        guard let message = transfer.message else {
            XCTFail("Transaction does not have message.")
            return
        }

        guard let secureMessage = transfer.message as? SecureMessage else {
            XCTFail("Transaction does not have message.")
            return
        }
        XCTAssertEqual(MessageType.secure, message.type)
        XCTAssertEqual("message", String(
                bytes: try! secureMessage.getDecodedPayload(
                        privateKey: cosignatoryAccount1.keyPair.privateKey,
                        publicKey: account.keyPair.publicKey),
                encoding: .utf8))
    }


    func announceAndValidateTransaction(_ signedTransaction: SignedTransaction, _ address: Address) {
        let confirmedObservable = listener.confirmed(address: address)

        _ = try! transactionHttp.announce(signedTransaction: signedTransaction).toBlocking().first()!

        let transaction = try! confirmedObservable.toBlocking().first()!

        XCTAssertEqual(signedTransaction.hash, transaction.transactionInfo!.hash!)
    }

    func announceAndValidateAggregateBondedTransaction(_ signedTransaction: SignedTransaction, _ address: Address) -> AggregateTransaction{
        let aggregateTransactionObservable = listener.aggregateBondedAdded(address: address)

        _ = try! transactionHttp.announceAggregateBonded(signedTransaction: signedTransaction).toBlocking().first()!

        let aggregateTransaction = try! aggregateTransactionObservable.toBlocking().first()!
        XCTAssertEqual(signedTransaction.hash, aggregateTransaction.transactionInfo!.hash!)

        return aggregateTransaction
    }

    func announceAndValidateAggregateBondedCosignatureTransaction(_ cosignatureSignedTransaction: CosignatureSignedTransaction, _ address: Address) {
        let cosignatureObservable = listener.cosignatureAdded(address: address)

        // wait monitoring
        sleep(1)

        _ = try! transactionHttp.announceAggregateBondedCosignature(cosignatureSignedTransaction: cosignatureSignedTransaction).toBlocking().first()!

        let cosignature = try! cosignatureObservable.toBlocking().first()!
        XCTAssertEqual(cosignature.parentHash, cosignatureSignedTransaction.parentHash)

    }


    private func watchConfirmed(_ address: Address) {
        listener.confirmed(address: address).subscribe(
                onNext: { transaction in
                    print("Confirmed \(address.pretty) \(transaction.type)")
                }
        ).disposed(by: disposeBag)
    }

    private func watchUnconfirmed(_ address: Address) {
        listener.unconfirmedAdded(address: address).subscribe(
                onNext: { transaction in
                    print("Unconfirmed \(address.pretty) \(transaction.type)")
                }
        ).disposed(by: disposeBag)
    }


    private func watchBondedAdded(_ address: Address) {
        listener.aggregateBondedAdded(address: address).subscribe(
                onNext: { transaction in
                    print("Bonded Added \(address.pretty) \(transaction.type)")
                }
        ).disposed(by: disposeBag)
    }


    private func watchTransactionError(_ address: Address) {
        listener.status(address: address).subscribe(
                onNext: { status in
                    print(status.status)
                }
        ).disposed(by: disposeBag)
    }
}


