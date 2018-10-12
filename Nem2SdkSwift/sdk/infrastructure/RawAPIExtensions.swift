// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation
import RxSwift

extension RequestBuilder {
    func with(url: URL) -> RequestBuilder {
        URLString = url.description + URLString
        return self
    }
    func rxSend() -> Single<T> {
        return Single.create { observer in
            self.execute { (response: Response<T>?, error: Error?) in
                if let response = response?.body {
                    observer(.success(response))
                }  else {
                    if let error = error {
                        if case ErrorResponse.error(let code, let data, _ ) = error {
                            let message = data != nil ? String(data: data!, encoding: .utf8) : nil
                            observer(.error(Nem2SdkSwiftError.responseError(code, message)))
                        } else {
                            observer(.error(Nem2SdkSwiftError.networkError))
                        }
                    }
                    else {
                        observer(.error(Nem2SdkSwiftError.networkError))
                    }
                }
            }

            return Disposables.create()
        }
    }
}

extension Array where Element == Int {
    var uint64Value: UInt64 {
        return UInt64(self[0]) | (UInt64(self[1]) << 32)
    }
}

