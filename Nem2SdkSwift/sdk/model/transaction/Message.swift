// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// An abstract message class that serves as the base class of all message types.
public class Message {
    // MARK: Properties
    /// Message type.
    public let type: MessageType
    /// Returns message payload.
    public let payload: [UInt8]

    init(type: MessageType, payload: [UInt8]) {
        self.type = type
        self.payload = payload
    }
}
