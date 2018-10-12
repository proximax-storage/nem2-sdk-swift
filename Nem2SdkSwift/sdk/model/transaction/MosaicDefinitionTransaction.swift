// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/**
 * Before a mosaic can be created or transferred, a corresponding definition of the mosaic has to be created and published to the network.
 * This is done via a mosaic definition transaction.
 */
public class MosaicDefinitionTransaction: Transaction {
    // MARK: Properties
    /// Mosaic name.
    public let mosaicName: String
    /// Mosaic id generated from namespace name and mosaic name.
    public let mosaicId: MosaicId
    /// Namespace id generated from namespace name.
    public let namespaceId: NamespaceId
    /// Mosaic properties defining mosaic.
    public let mosaicProperties: MosaicProperties

    // MARK: Methods
    init(base: Transaction,
         mosaicName: String,
         mosaicId: MosaicId,
         namespaceId: NamespaceId,
         mosaicProperties: MosaicProperties) {

        self.mosaicName = mosaicName
        self.mosaicId = mosaicId
        self.namespaceId = namespaceId
        self.mosaicProperties = mosaicProperties

        super.init(base: base)
    }


    /**
     * Create a mosaic creation transaction object.
     *
     * - parameter mosaicName:        Mosaic name ex: xem.
     * - parameter namespaceFullName: Namespace where mosaic will be included ex: nem.
     * - parameter mosaicProperties:  Mosaic properties.
     * - parameter networkType:       Network type.
     * - parameter deadline:          Deadline to include the transaction.(Optional. The default is 1 hour from now.)
     * - returns: MosaicDefinitionTransaction
     */
    public static func create(
            mosaicName: String,
            namespaceFullName: String,
            mosaicProperties: MosaicProperties,
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60)) throws -> MosaicDefinitionTransaction {

        let mosaicId = try MosaicId(fullName: namespaceFullName + ":" + mosaicName)
        let namespaceId = try NamespaceId(fullName: namespaceFullName)

        let base = Transaction(type: .mosaicDefinition, networkType: networkType, version: 2, deadline: deadline)
        return MosaicDefinitionTransaction(base: base, mosaicName: mosaicName, mosaicId: mosaicId, namespaceId: namespaceId, mosaicProperties: mosaicProperties)
    }

    override func getTransactionBodyBytes() -> [UInt8] {
        let flags: UInt8 = (self.mosaicProperties.isSupplyMutable ? 0x01 : 0x00) +
                (self.mosaicProperties.isTransferable ? 0x02 : 0x00) +
                (self.mosaicProperties.isLevyMutable ? 0x04 : 0x00)

        let nameBytes = Array(self.mosaicName.utf8)

        var bytes = self.namespaceId.id.bytes // namespace id 8 bytes
        bytes += self.mosaicId.id.bytes // mosaic id  8 bytes
        bytes += UInt8(nameBytes.count).bytes // mosaic name length 1 byte
        bytes += UInt8(1).bytes  // property count 1 byte
        bytes += flags.bytes // flag 1 byte
        bytes += UInt8(self.mosaicProperties.divisibility).bytes // divisibility 1 byte
        bytes += nameBytes // mosaic name(UTF8)
        bytes += UInt8(2).bytes // indicate duration 1 byte
        bytes += mosaicProperties.duration.bytes // // duration 8 byte

        return bytes
    }
}
