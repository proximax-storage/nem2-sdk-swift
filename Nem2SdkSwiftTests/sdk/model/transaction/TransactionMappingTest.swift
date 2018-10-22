// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

private extension UInt64 {
    var separated: String {
        return "[\(self & 0xFFFFFFFF),\((self >> 32) & 0xFFFFFFFF)]"
    }
}

public class TransactionMappingTest: XCTestCase {
    let commonHash = "18C036C20B32348D63684E09A13128A2C18F6A75650D3A5FB43853D716E5E219".toBytesFromHexString()!
    let commonHeight: UInt64 = 0x01
    let commonId = "59FDA0733F17CF0001772CA7"
    let commonIndex = 19
    let commonMerkleComponentHash = "18C036C20B32348D63684E09A13128A2C18F6A75650D3A5FB43853D716E5E219".toBytesFromHexString()!
    let commonDeadline: UInt64 = 10000
    let commonFee: UInt64 = 0
    let commonSignature = "553E696EB4A54E43A11D180EBA57E4B89D0048C9DD2604A9E0608120018B9E02F6EE63025FEEBCED3293B622AF8581334D0BDAB7541A9E7411E7EE4EF0BC5D0E"
    let commonSigner = "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF"
    let commonVersion: UInt16 = 36867

    let innerAggregateHash = "3D28C804EDD07D5A728E5C5FFEC01AB07AFA5766AE6997B38526D36015A4D006".toBytesFromHexString()!
    let innerAggregateId = "5A0069D83F17CF0001777E55"
    let innerHeight: UInt64 = 18160
    let innerId = "5A0069D83F17CF0001777E56"
    let innerIndex = 0
    let innerSigner = "B4F12E7C9F6946091E2CB8B6D3A12B50D17CCBBF646386EA27CE2946A7423DCF"
    let innerVersion: UInt16 = 36867

    func createDto(_ type: UInt16, _ customFields: String) -> String{
        return """
        {
          "meta": {
            "hash":"\(commonHash.hexString.uppercased())",
            "height":\(commonHeight.separated),
            "id":"\(commonId)",
            "index":\(commonIndex),
            "merkleComponentHash":"\(commonMerkleComponentHash.hexString.uppercased())"
          },
          "transaction": {
            "deadline":\(commonDeadline.separated),
            "fee": \(commonFee.separated),
            "signature": "\(commonSignature)",
            "signer": "\(commonSigner)",
            "type": \(type),
            "version": \(commonVersion),
            \(customFields)
          }
        }
"""
    }


    func decode<T: Transaction> (_ dtoString: String) -> T{
        let decoder = JSONDecoder()
        let dto = try! decoder.decode(AnyObjectDictionary.self, from: dtoString.data(using: .utf8)!)
        let transaction = try! TransactionMapping.apply(dto)
        return transaction as! T
    }

    func validateCommonFields(_ type: UInt16, _ transaction: Transaction) {
        XCTAssertEqual(commonHash, transaction.transactionInfo?.hash)
        XCTAssertEqual(commonHeight, transaction.transactionInfo?.height)
        XCTAssertEqual(commonId, transaction.transactionInfo?.id)
        XCTAssertEqual(commonIndex, transaction.transactionInfo?.index)
        XCTAssertEqual(commonMerkleComponentHash, transaction.transactionInfo?.merkleComponentHash)
        XCTAssertEqual(commonDeadline, transaction.deadline.timestamp)
        XCTAssertEqual(commonFee, transaction.fee)
        XCTAssertEqual(commonSignature, transaction.signature!)
        XCTAssertEqual(commonSigner, transaction.signer!.publicKey.description)
        XCTAssertEqual(type, transaction.type.rawValue)
        XCTAssertEqual(commonVersion, UInt16(transaction.networkType.rawValue) << 8 + UInt16(transaction.version))
    }

    func createAggregateDto(_ type: UInt16, _ customFields: String) -> String {
        return """
        {
          "meta": {
            "hash":"\(commonHash.hexString.uppercased())",
            "height":\(commonHeight.separated),
            "id":"\(commonId)",
            "index":\(commonIndex),
            "merkleComponentHash":"\(commonMerkleComponentHash.hexString.uppercased())"
          },
          "transaction": {
            "cosignatures": [
              {
                "signature":"5780C8DF9D46BA2BCF029DCC5D3BF55FE1CB5BE7ABCF30387C4637DDEDFC2152703CA0AD95F21BB9B942F3CC52FCFC2064C7B84CF60D1A9E69195F1943156C07",
                "signer":"A5F82EC8EBB341427B6785C8111906CD0DF18838FB11B51CE0E18B5E79DFF630"
              }
            ],
            "deadline":\(commonDeadline.separated),
            "fee": \(commonFee.separated),
            "signature": "\(commonSignature)",
            "signer": "\(commonSigner)",
            "transactions": [
              {
                "meta": {
                  "aggregateHash":"\(innerAggregateHash.hexString.uppercased())",
                  "aggregateId":"\(innerAggregateId)",
                  "height":\(innerHeight.separated),
                  "id":"\(innerId)",
                  "index": \(innerIndex)
                },
                "transaction": {
                  "signer":"\(innerSigner)",
                  "type":\(type),
                  "version": \(innerVersion),
                  \(customFields)
                }
              }
            ],
            "type":16705,
            "version": \(commonVersion),
          }
        }
"""
    }

    func validateAggregateFields(_ type: UInt16, _ transaction: AggregateTransaction) {
        XCTAssertEqual(commonHash, transaction.transactionInfo?.hash)
        XCTAssertEqual(commonHeight, transaction.transactionInfo?.height)
        XCTAssertEqual(commonId, transaction.transactionInfo?.id)
        XCTAssertEqual(commonIndex, transaction.transactionInfo?.index)
        XCTAssertEqual(commonMerkleComponentHash, transaction.transactionInfo?.merkleComponentHash)
        XCTAssertEqual(commonDeadline, transaction.deadline.timestamp)
        XCTAssertEqual(commonFee, transaction.fee)
        XCTAssertEqual(commonSignature, transaction.signature!)
        XCTAssertEqual(commonSigner, transaction.signer!.publicKey.description)
        XCTAssertEqual(TransactionType.aggregateComplete, transaction.type)
        XCTAssertEqual(commonVersion, UInt16(transaction.networkType.rawValue) << 8 + UInt16(transaction.version))

        XCTAssertEqual(1, transaction.innerTransactions.count)

        let innerTransaction = transaction.innerTransactions[0]

        XCTAssertEqual(innerAggregateHash, innerTransaction.transactionInfo!.aggregateHash)
        XCTAssertEqual(innerAggregateId, innerTransaction.transactionInfo!.aggregateId)
        XCTAssertEqual(innerHeight, innerTransaction.transactionInfo!.height)
        XCTAssertEqual(innerId, innerTransaction.transactionInfo!.id)
        XCTAssertEqual(innerSigner, innerTransaction.signer?.publicKey.description)
        XCTAssertEqual(innerVersion, UInt16(innerTransaction.networkType.rawValue) << 8 + UInt16(innerTransaction.version))
        XCTAssertEqual(type, innerTransaction.type.rawValue)
    }

    func testShouldCreateStandaloneTransferTransaction() {
        let messagePayload = "746573742D6D657373616765"
        let messageType = MessageType.plain
        let amount = "[3863990592,95248]"
        let mosaicId = "[3646934825,3576016193]"
        let recipient = "9050B9837EFAB4BBE8A4B9BB32D812F9885C00D8FC1650E142"
        let type: UInt16 = 16724
        let customFields = """
            "message": {
              "payload": "\(messagePayload)",
              "type": \(messageType.rawValue)
            },
            "mosaics": [
              {
                "amount": \(amount),
                "id": \(mosaicId)
              }
            ],
            "recipient": "\(recipient)"
"""
        let dtoString = createDto(type, customFields)
        let transaction: TransferTransaction = decode(dtoString)

        validateCommonFields(type, transaction)
        XCTAssertEqual(messagePayload, transaction.message!.payload.hexString.uppercased())
        XCTAssertEqual(messageType, transaction.message!.type)
        XCTAssertEqual(amount, transaction.mosaics[0].amount.separated)
        XCTAssertEqual(mosaicId, transaction.mosaics[0].id.id.separated)
        XCTAssertEqual(recipient, transaction.recipient.bytes.hexString.uppercased())
    }


    func testShouldCreateAggregateTransferTransaction()  {
        let messagePayload = "746573742D6D657373616765"
        let messageType = MessageType.plain
        let amount = "[3863990592,95248]"
        let mosaicId = "[3646934825,3576016193]"
        let recipient = "9050B9837EFAB4BBE8A4B9BB32D812F9885C00D8FC1650E142"
        let type: UInt16 = 16724
        let customFields = """
            "message": {
              "payload": "\(messagePayload)",
              "type": \(messageType.rawValue)
            },
            "mosaics": [
              {
                "amount": \(amount),
                "id": \(mosaicId)
              }
            ],
            "recipient": "\(recipient)"
"""
        let dtoString = createAggregateDto(type, customFields)
        let aggregate: AggregateTransaction = decode(dtoString)
        let transaction = aggregate.innerTransactions[0] as! TransferTransaction

        validateAggregateFields(type, aggregate)
        XCTAssertEqual(messagePayload, transaction.message!.payload.hexString.uppercased())
        XCTAssertEqual(messageType, transaction.message!.type)
        XCTAssertEqual(amount, transaction.mosaics[0].amount.separated)
        XCTAssertEqual(mosaicId, transaction.mosaics[0].id.id.separated)
        XCTAssertEqual(recipient, transaction.recipient.bytes.hexString.uppercased())
    }

    func testShouldCreateStandaloneRootNamespaceCreationTransaction()  {
        let type: UInt16 = 16718
        let customFields = "\"duration\":[1000,0],\"name\":\"a2p1mg\",\"namespaceId\":[437145074,4152736179],\"namespaceType\":0"
        let dtoString = createDto(type, customFields)
        let transaction: RegisterNamespaceTransaction = decode(dtoString)

        validateCommonFields(type, transaction)

        XCTAssertEqual(1000, transaction.duration!)
        XCTAssertEqual("a2p1mg", transaction.namespaceName)
        XCTAssertEqual("[437145074,4152736179]", transaction.namespaceId.id.separated)
        XCTAssertEqual(0, transaction.namespaceType.rawValue)
    }

    func testShouldCreateAggregateRootNamespaceCreationTransaction() {
        let type: UInt16 = 16718
        let customFields = "\"duration\":[1000,0],\"name\":\"a2p1mg\",\"namespaceId\":[437145074,4152736179],\"namespaceType\":0"
        let dtoString = createAggregateDto(type, customFields)
        let aggregate: AggregateTransaction = decode(dtoString)
        let transaction = aggregate.innerTransactions[0] as! RegisterNamespaceTransaction

        validateAggregateFields(type, aggregate)

        XCTAssertEqual(1000, transaction.duration!)
        XCTAssertEqual("a2p1mg", transaction.namespaceName)
        XCTAssertEqual("[437145074,4152736179]", transaction.namespaceId.id.separated)
        XCTAssertEqual(0, transaction.namespaceType.rawValue)
    }


    func testShouldCreateStandaloneSubNamespaceCreationTransaction() {
        let type: UInt16 = 16718
        let customFields = "\"name\":\"0unius\",\"namespaceId\":[1970060410,3289875941],\"namespaceType\":1,\"parentId\":[3316183705,3829351378]"
        let dtoString = createDto(type, customFields)
        let transaction: RegisterNamespaceTransaction = decode(dtoString)

        validateCommonFields(type, transaction)

        XCTAssertEqual("[3316183705,3829351378]", transaction.parentId!.id.separated)
        XCTAssertEqual("0unius", transaction.namespaceName)
        XCTAssertEqual("[1970060410,3289875941]", transaction.namespaceId.id.separated)
        XCTAssertEqual(1, transaction.namespaceType.rawValue)
    }

    func testShouldCreateAggregateSubNamespaceCreationTransaction() {
        let type: UInt16 = 16718
        let customFields = "\"name\":\"0unius\",\"namespaceId\":[1970060410,3289875941],\"namespaceType\":1,\"parentId\":[3316183705,3829351378]"
        let dtoString = createAggregateDto(type, customFields)
        let aggregate: AggregateTransaction = decode(dtoString)
        let transaction = aggregate.innerTransactions[0] as! RegisterNamespaceTransaction

        validateAggregateFields(type, aggregate)

        XCTAssertEqual("[3316183705,3829351378]", transaction.parentId!.id.separated)
        XCTAssertEqual("0unius", transaction.namespaceName)
        XCTAssertEqual("[1970060410,3289875941]", transaction.namespaceId.id.separated)
        XCTAssertEqual(1, transaction.namespaceType.rawValue)
    }

    func testShouldCreateStandaloneMosaicCreationTransaction() {
        let type: UInt16 = 16717
        let customFields = "\"mosaicId\":[3248159581,740240531],\"name\":\"ie7rfaqxiorum1jor\",\"parentId\":[3316183705,3829351378],\"properties\":[{\"id\":0,\"value\":[7,0]},{\"id\":1,\"value\":[6,0]},{\"id\":2,\"value\":[1000,0]}]"
        let dtoString = createDto(type, customFields)
        let transaction: MosaicDefinitionTransaction = decode(dtoString)

        validateCommonFields(type, transaction)

        XCTAssertEqual("[3248159581,740240531]", transaction.mosaicId.id.separated)
        XCTAssertEqual("ie7rfaqxiorum1jor", transaction.mosaicName)
        XCTAssertEqual("[3316183705,3829351378]", transaction.namespaceId.id.separated)
        XCTAssertEqual(true, transaction.mosaicProperties.isLevyMutable)
        XCTAssertEqual(true, transaction.mosaicProperties.isTransferable)
        XCTAssertEqual(true, transaction.mosaicProperties.isSupplyMutable)
        XCTAssertEqual(6, transaction.mosaicProperties.divisibility)
        XCTAssertEqual(1000, transaction.mosaicProperties.duration)
    }

    func testShouldCreateAggregateMosaicCreationTransaction() {
        let type: UInt16 = 16717
        let customFields = "\"mosaicId\":[3248159581,740240531],\"name\":\"ie7rfaqxiorum1jor\",\"parentId\":[3316183705,3829351378],\"properties\":[{\"id\":0,\"value\":[7,0]},{\"id\":1,\"value\":[6,0]},{\"id\":2,\"value\":[1000,0]}]"
        let dtoString = createAggregateDto(type, customFields)
        let aggregate: AggregateTransaction = decode(dtoString)
        let transaction = aggregate.innerTransactions[0] as! MosaicDefinitionTransaction

        validateAggregateFields(type, aggregate)

        XCTAssertEqual("[3248159581,740240531]", transaction.mosaicId.id.separated)
        XCTAssertEqual("ie7rfaqxiorum1jor", transaction.mosaicName)
        XCTAssertEqual("[3316183705,3829351378]", transaction.namespaceId.id.separated)
        XCTAssertEqual(true, transaction.mosaicProperties.isLevyMutable)
        XCTAssertEqual(true, transaction.mosaicProperties.isTransferable)
        XCTAssertEqual(true, transaction.mosaicProperties.isSupplyMutable)
        XCTAssertEqual(6, transaction.mosaicProperties.divisibility)
        XCTAssertEqual(1000, transaction.mosaicProperties.duration)

    }

    func testShouldCreateStandaloneMosaicSupplyChangeTransaction() {
        let type: UInt16 = 16973
        let customFields = "\"delta\":[100000,0],\"direction\":1,\"mosaicId\":[3070467832,2688515262]"
        let dtoString = createDto(type, customFields)
        let transaction: MosaicSupplyChangeTransaction = decode(dtoString)

        validateCommonFields(type, transaction)

        XCTAssertEqual(100000, transaction.delta)
        XCTAssertEqual(1, transaction.mosaicSupplyType.rawValue)
        XCTAssertEqual("[3070467832,2688515262]", transaction.mosaicId.id.separated)
    }

    func testShouldCreateAggregateMosaicSupplyChangeTransaction() {
        let type: UInt16 = 16973
        let customFields = "\"delta\":[100000,0],\"direction\":1,\"mosaicId\":[3070467832,2688515262]"
        let dtoString = createAggregateDto(type, customFields)
        let aggregate: AggregateTransaction = decode(dtoString)
        let transaction = aggregate.innerTransactions[0] as! MosaicSupplyChangeTransaction

        validateAggregateFields(type, aggregate)

        XCTAssertEqual(100000, transaction.delta)
        XCTAssertEqual(1, transaction.mosaicSupplyType.rawValue)
        XCTAssertEqual("[3070467832,2688515262]", transaction.mosaicId.id.separated)

    }

    func testShouldCreateStandaloneMultisigModificationTransaction() {
        let type: UInt16 = 16725
        let customFields = "\"minApprovalDelta\":1,\"minRemovalDelta\":1,\"modifications\":[{\"cosignatoryPublicKey\":\"589B73FBC22063E9AE6FBAC67CB9C6EA865EF556E5FB8B7310D45F77C1250B97\",\"type\":0}]"
        let dtoString = createDto(type, customFields)
        let transaction: ModifyMultisigAccountTransaction = decode(dtoString)

        validateCommonFields(type, transaction)

        XCTAssertEqual(1, transaction.minApprovalDelta)
        XCTAssertEqual(1, transaction.minRemovalDelta)
        XCTAssertEqual(1, transaction.modifications.count)
        XCTAssertEqual(0, transaction.modifications[0].type.rawValue)
        XCTAssertEqual("589B73FBC22063E9AE6FBAC67CB9C6EA865EF556E5FB8B7310D45F77C1250B97", transaction.modifications[0].cosignatory.publicKey.description.uppercased())
    }

    func testShouldCreateAggregateMultisigModificationTransaction() {
        let type: UInt16 = 16725
        let customFields = "\"minApprovalDelta\":1,\"minRemovalDelta\":1,\"modifications\":[{\"cosignatoryPublicKey\":\"589B73FBC22063E9AE6FBAC67CB9C6EA865EF556E5FB8B7310D45F77C1250B97\",\"type\":0}]"
        let dtoString = createAggregateDto(type, customFields)

        let aggregate: AggregateTransaction = decode(dtoString)
        let transaction = aggregate.innerTransactions[0] as! ModifyMultisigAccountTransaction

        validateAggregateFields(type, aggregate)

        XCTAssertEqual(1, transaction.minApprovalDelta)
        XCTAssertEqual(1, transaction.minRemovalDelta)
        XCTAssertEqual(1, transaction.modifications.count)
        XCTAssertEqual(0, transaction.modifications[0].type.rawValue)
        XCTAssertEqual("589B73FBC22063E9AE6FBAC67CB9C6EA865EF556E5FB8B7310D45F77C1250B97", transaction.modifications[0].cosignatory.publicKey.description.uppercased())
    }

    func testShouldCreateStandaloneLockFundsTransaction() {
        let type: UInt16 = 16716

        let customFields = "\"duration\": [100,0],\"mosaicId\": [3646934825,3576016193],\"amount\": [10000000,0], \"hash\": \"49E9F58867FB9399F32316B99CCBC301A5790E5E0605E25F127D28CEF99740A3\""
        let dtoString = createDto(type, customFields)
        let transaction: LockFundsTransaction = decode(dtoString)

        validateCommonFields(type, transaction)

        XCTAssertEqual("[3646934825,3576016193]", transaction.mosaic.id.id.separated)
        XCTAssertEqual("49E9F58867FB9399F32316B99CCBC301A5790E5E0605E25F127D28CEF99740A3", transaction.signedTransaction.hash.hexString.uppercased())
        XCTAssertEqual(10000000, transaction.mosaic.amount)
        XCTAssertEqual(100, transaction.duration)
    }

    func testShouldCreateAggregateLockFundsTransaction() {
        let type: UInt16 = 16716

        let customFields = "\"duration\": [100,0],\"mosaicId\": [3646934825,3576016193],\"amount\": [10000000,0], \"hash\": \"49E9F58867FB9399F32316B99CCBC301A5790E5E0605E25F127D28CEF99740A3\""
        let dtoString = createAggregateDto(type, customFields)
        let aggregate: AggregateTransaction = decode(dtoString)
        let transaction = aggregate.innerTransactions[0] as! LockFundsTransaction

        validateAggregateFields(type, aggregate)

        XCTAssertEqual("[3646934825,3576016193]", transaction.mosaic.id.id.separated)
        XCTAssertEqual("49E9F58867FB9399F32316B99CCBC301A5790E5E0605E25F127D28CEF99740A3", transaction.signedTransaction.hash.hexString.uppercased())
        XCTAssertEqual(10000000, transaction.mosaic.amount)
        XCTAssertEqual(100, transaction.duration)

    }

    func testShouldCreateStandaloneSecretLockTransaction() {
        let type: UInt16 = 16972
        let customFields = "\"duration\": [100,0],\"mosaicId\": [3646934825,3576016193],\"amount\": [10000000,0],\"hashAlgorithm\": 0,\"secret\": \"428A9DEB1DC6B938AD7C83617E4A558D5316489ADE176AE0C821568A2AD6F700470901532716F83D43F2A7240FBB2C34BDD9536BCF6CC7601904782C385CD8B4\",\"recipient\": \"90C9B099BAEBB743A4D2D8D3B1520F6DD0A0E9D6C9D968C155\""

        let dtoString = createDto(type, customFields)
        let transaction: SecretLockTransaction = decode(dtoString)

        validateCommonFields(type, transaction)

        XCTAssertEqual("[3646934825,3576016193]", transaction.mosaic.id.id.separated)
        XCTAssertEqual(10000000, transaction.mosaic.amount)
        XCTAssertEqual(0, transaction.hashType.rawValue)
        XCTAssertEqual(100, transaction.duration)
        XCTAssertEqual("428A9DEB1DC6B938AD7C83617E4A558D5316489ADE176AE0C821568A2AD6F700470901532716F83D43F2A7240FBB2C34BDD9536BCF6CC7601904782C385CD8B4", transaction.secret.hexString.uppercased())
        XCTAssertEqual("90C9B099BAEBB743A4D2D8D3B1520F6DD0A0E9D6C9D968C155", transaction.recipient.bytes.hexString.uppercased())
    }

    func testShouldCreateAggregateSecretLockTransaction() {
        let type: UInt16 = 16972
        let customFields = "\"duration\": [100,0],\"mosaicId\": [3646934825,3576016193],\"amount\": [10000000,0],\"hashAlgorithm\": 0,\"secret\": \"428A9DEB1DC6B938AD7C83617E4A558D5316489ADE176AE0C821568A2AD6F700470901532716F83D43F2A7240FBB2C34BDD9536BCF6CC7601904782C385CD8B4\",\"recipient\": \"90C9B099BAEBB743A4D2D8D3B1520F6DD0A0E9D6C9D968C155\""

        let dtoString = createAggregateDto(type, customFields)
        let aggregate: AggregateTransaction = decode(dtoString)
        let transaction = aggregate.innerTransactions[0] as! SecretLockTransaction

        validateAggregateFields(type, aggregate)

        XCTAssertEqual("[3646934825,3576016193]", transaction.mosaic.id.id.separated)
        XCTAssertEqual(10000000, transaction.mosaic.amount)
        XCTAssertEqual(0, transaction.hashType.rawValue)
        XCTAssertEqual(100, transaction.duration)
        XCTAssertEqual("428A9DEB1DC6B938AD7C83617E4A558D5316489ADE176AE0C821568A2AD6F700470901532716F83D43F2A7240FBB2C34BDD9536BCF6CC7601904782C385CD8B4", transaction.secret.hexString.uppercased())
        XCTAssertEqual("90C9B099BAEBB743A4D2D8D3B1520F6DD0A0E9D6C9D968C155", transaction.recipient.bytes.hexString.uppercased())

    }

    func testShouldCreateStandaloneSecretProofTransaction() {
        let type: UInt16 = 17228
        let customFields = "\"hashAlgorithm\": 0,\"secret\": \"428A9DEB1DC6B938AD7C83617E4A558D5316489ADE176AE0C821568A2AD6F700470901532716F83D43F2A7240FBB2C34BDD9536BCF6CC7601904782C385CD8B4\",\"proof\": \"E08664BF179B064D9E3B\""

        let dtoString = createDto(type, customFields)
        let transaction: SecretProofTransaction = decode(dtoString)

        validateCommonFields(type, transaction)

        XCTAssertEqual("428A9DEB1DC6B938AD7C83617E4A558D5316489ADE176AE0C821568A2AD6F700470901532716F83D43F2A7240FBB2C34BDD9536BCF6CC7601904782C385CD8B4", transaction.secret.hexString.uppercased())
        XCTAssertEqual("E08664BF179B064D9E3B", transaction.proof.hexString.uppercased())
        XCTAssertEqual(0, transaction.hashType.rawValue)
    }


    func testShouldCreateAggregateSecretProofTransaction() {
        let type: UInt16 = 17228
        let customFields = "\"hashAlgorithm\": 0,\"secret\": \"428A9DEB1DC6B938AD7C83617E4A558D5316489ADE176AE0C821568A2AD6F700470901532716F83D43F2A7240FBB2C34BDD9536BCF6CC7601904782C385CD8B4\",\"proof\": \"E08664BF179B064D9E3B\""

        let dtoString = createAggregateDto(type, customFields)
        let aggregate: AggregateTransaction = decode(dtoString)
        let transaction = aggregate.innerTransactions[0] as! SecretProofTransaction

        validateAggregateFields(type, aggregate)

        XCTAssertEqual("428A9DEB1DC6B938AD7C83617E4A558D5316489ADE176AE0C821568A2AD6F700470901532716F83D43F2A7240FBB2C34BDD9536BCF6CC7601904782C385CD8B4", transaction.secret.hexString.uppercased())
        XCTAssertEqual("E08664BF179B064D9E3B", transaction.proof.hexString.uppercased())
        XCTAssertEqual(0, transaction.hashType.rawValue)
    }
}
