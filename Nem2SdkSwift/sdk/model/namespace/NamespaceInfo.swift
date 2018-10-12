// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// NamespaceInfo contains the state information of a namespace.
public struct NamespaceInfo {
    /// MARK: Properties
    /// If namespace is active
    public let isActive: Bool
    /// Index
    public let index: Int
    /// Meta id
    public let metaId: String
    /// Namespace type
    public let type: NamespaceType
    /// Namespace level depth
    public let depth: Int
    /// Different NamespaceIds per level
    public let levels: [NamespaceId]
    /// Parent namespace id
    public let parentId: NamespaceId?
    /// Mosaic owner account
    public let owner: PublicAccount
    /// Block height the namespace was registered
    public let startHeight: UInt64
    /// Block height the namespace expires if not renewed
    public let endHeight: UInt64

    /// Namespace expiration status
    public var isExpired: Bool {
        return !isActive;
    }

    /// Namespace id
    public var id: NamespaceId {
        return levels.last!
    }

    /// True if namespace is Root
    public var isRoot: Bool {
        return self.type == .rootNamespace
    }

    /// True if namespace is SubNamespace
    public var isSubNamespace: Bool {
        return self.type == .subNamespace
    }
}
