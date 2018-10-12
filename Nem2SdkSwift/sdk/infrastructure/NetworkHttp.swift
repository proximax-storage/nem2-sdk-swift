// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import RxSwift

/// Network http repository.
public class NetworkHttp: Http, NetworkRepository {
    /**
     * Constructs with host.
     *
     * - parameter url: Host url.
     */
    public override init(url: URL) {
        super.init(url: url)
    }

    /// :nodoc:
    override public func getNetworkType() -> Single<NetworkType> {
        return super.getNetworkType()
    }
}