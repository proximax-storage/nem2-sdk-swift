// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

class TransactionMapping {
    static func apply(_ dictionary: AnyObjectDictionary) throws -> Transaction {
        guard case .object(let object) = dictionary else {
            throw Nem2SdkSwiftError.parseError("Failed to parse transaction.")
        }

        let meta = try object.getDictionary("meta")
        let transaction = try object.getDictionary("transaction")

        return try apply(meta, transaction)
    }

    static func apply(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> Transaction {
        let type: TransactionType = try transaction.getEnum("type")

        switch type {
        case .aggregateComplete, .aggregateBonded: return try getAggregate(meta, transaction)
        case .mosaicDefinition: return try getMosaicDefinition(meta, transaction)
        case .mosaicSupplyChange: return try getMosaicSupplyChange(meta, transaction)
        case .modifyMultisigAccount: return try getModifyMultisigAccount(meta, transaction)
        case .registerNamespace: return try getRegisterNamespace(meta, transaction)
        case .transfer: return try getTransfer(meta, transaction)
        case .lock: return try getLockFunds(meta, transaction)
        case .secretLock: return try getSecretLock(meta, transaction)
        case .secretProof: return try getSecretProof(meta, transaction)
        }
    }

    static func getBase(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> Transaction {
        let type: TransactionType = try transaction.getEnum("type")
        let versionAndNetwork = try transaction.getInt("version")
        let version = UInt8(versionAndNetwork & 0xFF)
        let networkValue = UInt8((versionAndNetwork >> 8) & 0xFF)
        guard let network = NetworkType(rawValue: networkValue) else {
            throw Nem2SdkSwiftError.parseError("Unknown network \(networkValue).")
        }

        let hash = try? meta.getString("hash")
        let id = try? meta.getString("id")
        let aggregateHash = try? meta.getString("aggregateHash")

        let transactionInfo: TransactionInfo
        if (hash != nil && id != nil) {
            transactionInfo = TransactionInfo.create(
                    height: try meta.getUInt64("height"),
                    index: Int(try meta.getInt("index")),
                    id: id!,
                    hash: try HexEncoder.toBytes(hash!),
                    merkleComponentHash: try HexEncoder.toBytes(try meta.getString("merkleComponentHash")))
        } else if aggregateHash != nil && id != nil {
            transactionInfo = TransactionInfo.createAggregate(
                    height: try meta.getUInt64("height"),
                    index: Int(try meta.getInt("index")),
                    id: id!,
                    aggregateHash: try HexEncoder.toBytes(aggregateHash!),
                    aggregateId: try! meta.getString("aggregateId"))
        } else {
            transactionInfo = TransactionInfo.create(
                    height: try meta.getUInt64("height"),
                    hash: try HexEncoder.toBytes(try meta.getString("hash")),
                    merkleComponentHash: try HexEncoder.toBytes(try meta.getString("merkleComponentHash")))
        }

        return Transaction(
                type: type,
                networkType: network,
                version: version,
                deadline: Deadline(fromNemesis: TimeInterval(try transaction.getUInt64("deadline")) / 1000.0),
                fee: try transaction.getUInt64("fee"),
                signature: try transaction.getString("signature"),
                signer: try PublicAccount(publicKeyHexString: try transaction.getString("signer"), networkType: network),
                transactionInfo: transactionInfo)
    }

    static func getAggregate(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> AggregateTransaction {
        let baseTransaction = try getBase(meta, transaction)
        let innerTransactions = try transaction.getArrayOfDictionary("transactions").map { (innerTransaction: [String: AnyObjectDictionary]) -> Transaction in
            var innerTransactionObject = try innerTransaction.getDictionary("transaction")
            // copy deadline, fee, signature to inner transaction.
            ["deadline", "fee", "signature"].forEach {innerTransactionObject[$0] = transaction[$0]}
            return try TransactionMapping.apply((try? innerTransaction.getDictionary("meta")) ?? meta, innerTransactionObject)
        }

        let cosignatures = try (try? transaction.getArrayOfDictionary("cosignatures"))?.map { (aggregateCosignature: [String: AnyObjectDictionary]) -> AggregateTransactionCosignature in
            return AggregateTransactionCosignature(
                    signature: try HexEncoder.toBytes(aggregateCosignature.getString("signature")),
                    signer: try PublicAccount(publicKeyHexString: aggregateCosignature.getString("signer"), networkType: baseTransaction.networkType))
        } ?? []

        return AggregateTransaction(
                base: baseTransaction,
                innerTransactions: innerTransactions,
                cosignatures: cosignatures)
    }

    static func getMosaicDefinition(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> MosaicDefinitionTransaction {
        let properties = try transaction.getArrayOfDictionary("properties")
        let flags = try properties[0].getArrayOfInt("value")[0]

        let mosaicProperties = MosaicProperties(
                isSupplyMutable: (flags & 0x01) != 0,
                isTransferable: (flags & 0x02) != 0,
                isLevyMutable: (flags & 0x04) != 0,
                divisibility: Int(try properties[1].getArrayOfInt("value")[0]),
                duration: properties.count > 2 ? (try properties[2].getUInt64("value")) : 0)

        return MosaicDefinitionTransaction(
                base: try getBase(meta, transaction),
                mosaicName: try transaction.getString("name"),
                mosaicId: MosaicId(id: try transaction.getUInt64("mosaicId")),
                namespaceId: NamespaceId(id: try transaction.getUInt64("parentId")),
                mosaicProperties: mosaicProperties)
    }

    static func getMosaicSupplyChange(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> MosaicSupplyChangeTransaction {
        return MosaicSupplyChangeTransaction(
                base: try getBase(meta, transaction),
                mosaicId: MosaicId(id: try transaction.getUInt64("mosaicId")),
                mosaicSupplyType: try transaction.getEnum("direction"),
                delta: try transaction.getUInt64("delta"))
    }

    static func getModifyMultisigAccount(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> ModifyMultisigAccountTransaction {
        let base = try getBase(meta, transaction)
        let modifications: [MultisigCosignatoryModification] = try (try? transaction.getArrayOfDictionary("modifications"))?.map { modification in
            return MultisigCosignatoryModification(
                    type: try modification.getEnum("type"),
                    cosignatory: try PublicAccount(publicKeyHexString: try modification.getString("cosignatoryPublicKey"), networkType: base.networkType))
        } ?? []

        return ModifyMultisigAccountTransaction(
                base: try getBase(meta, transaction),
                minApprovalDelta: Int8(try transaction.getInt("minApprovalDelta")),
                minRemovalDelta: Int8(try transaction.getInt("minRemovalDelta")),
                modifications: modifications)
    }

    static func getRegisterNamespace(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> RegisterNamespaceTransaction {
        let namespaceType: NamespaceType = try transaction.getEnum("namespaceType")

        return RegisterNamespaceTransaction(
                base: try getBase(meta, transaction),
                namespaceName: try transaction.getString("name"),
                namespaceId: NamespaceId(id: try transaction.getUInt64("namespaceId")),
                namespaceType: namespaceType,
                duration: namespaceType == .rootNamespace ? try transaction.getUInt64("duration") : nil,
                parentId: namespaceType == .subNamespace ? NamespaceId(id: try transaction.getUInt64("parentId")) : nil)
    }

    static func getTransfer(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> TransferTransaction{
        let mosaics = try (try? transaction.getArrayOfDictionary("mosaics"))?.map { mosaicJson in
            Mosaic(id: MosaicId(id: try mosaicJson.getUInt64("id")), amount: try mosaicJson.getUInt64("amount"))
        } ?? []

        let message: Message?
        if let messageJson = try? transaction.getDictionary("message") {
            let messageType: MessageType = try messageJson.getEnum("type")
            let payload = try HexEncoder.toBytes(try messageJson.getString("payload"))

            switch messageType {
            case .plain: message = PlainMessage(payload: payload)
            case .secure: message = SecureMessage(encodedPayload: payload)
            }
        } else {
            message = nil
        }

        return TransferTransaction(
                base: try getBase(meta, transaction),
                recipient: try Address(encodedAddress: try transaction.getString("recipient")),
                mosaics: mosaics,
                message: message)
    }

    static func getLockFunds(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> LockFundsTransaction {
        let mosaic: Mosaic
        if transaction["mosaicId"] != nil {
            mosaic = Mosaic(id: MosaicId(id: try transaction.getUInt64("mosaicId")), amount: try transaction.getUInt64("amount"))
        } else {
            let mosaicObject = try transaction.getDictionary("mosaic")
            mosaic = Mosaic(id: MosaicId(id: try mosaicObject.getUInt64("id")), amount: try mosaicObject.getUInt64("amount"))
        }
        return LockFundsTransaction(
                base: try getBase(meta, transaction),
                mosaic: mosaic,
                duration: try transaction.getUInt64("duration"),
                signedTransaction: SignedTransaction(payload: [], hash: try HexEncoder.toBytes(try transaction.getString("hash")), type: .aggregateBonded))
    }

    static func getSecretLock(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> SecretLockTransaction {
        let mosaic: Mosaic
        if transaction["mosaicId"] != nil {
            mosaic = Mosaic(id: MosaicId(id: try transaction.getUInt64("mosaicId")), amount: try transaction.getUInt64("amount"))
        } else {
            let mosaicObject = try transaction.getDictionary("mosaic")
            mosaic = Mosaic(id: MosaicId(id: try mosaicObject.getUInt64("id")), amount: try mosaicObject.getUInt64("amount"))
        }

        return SecretLockTransaction(
                base: try getBase(meta, transaction),
                mosaic: mosaic,
                duration: try transaction.getUInt64("duration"),
                hashType: try transaction.getEnum("hashAlgorithm"),
                secret: try HexEncoder.toBytes(transaction.getString("secret")),
                recipient: try Address(encodedAddress: try transaction.getString("recipient")))
    }

    static func getSecretProof(_ meta: [String: AnyObjectDictionary], _ transaction: [String: AnyObjectDictionary]) throws -> SecretProofTransaction {
        return SecretProofTransaction(
                base: try getBase(meta, transaction),
                hashType: try transaction.getEnum("hashAlgorithm"),
                secret: try HexEncoder.toBytes(transaction.getString("secret")),
                proof: try HexEncoder.toBytes(transaction.getString("proof")))
    }
}


extension Array where Element == AnyObjectDictionary {
    private func getObject(_ index: Int) throws -> AnyObjectDictionary{
        guard index < self.count else {
            throw Nem2SdkSwiftError.parseError("Index \(index) is out of bounds")
        }
        return self[index]
    }

    func getInt(_ index: Int) throws -> Int64 {
        guard case .integer(let value) = try getObject(index) else {
            throw Nem2SdkSwiftError.parseError("Failed to parse array element as integer.")
        }
        return value
    }

    func getArray(_ index: Int) throws -> [AnyObjectDictionary] {
        guard case .array(let value) = try getObject(index) else {
            throw Nem2SdkSwiftError.parseError("Failed to parse array element as array.")
        }
        return value
    }

    func getDictionary(_ index: Int) throws -> [String: AnyObjectDictionary] {
        guard case .object(let value) = try getObject(index) else {
            throw Nem2SdkSwiftError.parseError("Failed to parse array element as dictionary.")
        }
        return value
    }

    func getUInt64(_ index: Int) throws -> UInt64 {
        let array = try getArray(index)
        guard array.count != 2 else {
            throw Nem2SdkSwiftError.parseError("Failed to parse array element as uint64")
        }
        let lower = try array.getInt(0)
        let higher = try array.getInt(1)
        return UInt64(UInt32(higher) << 32) + UInt64(UInt32(lower))
    }
}

extension Dictionary where Key == String, Value == AnyObjectDictionary {
    func getInt(_ key: String) throws -> Int64 {
        guard let valueObject = self[key],
              case .integer(let value) = valueObject else {
            throw Nem2SdkSwiftError.parseError("Failed to parse \(key)")
        }
        return value
    }

    func getString(_ key: String) throws -> String {
        guard let valueObject = self[key],
              case .string(let value) = valueObject else {
            throw Nem2SdkSwiftError.parseError("Failed to parse \(key)")
        }
        return value
    }

    func getArray(_ key: String) throws -> [AnyObjectDictionary] {
        guard let valueObject = self[key],
              case .array(let value) = valueObject else {
            throw Nem2SdkSwiftError.parseError("Failed to parse \(key)")
        }
        return value
    }

    func getDictionary(_ key: String) throws -> [String: AnyObjectDictionary] {
        guard let valueObject = self[key],
              case .object(let value) = valueObject else {
            throw Nem2SdkSwiftError.parseError("Failed to parse \(key)")
        }
        return value
    }

    func getArrayOfInt(_ key: String) throws -> [Int64] {
        let array = try getArray(key)
        return try array.enumerated().map { index, _ in try array.getInt(index) }
    }


    func getArrayOfDictionary(_ key: String) throws -> [[String: AnyObjectDictionary]] {
        let array = try getArray(key)
        return try array.enumerated().map { index, _ in try array.getDictionary(index) }
    }


    func getUInt64(_ key: String) throws -> UInt64 {
        let array = try getArray(key)
        guard array.count == 2 else {
            throw Nem2SdkSwiftError.parseError("Failed to parse \(key) as uint64")
        }

        let lower = try array.getInt(0)
        let higher = try array.getInt(1)

        return UInt64(UInt32(higher)) << 32 + UInt64(UInt32(lower))
    }

    func getEnum<T: RawRepresentable>(_ key: String) throws -> T where T.RawValue : FixedWidthInteger{
        let rawValue = try getInt(key)

        guard let value = T(rawValue: T.RawValue(clamping: rawValue)) else {
            throw Nem2SdkSwiftError.parseError("\(rawValue) is unknown value as \(String(describing: T.self)).")
        }
        return value
    }
}