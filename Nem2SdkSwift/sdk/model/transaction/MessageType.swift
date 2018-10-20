// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// Enum containing message type constants.
public enum MessageType: UInt8 {
    /// Plain message
    case plain = 0
    /// Encrypted message
    case secure = 1
}
