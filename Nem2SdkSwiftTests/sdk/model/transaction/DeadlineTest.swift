// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
@testable import Nem2SdkSwift

class DeadlineTest: XCTestCase {
    func testShouldCreateADeadlineForTwoHoursFromNow() {
        let now = Date()
        let deadline = Deadline(fromNow: 2 * 60 * 60)


        XCTAssertTrue(now < deadline.date)
        XCTAssertTrue(Date(timeInterval: 2 * 60 * 60 - 1, since: now) < deadline.date)
        XCTAssertTrue(Date(timeInterval: 2 * 60 * 60 + 2, since: now) > deadline.date)
    }

    func testNemesisDateIsCorrect() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let expectedNemesisDate = dateFormatter.date(from: "2016/04/01 00:00:00")!

        XCTAssertEqual(expectedNemesisDate, Deadline.dateOfNemesisBlock)
    }

    func testTimestampIsDurationSecondFromNemesisBlock() {
        let deadline = Deadline(fromNow: 0)

        let calculatedDate = Date(timeInterval: TimeInterval(deadline.timestamp / 1000 ), since: Deadline.dateOfNemesisBlock)

        // timestamp's unit is milli second so the calculated date has lower precision.
        XCTAssertGreaterThanOrEqual(deadline.date.timeIntervalSince(calculatedDate), 0)
        XCTAssertLessThan(deadline.date.timeIntervalSince(calculatedDate), 1)
    }
}
