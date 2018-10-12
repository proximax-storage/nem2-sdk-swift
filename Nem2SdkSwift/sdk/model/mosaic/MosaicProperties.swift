// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// The mosaic properties structure describes mosaic properties.
public struct MosaicProperties {
    /// True if supply is mutable
    public let isSupplyMutable: Bool
    /// True if mosaic is transferable between non-owner accounts
    public let isTransferable: Bool
    /// True if the mosaic levy is mutable
    public let isLevyMutable: Bool
    /// Mosaic divisibility
    public let divisibility: Int
    /// Number of blocks from height it will be active
    public let duration: UInt64

    /// :nodoc:
    public init(isSupplyMutable: Bool,
                isTransferable: Bool,
                isLevyMutable: Bool,
                divisibility: Int,
                duration: UInt64) {
        self.isSupplyMutable = isSupplyMutable
        self.isTransferable = isTransferable
        self.isLevyMutable = isLevyMutable
        self.divisibility = divisibility
        self.duration = duration
    }
}
