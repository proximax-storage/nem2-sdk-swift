// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import XCTest
import RxBlocking
@testable import Nem2SdkSwift

class NetworkHttpTest: XCTestCase {
    private var networkHttp: NetworkHttp!

    override func setUp() {
        super.setUp()
        networkHttp = NetworkHttp(url: TestSettings.url)
    }


    func testGetNetworkType() {
        let networkType = try! networkHttp.getNetworkType().toBlocking().first()!
        XCTAssertEqual(NetworkType.mijinTest, networkType)
    }
}