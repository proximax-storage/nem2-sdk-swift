// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation


/// Static functions to generate mosaic ID and namespace ID.
class IdGenerator {
    /**
     * Generates ID
     *
     * - parameter name: Name of the entity.
     * - parameter parentId: ID of the parent of the entity.
     */
    static func generateId(name: String, parentId: UInt64) -> UInt64 {
        let parentIdBytes = parentId.bytes
        let bytes = Array(name.utf8)

        let result = Hashes.sha3_256(parentIdBytes + bytes)
        return UInt64.createFrom(bytes: Array(result[0..<8]))!
    }

    static func generateNamespacePath(name: String) throws -> [UInt64] {
        let parts = name.split(separator: ".", omittingEmptySubsequences: false)

        if (parts.count == 0) {
            throw Nem2SdkSwiftError.illegalArgument("invalid namespace name")
        } else if (parts.count > 3) {
            throw Nem2SdkSwiftError.illegalArgument("too many parts")
        }

        var namespaceId: UInt64 = 0

        return try parts.map { partView in
            let part = String(partView)

            guard part.matches("^[a-z0-9][a-z0-9-_]*$") else {
                throw Nem2SdkSwiftError.illegalArgument("invalid namespace name")
            }
            namespaceId = generateId(name: part, parentId: namespaceId)
            return namespaceId
        }
    }


    static func generateNamespaceId(namespaceFullName: String) throws -> UInt64 {
        let namespacePath = try generateNamespacePath(name: namespaceFullName)
        return namespacePath.last!
    }


    static func generateMosaicId(namespaceFullName: String, mosaicName: String) throws -> UInt64 {
        guard !mosaicName.isEmpty else {
            throw Nem2SdkSwiftError.illegalArgument("having zero length")
        }
        let parentNamespaceId = try generateNamespaceId(namespaceFullName: namespaceFullName)

        guard mosaicName.matches("^[a-z0-9][a-z0-9-_]*$") else {
            throw Nem2SdkSwiftError.illegalArgument("invalid mosaic name")
        }
        return generateId(name: mosaicName, parentId: parentNamespaceId)
    }
}
