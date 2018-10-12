// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// XEM Mosaic
public class XEM {
    // MARK: Properties

    /// Divisibility
    public static let divisibility = 6
    /// Initial supply
    public static let initialSupply: UInt64 = 8_999_999_999
    /// Is transferable
    public static let transferable = true
    /// Is supply mutable
    public static let supplyMutable = false
    /// Namespace id
    public static let namespaceId = try! NamespaceId(fullName: "nem")
    /// Mosaic id
    public static let mosaicId = try! MosaicId(fullName: "nem:xem")

    /**
     * Create xem with using xem as unit.
     *
     * - parameter xemAmount: XEM amount
     * - returns: XEM Mosaic
     */
    public static func of(xemAmount: Decimal) -> Mosaic {
        let microXem = xemAmount.scale10(divisibility).uint64Value
        return Mosaic(id: mosaicId, amount: microXem)
    }

    /**
     * Create xem with using micro xem as unit, 1 XEM = 1000000 micro XEM.
     *
     * - parameter microXemAmount: micro XEM amount
     * - returns: XEM Mosaic
     */
    public static func of(microXemAmount: UInt64) -> Mosaic {
        return Mosaic(id: mosaicId, amount: microXemAmount)
    }
}
