// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation
import RxSwift

/// :nodoc:
public class Http {
    let url: URL
    var networkType: NetworkType?

    init(url: URL) {
        self.url = url
        SwaggerClientAPI.basePath = ""
    }

    func getNetworkType() -> Single<NetworkType> {
        if let networkType = self.networkType {
            return Single.create { observer in
                observer(.success(networkType))
                return Disposables.create()
            }
        }
        let builder = NetworkRoutesAPI.getNetworkTypeWithRequestBuilder()
        builder.URLString = url.appendingPathComponent(builder.URLString).description
        return builder.rxSend().map { dto in
            if dto.name.lowercased() == "mijinTest".lowercased() {
                self.networkType = NetworkType.mijinTest
                return NetworkType.mijinTest
            } else {
                throw Nem2SdkSwiftError.illegalArgument("network " + dto.name + " is not supported yet by the sdk")
            }
        }
    }
}
