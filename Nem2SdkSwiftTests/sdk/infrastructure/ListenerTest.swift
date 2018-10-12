// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import XCTest
import RxSwift
import RxBlocking
@testable import Nem2SdkSwift

class ListenerTest: XCTestCase {
    private let transactionHttp = TransactionHttp(url: TestSettings.url)
    private let accountHttp = AccountHttp(url: TestSettings.url)
    private let account = try! Account(privateKeyHexString: TestSettings.accountPrivateKey, networkType: .mijinTest)
    private let multisigAccount = try! Account(privateKeyHexString: TestSettings.multisigPrivateKey, networkType: .mijinTest)
    private let cosignatoryAccount1 = try! Account(privateKeyHexString: TestSettings.cosignatory1PrivateKey, networkType: .mijinTest)
    private let cosignatoryAccount2 = try! Account(privateKeyHexString: TestSettings.cosignatory2PrivateKey, networkType: .mijinTest)

    var listener: Listener!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        listener = Listener(url: TestSettings.url)
        disposeBag = DisposeBag()

        listener.error().subscribe(
                onNext: { error in
                    if case Nem2SdkSwiftError.parseError(let message) = error{
                        print(message)
                    } else {
                        print(error.localizedDescription)
                    }
                }
        ).disposed(by: disposeBag)
        _ = try! listener.open().toBlocking().first()
    }

    func testShouldConnectToWebSocket() {
        XCTAssertNotNil(listener.uid)
    }

    func testShouldReturnNewBlockViaListener()  {
        _ = announceStandaloneTransferTransaction()

        let blockInfo = try! listener.newBlock().toBlocking().first()!

        XCTAssertTrue(blockInfo.height > 0)
    }

    func testShouldReturnConfirmedTransactionAddressSignerViaListener() {
        let signedTransaction = announceStandaloneTransferTransaction()

        let transaction = try! listener.confirmed(address: account.address).toBlocking().first()!
        XCTAssertEqual(signedTransaction.hash, transaction.transactionInfo?.hash)
    }

    func testShouldReturnConfirmedTransactionAddressRecipientViaListener() {
        let signedTransaction = announceStandaloneTransferTransaction()

        let transaction = try! listener.confirmed(address: try! Address(rawAddress: "SBILTA367K2LX2FEXG5TFWAS7GEFYAGY7QLFBYKC")).toBlocking().first()!
        XCTAssertEqual(signedTransaction.hash, transaction.transactionInfo?.hash)
    }

    func testShouldReturnUnconfirmedAddedTransactionViaListener() {
        let signedTransaction = announceStandaloneTransferTransaction()

        let transaction = try! listener.unconfirmedAdded(address: account.address).toBlocking().first()!
        XCTAssertEqual(signedTransaction.hash, transaction.transactionInfo?.hash)
        // Wait for removing unconfirmed transaction for next test
        _ = try! listener.unconfirmedRemoved(address: account.address).toBlocking().first()!
    }

    func testShouldReturnUnconfirmedRemovedTransactionViaListener() {
        let signedTransaction = announceStandaloneTransferTransaction()

        let hash = try! listener.unconfirmedRemoved(address: account.address).toBlocking().first()!
        XCTAssertEqual(signedTransaction.hash, hash)
    }

    func testShouldReturnAggregateBondedAddedTransactionViaListener() {
        watchTransactionError(cosignatoryAccount1.address)

        guard let signedTransaction = announceAggregateBondedTransaction() else {
            XCTFail("Failed to send aggregate bonded transaction.")
            return
        }

        let aggregateTransaction = try! listener.aggregateBondedAdded(address: cosignatoryAccount1.address).toBlocking().first()!
        XCTAssertEqual(signedTransaction.hash, aggregateTransaction.transactionInfo?.hash)

        // confirm to unlock funds
        //announceCosignatureTransaction(transactionToCosign: aggregateTransaction, with: cosignatoryAccount1)
        announceCosignatureTransaction(transactionToCosign: aggregateTransaction, with: cosignatoryAccount2)
    }

    func testShouldReturnAggregateBondedRemovedTransactionViaListener()  {
        watchTransactionError(cosignatoryAccount1.address)

        guard let signedTransaction = announceAggregateBondedTransaction() else {
            XCTFail("Failed to send aggregate bonded transaction.")
            return
        }

        let aggregateTransaction = try! listener.aggregateBondedAdded(address: cosignatoryAccount1.address).toBlocking().first()!
        XCTAssertEqual(signedTransaction.hash, aggregateTransaction.transactionInfo?.hash)

        let aggregateRemoveObserver = try! listener.aggregateBondedRemoved(address: cosignatoryAccount1.address)

        // confirm
        announceCosignatureTransaction(transactionToCosign: aggregateTransaction, with: cosignatoryAccount2)

        let hash = try! aggregateRemoveObserver.toBlocking().first()!
        XCTAssertEqual(signedTransaction.hash, hash)
    }


    func testShouldReturnCosignatureAddedViaListener() {
        watchTransactionError(cosignatoryAccount1.address)

        guard let signedTransaction = announceAggregateBondedTransaction() else {
            XCTFail("Failed to send aggregate bonded transaction.")
            return
        }

        let aggregateTransaction = try! listener.aggregateBondedAdded(address: cosignatoryAccount1.address).toBlocking().first()!
        XCTAssertEqual(signedTransaction.hash, aggregateTransaction.transactionInfo?.hash)

        let cosignatureObserver = try! listener.cosignatureAdded(address: cosignatoryAccount1.address)

        // confirm
        announceCosignatureTransaction(transactionToCosign: aggregateTransaction, with: cosignatoryAccount2)

        let cosignature = try! cosignatureObserver.toBlocking().first()!

        XCTAssertEqual(cosignature.signer, cosignatoryAccount2.publicKeyBytes)
    }


    func testShouldReturnTransactionStatusGivenAddedViaListener() {
        let signedTransaction = announceStandaloneTransferTransactionWithInsufficientBalance()

        let status = try! listener.status(address: account.address).toBlocking().first()!
        XCTAssertEqual(signedTransaction.hash, status.hash)
    }

    private func watchTransactionError(_ address: Address) {
        listener.status(address: address).subscribe(
                onNext: { status in
                    print(status.status)
                }
        ).disposed(by: disposeBag)
    }


    private func announceStandaloneTransferTransaction() -> SignedTransaction {
        let transferTransaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SBILTA367K2LX2FEXG5TFWAS7GEFYAGY7QLFBYKC"),
                mosaics: [],
                message: PlainMessage.empty,
                networkType: .mijinTest
                )

        let signedTransaction = account.sign(transaction: transferTransaction)
        _ = try! transactionHttp.announce(signedTransaction: signedTransaction).toBlocking().first()!
        return signedTransaction
    }


    private func announceStandaloneTransferTransactionWithInsufficientBalance() -> SignedTransaction {
        let transferTransaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SBILTA367K2LX2FEXG5TFWAS7GEFYAGY7QLFBYKC"),
                mosaics: [XEM.of(xemAmount: 1000000)],
                message: PlainMessage(text: "test-message"),
                networkType: .mijinTest)

        let signedTransaction = account.sign(transaction: transferTransaction)
        _ = try! transactionHttp.announce(signedTransaction: signedTransaction).toBlocking().first()!
        return signedTransaction
    }

    private func announceAggregateBondedTransaction() -> SignedTransaction? {
        let transferTransaction = TransferTransaction.create(
                recipient: try! Address(rawAddress: "SBILTA367K2LX2FEXG5TFWAS7GEFYAGY7QLFBYKC"),
                mosaics: [],
                networkType: .mijinTest)

        let aggregateTransaction = try! AggregateTransaction.createBonded(
                innerTransactions: [transferTransaction.toAggregate(signer: multisigAccount.publicAccount)],
                networkType: .mijinTest)

        let signedTransaction = cosignatoryAccount1.sign(transaction: aggregateTransaction)

        // Lock funds
        let lockFundsTransaction = try! LockFundsTransaction.create(
                mosaic: XEM.of(xemAmount: 10),
                duration: 100,
                signedTransaction: signedTransaction,
                networkType: .mijinTest)

        let signedLockFundsTransaction = cosignatoryAccount1.sign(transaction: lockFundsTransaction)
        // announce lock funds
        _ = try! transactionHttp.announce(signedTransaction: signedLockFundsTransaction).toBlocking().first()!

        // wait confirmed
        let disposeBag = DisposeBag()
        let blockObserver = listener.newBlock().toBlocking()
        for i in 0..<100 {
            _ = try! blockObserver.first()!

            let transactionStatus = try! transactionHttp.getTransactionStatus(hash: signedLockFundsTransaction.hash).toBlocking().first()!
            if transactionStatus.height != nil {
                // confirmed
                break
            }
            // unconfirmed
            if transactionStatus.group == "failed" {
                // error
                return nil
            }
        }

        // announce aggregate bonded transaction
        _ = try! transactionHttp.announceAggregateBonded(signedTransaction: signedTransaction).toBlocking().first()!

        return signedTransaction
    }

    private func announceCosignatureTransaction(transactionToCosign: AggregateTransaction, with account: Account) -> CosignatureSignedTransaction {
        let cosignatureTransaction = try! CosignatureTransaction(transactionToCosign: transactionToCosign)

        let cosignatureSignedTransaction = account.sign(cosignatureTransaction: cosignatureTransaction)
        _ = try! transactionHttp.announceAggregateBondedCosignature(cosignatureSignedTransaction: cosignatureSignedTransaction).toBlocking().first()!

        return cosignatureSignedTransaction
    }
}