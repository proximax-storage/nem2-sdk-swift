// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/**
 * A mosaic describes an instance of a mosaic definition.
 * Mosaics can be transferred by means of a transfer transaction.
 */
public struct Mosaic {
    /// Mosaic identifier
    public let id: MosaicId
    /// Amount of mosaic
    public let amount: UInt64

    /// :nodoc:
    public init(id: MosaicId, amount: UInt64) {
        self.id = id
        self.amount = amount
    }
}
