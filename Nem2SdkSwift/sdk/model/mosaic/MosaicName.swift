// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// The mosaic name info structure describes basic information of a mosaic and name.
public struct MosaicName {
    // MARK: Properties
    /// Mosaic identifier
    public let mosaicId: MosaicId
    /// Mosaic name
    public let name: String
    /// Namespace identifier it belongs to
    public let parentId: NamespaceId
}
