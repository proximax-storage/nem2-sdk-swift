// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import RxSwift
/// Namespace http repository
public class NamespaceHttp: Http, NamespaceRepository {
    /**
     * Constructs with host.
     *
     * - parameter url: Host url.
     */
    public override init(url: URL) {
        super.init(url: url)
    }

    /// :nodoc:
    public func getNamespace(namespaceId: NamespaceId) -> Single<NamespaceInfo> {
        let builder = NamespaceRoutesAPI.getNamespaceWithRequestBuilder(namespaceId: namespaceId.id.hexString).with(url: url)
        return Single.zip( getNetworkType(), builder.rxSend()).map { (networkType, dto) in try dto.toModel(in: networkType) }

    }

    /// :nodoc:
    public func getNamespacesFromAccount(address: Address, pageSize: Int?, id: String?) -> Single<[NamespaceInfo]> {
        let builder = NamespaceRoutesAPI.getNamespacesFromAccountWithRequestBuilder(accountId: address.plain, pageSize: pageSize, id: id).with(url: url)
        return Single.zip( getNetworkType(), builder.rxSend()).map { (networkType, dto) in try dto.map { try $0.toModel(in: networkType)} }

    }

    /// :nodoc:
    public func getNamespacesFromAccounts(addresses: [Address], pageSize: Int?, id: String?) -> Single<[NamespaceInfo]> {
        let builder = NamespaceRoutesAPI.getNamespacesFromAccountsWithRequestBuilder(addresses: Addresses(addresses: addresses.map { $0.plain}), pageSize: pageSize, id: id).with(url: url)
        return Single.zip( getNetworkType(), builder.rxSend()).map { (networkType, dto) in try dto.map { try $0.toModel(in: networkType)} }
    }

    /// :nodoc:
    public func getNamespaceNames(namespaceIds: [NamespaceId]) -> Single<[NamespaceName]> {
        let builder = NamespaceRoutesAPI.getNamespacesNamesWithRequestBuilder(namespaceIds: NamespaceIds(namespaceIds: namespaceIds.map {$0.id.hexString})).with(url: url)
        return builder.rxSend().map { dto in dto.map { $0.toModel()}}
    }
}



extension NamespaceInfoDTO {
    func toModel(in networkType: NetworkType) throws -> NamespaceInfo {
        guard let namespaceType = NamespaceType(rawValue: UInt8(namespace.type)) else {
            throw Nem2SdkSwiftError.parseError("Failed to parse \(namespace.type) as namespace type.")
        }
        let owner = try PublicAccount(publicKeyHexString: namespace.owner, networkType: networkType)
        return NamespaceInfo(
                isActive: meta.active,
                index: meta.index,
                metaId: meta.id,
                type: namespaceType,
                depth: namespace.depth,
                levels: [namespace.level0, namespace.level1, namespace.level2].compactMap { $0?.uint64Value }.map { NamespaceId(id: $0) },
                parentId: NamespaceId(id: namespace.parentId.uint64Value),
                owner: owner,
                startHeight: namespace.startHeight.uint64Value,
                endHeight: namespace.endHeight.uint64Value)
    }
}

extension NamespaceNameDTO {
    func toModel() -> NamespaceName {
        let parentIdStruct = parentId != nil ? NamespaceId(id: parentId!.uint64Value) : nil
        return NamespaceName(
                namespaceId: NamespaceId(id: namespaceId.uint64Value),
                name: name,
                parentId: parentIdStruct)
    }
}



