// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/**
 * In case a mosaic has the flag 'supplyMutable' set to true, the creator of the mosaic can change the supply,
 * i.e. increase or decrease the supply.
 */
public class MosaicSupplyChangeTransaction: Transaction {
    // MARK: Properties
    /// Mosaic id.
    public let mosaicId: MosaicId
    /// Mosaic supply type.
    public let mosaicSupplyType: MosaicSupplyType
    /// Amount of mosaics added or removed.
    public let delta: UInt64

    // MARK: Methods
    init(base: Transaction,
         mosaicId: MosaicId,
         mosaicSupplyType: MosaicSupplyType,
         delta: UInt64) {

        self.mosaicId = mosaicId
        self.mosaicSupplyType = mosaicSupplyType
        self.delta = delta

        super.init(base: base)
    }

    /**
     * Create a mosaic supply change transaction object.
     *
     * - parameter mosaicId:         Mosaic id.
     * - parameter mosaicSupplyType: Supply type.
     * - parameter delta:            Supply change in units for the mosaic.
     * - parameter networkType:      Network type.
     * - parameter deadline:         Deadline to include the transaction.
     * - returns: MosaicSupplyChangeTransaction
     */
    public static func create(
            mosaicId: MosaicId,
            mosaicSupplyType: MosaicSupplyType,
            delta: UInt64,
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60)) -> MosaicSupplyChangeTransaction {
        let base = Transaction(type: .mosaicSupplyChange, networkType: networkType, version: 2, deadline: deadline)
        return MosaicSupplyChangeTransaction(base: base, mosaicId: mosaicId, mosaicSupplyType: mosaicSupplyType, delta: delta)
    }

    override func getTransactionBodyBytes() -> [UInt8] {
        return self.mosaicId.id.bytes + // id 8 bytes
                self.mosaicSupplyType.rawValue.bytes + // direction 1 byte
                self.delta.bytes // amount delta 8 bytes
    }
}
