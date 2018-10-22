// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation


/// Errors from Nem2SdkSwift
public enum Nem2SdkSwiftError: Error {
    /// An argument of the API is invalid.
    case illegalArgument(String)
    /// A network error
    case networkError
    /// A response error
    case responseError(Int, String?)
    /// A parse error
    case parseError(String)
    /// A serialize error
    case serializeError(String)
    /// A message encryption error
    case messageEncryptionError(String)
}