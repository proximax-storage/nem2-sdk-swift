// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import RxSwift

/// Namespace interface repository.
public protocol NamespaceRepository {

    /**
     * Gets the NamespaceInfo for a given namespaceId.
     *
     * - parameter namespaceId: NamespaceId
     * - returns: Observable of NamespaceInfo
     */
    func getNamespace(namespaceId: NamespaceId) -> Single<NamespaceInfo>

    /**
     * Gets list of NamespaceInfo for an account.
     *
     * - parameter address: Address
     * - parameter pageSize: The number of namespaces to return. (optional)
     * - parameter id: The namespace id up to which namespace definitions are returned. (optional)
     * - returns: Observable of [NamespaceInfo]
     */
    func getNamespacesFromAccount(address: Address, pageSize: Int?, id: String?) -> Single<[NamespaceInfo]>

    /**
     * Gets list of NamespaceInfo for different account.
     *
     * - parameter addresses: List of Address
     * - parameter pageSize: The number of namespaces to return. (optional)
     * - parameter id: The namespace id up to which namespace definitions are returned. (optional)
     * - returns: Observable of [NamespaceInfo]
     */
    func getNamespacesFromAccounts(addresses: [Address], pageSize: Int?, id: String?) -> Single<[NamespaceInfo]>

    /**
     * Gets list of NamespaceName for different namespaceIds.
     *
     * - parameter namespaceIds: List of NamespaceId
     * - returns: Observable of [NamespaceName]
     */
    func getNamespaceNames(namespaceIds: [NamespaceId]) -> Single<[NamespaceName]>
}

public extension NamespaceRepository {
    func getNamespacesFromAccount(address: Address, pageSize: Int? = nil, id: String? = nil) -> Single<[NamespaceInfo]> {
        return getNamespacesFromAccount(address: address, pageSize: pageSize, id: id)
    }

    func getNamespacesFromAccounts(addresses: [Address], pageSize: Int? = nil, id: String? = nil) -> Single<[NamespaceInfo]> {
        return getNamespacesFromAccounts(addresses: addresses, pageSize: pageSize, id: id)
    }
}

