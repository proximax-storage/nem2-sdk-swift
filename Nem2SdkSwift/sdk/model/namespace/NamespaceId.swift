// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The namespace id structure describes namespace id
public struct NamespaceId: Equatable {
    // MARK: Properties
    /// Namespace id
    public let id: UInt64
    /// Namespace full name, with subnamespaces if it's the case.
    public let fullName: String?

    // MARK: Methods
    /**
     * Create NamespaceId from namespace string name (ex: nem or domain.subdom.subdome)
     *
     * - parameter fullName: Namespace full name
     * - throws: Nem2SdkSwiftError.illegalArgument if the fullName is malformed.
     */
    public init(fullName: String) throws {
        self.id = try IdGenerator.generateNamespaceId(namespaceFullName: fullName)
        self.fullName = fullName
    }
    /**
     * Create NamespaceId from integer id
     *
     * - parameter id
     */
    public init(id: UInt64) {
        self.id = id;
        self.fullName = nil
    }

    /// Compares only the ids.
    public static func ==(lhs: NamespaceId, rhs: NamespaceId) -> Bool {
        // only checks the ids
        return lhs.id == rhs.id
    }
}
