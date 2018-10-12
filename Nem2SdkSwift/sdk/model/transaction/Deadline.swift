// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The deadline of the transaction. The deadline is given as the number of seconds elapsed since the creation of the nemesis block.
public class Deadline {
    //
    /// Nemesis block date. The date is 2016/04/01 00:00:00 UTC.
    public static let dateOfNemesisBlock = Date(timeIntervalSince1970: 1459468800)

    /// Deadline date
    public let date: Date

    /// Number of milli seconds elapsed since the creation of the nemesis block.
    public var timestamp: UInt64 {
        return UInt64(date.timeIntervalSince(Deadline.dateOfNemesisBlock) * 1000)
    }

    /**
     * Constructor
     *
     * - parameter fromNow: Duration time from now
     */
    public init(fromNow interval: TimeInterval) {
        self.date = Date(timeInterval: interval, since: Date())
    }

    /**
     * Constructor
     *
     * - parameter fromNemesis: Duration time from nemesis block
     */
    public init(fromNemesis interval: TimeInterval) {
        self.date = Date(timeInterval: interval, since: Deadline.dateOfNemesisBlock)
    }
}
