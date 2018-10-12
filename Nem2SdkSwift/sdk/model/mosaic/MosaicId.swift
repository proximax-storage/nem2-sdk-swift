// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// The mosaic id structure describes mosaic id
public struct MosaicId: Equatable {
    // MARK: Properties
    /// Mosaic integer id
    public let id: UInt64
    /// Mosaic full name, with namespace name (ex: nem:xem)
    public let fullName: String?

    // MARK: Methods
    /**
     * Create MosaicId from mosaic and namespace string name (ex: nem:xem or domain.subdom.subdome:token)
     *
     * - parameter fullName: Mosaic full name
     * - throws: Nem2SdkSwiftError.illegalArgument if the fullName is malformed.
     */
    public init(fullName: String) throws {
        guard !fullName.isEmpty && fullName.contains(":") else {
            throw Nem2SdkSwiftError.illegalArgument(fullName + " is not valid")
        }
        let parts = fullName.split(separator: ":");
        guard parts.count == 2 else {
            throw Nem2SdkSwiftError.illegalArgument(fullName + " is not valid")
        }
        let namespaceFullName = String(parts[0])
        let mosaicName = String(parts[1])

        self.id = try IdGenerator.generateMosaicId(namespaceFullName: namespaceFullName, mosaicName: mosaicName)
        self.fullName = fullName
    }

    /**
     * Create MosaicId from integer id
     *
     * - parameter id: Mosaic integer id
     */
    public init(id: UInt64) {
        self.id = id
        self.fullName = nil
    }

    /// Compares only the ids.
    public static func ==(lhs: MosaicId, rhs: MosaicId) -> Bool {
        return lhs.id == rhs.id
    }
}
