// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// The mosaic info structure contains its properties, the owner and the namespace to which it belongs to.
public struct MosaicInfo {
    /// MARK: Properties
    /// If the mosaic is active
    public let isActive: Bool
    /// Index
    public let index: Int
    /// Meta ID
    public let metaId: String
    /// The namespace id it belongs to
    public let namespaceId: NamespaceId
    /// Mosaic id
    public let mosaicId: MosaicId
    /// Total mosaic supply
    public let supply: UInt64
    /// Block height it was created
    public let height: UInt64
    /// Mosaic account owner
    public let owner: PublicAccount

    let properties: MosaicProperties

    /// If the mosaic is expired
    public var isExpired: Bool {
        return !isActive
    }


    /// True if the supply is mutable
    public var isSupplyMutable: Bool {
        return properties.isSupplyMutable
    }

    /// True if the mosaic is transferable between non-owner accounts
    public var isTransferable: Bool {
        return properties.isTransferable
    }

    /// If the mosaic levy is mutable
    public var isLevyMutable: Bool {
        return properties.isLevyMutable
    }

    /// The number of blocks from height it will be active
    public var duration: UInt64 {
        return properties.duration
    }

    /// Mosaic divisibility
    public var divisibility: Int {
        return properties.divisibility
    }
}

