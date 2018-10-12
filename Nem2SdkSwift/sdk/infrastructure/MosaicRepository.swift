// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation
import RxSwift

/// Mosaic interface repository.
public protocol MosaicRepository {
    /**
     * Gets a MosaicInfo for a given mosaicId
     *
     * - parameter mosaicId: Mosaic id
     * - returns: Observable of MosaicInfo
     */
    func getMosaic(mosaicId: MosaicId) -> Single<MosaicInfo>

    /**
     * Gets MosaicInfo for different mosaicIds.
     *
     * - parameter mosaicIds: List of mosaic id
     * - returns: Observable of [MosaicInfo]
     */
    func getMosaics(mosaicIds: [MosaicId]) -> Single<[MosaicInfo]>

    /**
     * Gets list of MosaicInfo from mosaics created with provided namespace.
     *
     * - parameter namespaceId: Namespace id.
     * - parameter pageSize: The number of mosaics to return. (optional)
     * - parameter id: The mosaic id up to which mosaic definitions are returned. (optional)
     * - returns: Observable of [MosaicInfo]
     */
    func getMosaicsFromNamespace(namespaceId: NamespaceId, pageSize: Int?, id: String?) -> Single<[MosaicInfo]>

    /**
     * Gets list of MosaicName for different mosaicIds.
     *
     * - parameter mosaicIds: List of mosaic id.
     * - returns: Observable of [MosaicName]
     */
    func getMosaicNames(mosaicIds: [MosaicId]) -> Single<[MosaicName]>
}

public extension MosaicRepository {
    func getMosaicsFromNamespace(namespaceId: NamespaceId, pageSize: Int? = nil, id: String? = nil) -> Single<[MosaicInfo]> {
        return getMosaicsFromNamespace(namespaceId: namespaceId, pageSize: pageSize, id: id)
    }
}