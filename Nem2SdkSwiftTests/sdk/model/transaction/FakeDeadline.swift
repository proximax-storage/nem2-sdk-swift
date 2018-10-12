// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
@testable import Nem2SdkSwift

class FakeDeadline: Deadline {
    init() {
        super.init(fromNow: 60 * 60)
    }

    override var timestamp: UInt64 {
        return 1
    }
}