// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation
import RxSwift

/// Mosaic http repository.
public class MosaicHttp: Http, MosaicRepository {
    /**
     * Constructs with host.
     *
     * - parameter url: Host url.
     */
    public override init(url: URL) {
        super.init(url: url)
    }

    /// :nodoc:
    public func getMosaic(mosaicId: MosaicId) -> Single<MosaicInfo> {
        let builder = MosaicRoutesAPI.getMosaicWithRequestBuilder(mosaicId: mosaicId.id.hexString).with(url: url)
        return Single.zip( getNetworkType(), builder.rxSend()).map { (networkType, dto) in try dto.toModel(in: networkType) }
    }

    /// :nodoc:
    public func getMosaics(mosaicIds: [MosaicId]) -> Single<[MosaicInfo]> {
        let builder = MosaicRoutesAPI.getMosaicsWithRequestBuilder(
                mosaicIds: MosaicIds(mosaicIds: mosaicIds.map { $0.id.hexString } )).with(url: url)
        return Single.zip( getNetworkType(), builder.rxSend()).map { (networkType, dto) in try dto.map { try $0.toModel(in: networkType) } }
    }

    /// :nodoc:
    public func getMosaicsFromNamespace(namespaceId: NamespaceId, pageSize: Int?, id: String?) -> Single<[MosaicInfo]> {
        let builder = MosaicRoutesAPI.getMosaicsFromNamespaceWithRequestBuilder(namespaceId: namespaceId.id.hexString, pageSize: pageSize, id: id).with(url: url)
        return Single.zip( getNetworkType(), builder.rxSend()).map { (networkType, dto) in try dto.map { try $0.toModel(in: networkType) } }
    }

    /// :nodoc:
    public func getMosaicNames(mosaicIds: [MosaicId]) -> Single<[MosaicName]> {
        let builder = MosaicRoutesAPI.getMosaicsNameWithRequestBuilder(mosaicIds: MosaicIds(mosaicIds: mosaicIds.map { $0.id.hexString })).with(url: url)
        return builder.rxSend().map { dto in dto.map { $0.toModel() } }
    }

}

private func extractMosaicProperties(properties: MosaicPropertiesDTO) -> MosaicProperties {
    let flags = properties[0][0]
    return MosaicProperties(
            isSupplyMutable: (( flags >> 0 ) & 0x01) != 0,
            isTransferable: (( flags >> 1 ) & 0x01) != 0,
            isLevyMutable: (( flags >> 2 ) & 0x01) != 0,
            divisibility: Int(properties[1].uint64Value),
            duration: properties[2].uint64Value)
}

extension MosaicInfoDTO {
    func toModel(in networkType: NetworkType) throws -> MosaicInfo {
        let owner = try PublicAccount(publicKeyHexString: self.mosaic.owner, networkType: networkType)
        return MosaicInfo(
                isActive: meta.active,
                index: meta.index,
                metaId: meta.id,
                namespaceId: NamespaceId(id: mosaic.namespaceId.uint64Value),
                mosaicId: MosaicId(id: mosaic.mosaicId.uint64Value),
                supply: mosaic.supply.uint64Value,
                height: mosaic.height.uint64Value,
                owner: owner,
                properties: extractMosaicProperties(properties: mosaic.properties))
    }
}

extension MosaicNameDTO {
    func toModel() -> MosaicName {
        return MosaicName(
                mosaicId: MosaicId(id: mosaicId.uint64Value),
                name: name,
                parentId: NamespaceId(id: parentId.uint64Value))
    }
}

