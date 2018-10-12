// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

// Mosaic supply type.
public enum MosaicSupplyType: UInt8, CaseIterable {
    /// Decrease the supply.
    case decrease = 0
    /// Increase the supply.
    case increase = 1
}