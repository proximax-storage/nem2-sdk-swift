// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The blockchain score structure describes blockchain difficulty.
public struct BlockchainScore {
    /// Low part of the blockchain score.
    public let scoreLow: UInt64
    /// High part of the blockchain score.
    public let scoreHigh: UInt64
}