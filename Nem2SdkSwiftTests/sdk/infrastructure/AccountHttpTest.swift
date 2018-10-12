// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import RxBlocking
import XCTest
//@testable import Nem2SdkSwift
import Nem2SdkSwift

class AccountHttpTest: XCTestCase {
    var accountHttp: AccountHttp!
    let publicAccount = try! PublicAccount(publicKeyHexString: TestSettings.testPublicKey, networkType: .mijinTest)

    override func setUp() {
        super.setUp()
        accountHttp = AccountHttp(url: TestSettings.url)
    }

    func testGetAccountInfo() {
        let accountInfo: AccountInfo = try! accountHttp.getAccountInfo(address: try! Address(rawAddress: TestSettings.testAddress)).toBlocking().first()!

        XCTAssertEqual(TestSettings.testPublicKey, accountInfo.publicKey)
    }


    func testGetAccountsInfo() {
        let accountInfos: [AccountInfo] = try! accountHttp.getAccountsInfo(addresses: [try! Address(rawAddress: TestSettings.testAddress)]).toBlocking().first()!


        XCTAssertEqual(1, accountInfos.count)
        XCTAssertEqual(TestSettings.testPublicKey, accountInfos[0].publicKey)
    }

    func testGetMultisigAccountInfo() {
        let multisigInfo: MultisigAccountInfo = try! accountHttp.getMultisigAccountInfo(address: try! Address(rawAddress: TestSettings.multisigAddress)).toBlocking().first()!
        print(multisigInfo)
        XCTAssertEqual(TestSettings.multisigPublicKey, multisigInfo.account.publicKey.description)
    }


    func testGetMultisigAccountGraphInfo() {
        let signerDAddress = try! Address(rawAddress: TestSettings.signerDAddress)
        let signerBAddress = try! Address(rawAddress: TestSettings.signerBAddress)
        let signerCAddress = try! Address(rawAddress: TestSettings.signerCAddress)
        let signerAAddress = try! Address(rawAddress: TestSettings.signerAAddress)
        let signerDInfo: MultisigAccountGraphInfo = try! accountHttp.getMultisigAccountGraphInfo(address: signerDAddress).toBlocking().first()!
        let signerCInfo: MultisigAccountGraphInfo = try! accountHttp.getMultisigAccountGraphInfo(address: signerCAddress).toBlocking().first()!
        let signerBInfo: MultisigAccountGraphInfo = try! accountHttp.getMultisigAccountGraphInfo(address: signerBAddress).toBlocking().first()!
        let signerAInfo: MultisigAccountGraphInfo = try! accountHttp.getMultisigAccountGraphInfo(address: signerAAddress).toBlocking().first()!


        // signerA is cosigner of signerB
        // A(0) -> B(-1) -> C(-2) -> D(-3)
        XCTAssertEqual(Set<Int>([0, -1, -2, -3]) , signerAInfo.levelsNumber)
        signerAInfo.multisigAccounts.forEach { key, value in  XCTAssertEqual(1, value.count)}
        XCTAssertEqual(signerAAddress.plain, signerAInfo.multisigAccounts[0]?[0].account.address.plain)
        XCTAssertEqual(signerBAddress.plain, signerAInfo.multisigAccounts[-1]?[0].account.address.plain)
        XCTAssertEqual(signerCAddress.plain, signerAInfo.multisigAccounts[-2]?[0].account.address.plain)
        XCTAssertEqual(signerDAddress.plain, signerAInfo.multisigAccounts[-3]?[0].account.address.plain)

        // signerB is cosigner of signerC
        // A(1) -> B(0) -> C(-1) -> D(-2)
        XCTAssertEqual(Set<Int>([1, 0, -1, -2]) , signerBInfo.levelsNumber)
        signerBInfo.multisigAccounts.forEach { key, value in  XCTAssertEqual(1, value.count)}
        XCTAssertEqual(signerAAddress.plain, signerBInfo.multisigAccounts[1]?[0].account.address.plain)
        XCTAssertEqual(signerBAddress.plain, signerBInfo.multisigAccounts[0]?[0].account.address.plain)
        XCTAssertEqual(signerCAddress.plain, signerBInfo.multisigAccounts[-1]?[0].account.address.plain)
        XCTAssertEqual(signerDAddress.plain, signerBInfo.multisigAccounts[-2]?[0].account.address.plain)

        // signerC is cosigner of signerD
        // A(2) -> B(1) -> C(0) -> D(-1)
        XCTAssertEqual(Set<Int>([2, 1, 0, -1]) , signerCInfo.levelsNumber)
        signerCInfo.multisigAccounts.forEach { key, value in  XCTAssertEqual(1, value.count)}
        XCTAssertEqual(signerAAddress.plain, signerCInfo.multisigAccounts[2]?[0].account.address.plain)
        XCTAssertEqual(signerBAddress.plain, signerCInfo.multisigAccounts[1]?[0].account.address.plain)
        XCTAssertEqual(signerCAddress.plain, signerCInfo.multisigAccounts[0]?[0].account.address.plain)
        XCTAssertEqual(signerDAddress.plain, signerCInfo.multisigAccounts[-1]?[0].account.address.plain)

        // signerD is multisig address, and cosigner of nobody
        // A(3) -> B(2) -> C(1) -> D(0)
        XCTAssertEqual(Set<Int>([3, 2, 1, 0]) , signerDInfo.levelsNumber)
        signerDInfo.multisigAccounts.forEach { key, value in  XCTAssertEqual(1, value.count)}
        XCTAssertEqual(signerAAddress.plain, signerDInfo.multisigAccounts[3]?[0].account.address.plain)
        XCTAssertEqual(signerBAddress.plain, signerDInfo.multisigAccounts[2]?[0].account.address.plain)
        XCTAssertEqual(signerCAddress.plain, signerDInfo.multisigAccounts[1]?[0].account.address.plain)
        XCTAssertEqual(signerDAddress.plain, signerDInfo.multisigAccounts[0]?[0].account.address.plain)
    }

    func testTransactions() {
        let transactions = try! accountHttp.transactions(publicAccount: publicAccount).toBlocking().first()!

        XCTAssertEqual(10, transactions.count)
    }

    func testTransactionsWithPagination() {
        let transactions: [Transaction] = try! accountHttp.transactions(publicAccount: publicAccount).toBlocking().first()!

        XCTAssertEqual(10, transactions.count)

        let nextTransactions: [Transaction] = try! accountHttp.transactions(publicAccount: publicAccount, pageSize: 11, id: transactions[0].transactionInfo!.id!).toBlocking().first()!

        XCTAssertEqual(11, nextTransactions.count)
        XCTAssertEqual(transactions[1].transactionInfo!.hash!, nextTransactions[0].transactionInfo!.hash!)
    }


    func testIncomingTransactions() {
        let transactions = try! accountHttp.incomingTransactions(publicAccount: publicAccount).toBlocking().first()!

        XCTAssertEqual(10, transactions.count)
    }

    func testOutgoingTransactions() {
        let transactions = try! accountHttp.outgoingTransactions(publicAccount: publicAccount).toBlocking().first()!

        XCTAssertEqual(10, transactions.count)
    }

    func testAggregateBondedTransactions() {
        let transactions = try! accountHttp.aggregateBondedTransactions(publicAccount: publicAccount).toBlocking().first()!
        XCTAssertEqual(0, transactions.count)
    }

    func testUnconfirmedTransactions() {
        let transactions = try! accountHttp.unconfirmedTransactions(publicAccount: publicAccount).toBlocking().first()!
        XCTAssertEqual(0, transactions.count)
    }

    func testThrowExceptionWhenBlockDoesNotExists() {
        TestUtils.expectResponseError(code: 404) {
            _ = try accountHttp.getAccountInfo(address: try Address(rawAddress: "SARDGFTDLLCB67D4HPGIMIHPNSRYRJRT7DOBGWZY")).toBlocking().first()
        }
    }

}