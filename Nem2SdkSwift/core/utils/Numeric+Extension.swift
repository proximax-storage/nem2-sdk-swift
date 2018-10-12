// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

extension Numeric{
    var bytes: [UInt8] {
        var mutableValue = self
        let bytes = Array<UInt8>(withUnsafeBytes(of: &mutableValue) {
            $0
        })
        return bytes
    }

    static func createFrom(bytes: [UInt8]) -> Self?{
        if bytes.count < MemoryLayout<Self>.size {
            return nil
        }
        let value = UnsafePointer(bytes).withMemoryRebound(to: Self.self, capacity: 1) {
            $0.pointee
        }
        return value
    }
}

extension Numeric where Self : BinaryInteger {
    var hexString: String {
        return String(self, radix: 16)
    }
}