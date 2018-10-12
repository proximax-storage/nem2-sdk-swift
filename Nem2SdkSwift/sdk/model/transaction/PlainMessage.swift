// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The plain message model defines a plain string. When sending it to the network we transform the payload to hex-string.
public class PlainMessage: Message {
    // MARK: Properties
    /// Plain message containing an empty string.
    public static let empty = PlainMessage(text: "")
    /// Plain text message. Nil If loaded payload cannot be decoded as utf-8 string.
    public let text: String?

    /**
     * Constructor
     *
     * - parameter text: plain message text.
     */
    public init(text: String) {
        self.text = text
        super.init(type: 0, payload: Array(text.utf8))
    }

    /**
     * Constructor
     *
     * - parameter payload: plain message payload
     */
    init(payload: [UInt8]) {
        self.text = String(bytes: payload, encoding: .utf8)
        super.init(type: 0, payload: payload)
    }
}

