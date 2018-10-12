// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/**
 * Accounts can rent a namespace for an amount of blocks and after a this renew the contract.
 * This is done via a RegisterNamespaceTransaction.
 */
public class RegisterNamespaceTransaction: Transaction {
    // MARK: Properties
    /// Namespace name.
    public let namespaceName: String
    /// ID of the namespace derived from namespaceName.
    /// When creating a sub namespace the namespaceId is derived from namespaceName and parentId.
    public let namespaceId: NamespaceId
    /// Namespace type either rootNamespace or subNamespace.
    public let namespaceType: NamespaceType
    /// Number of blocks a namespace is active.
    public let duration: UInt64?
    /// ID of the parent of sub namespace.
    public let parentId: NamespaceId?

    // MARK: Methods
    init(base: Transaction,
         namespaceName: String,
         namespaceId: NamespaceId,
         namespaceType: NamespaceType,
         duration: UInt64? = nil,
         parentId: NamespaceId? = nil) {

        self.namespaceName = namespaceName
        self.namespaceId = namespaceId
        self.namespaceType = namespaceType
        self.duration = duration
        self.parentId = parentId

        super.init(base: base)
    }


    /**
     * Create a root namespace object.
     *
     * - parameter namespaceName: Namespace name.
     * - parameter duration:      Duration of the namespace.
     * - parameter networkType:   Network type.
     * - parameter deadline:      Deadline to include the transaction.(Optional. The default is 1 hour from now.)
     * - returns: Instance of RegisterNamespaceTransaction
     */
    public static func createRootNamespace(
            namespaceName: String,
            duration: UInt64,
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60)) throws -> RegisterNamespaceTransaction {

        let namespaceId = try NamespaceId(fullName: namespaceName)
        let base = Transaction(type: .registerNamespace, networkType: networkType, version: 2, deadline: deadline)
        return RegisterNamespaceTransaction(base: base,
                namespaceName: namespaceName,
                namespaceId: namespaceId,
                namespaceType: .rootNamespace,
                duration: duration)
    }

    /**
     * Create a sub namespace object.
     *
     * - parameter namespaceName: Namespace name.
     * - parameter parentId:      Parent id name.
     * - parameter networkType:   Network type.
     * - parameter deadline:      Deadline to include the transaction.(Optional. The default is 1 hour from now.)
     * - returns: Instance of RegisterNamespaceTransaction
     */
    public static func createSubNamespace(
            namespaceName: String,
            parentId: NamespaceId,
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60)) throws -> RegisterNamespaceTransaction {

        let base = Transaction(type: .registerNamespace, networkType: networkType, version: 2, deadline: deadline)
        return RegisterNamespaceTransaction(
                base: base,
                namespaceName: namespaceName,
                namespaceId: NamespaceId(id: IdGenerator.generateId(name: namespaceName, parentId: parentId.id)),
                namespaceType: .subNamespace,
                parentId: parentId)
    }

    override func getTransactionBodyBytes() -> [UInt8] {

        let nameBytes = Array(namespaceName.utf8)

        return namespaceType.rawValue.bytes + // type 1 byte
                (namespaceType == .rootNamespace ? duration!.bytes : parentId!.id.bytes) + // duration if root, parent if if sub. Both are 8 bytes
                namespaceId.id.bytes + // namespace id 8 bytes
                UInt8(nameBytes.count).bytes + // namespace name length 1 byte
                nameBytes // namespace name( UTF8 )
    }
}
