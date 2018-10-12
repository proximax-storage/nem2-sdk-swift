// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// Network type
public enum NetworkType: UInt8, CaseIterable {
    /// Main network
    case mainNet = 104
    /// Test network
    case testNet = 152
    /// Mijin network
    case mijin = 96
    /// Mijin test network
    case mijinTest = 144

    /// MARK: Properties
    /// Initial address character of this network.
    public var initialCharacterOfAddress: String {
        switch self {
        case .mainNet: return "N"
        case .testNet: return "T"
        case .mijin: return "M"
        case .mijinTest: return "S"
        }
    }

    /// String description of this network
    public var description: String {
        switch self {
        case .mainNet: return "MAIN_NET"
        case .testNet: return "TEST_NET"
        case .mijin: return "MIJIN"
        case .mijinTest: return "MIJIN_TEST"
        }
    }

}
