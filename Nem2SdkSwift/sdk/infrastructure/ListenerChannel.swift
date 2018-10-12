// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

enum ListenerChannel: String {
    case block = "block"
    case confirmedAdded = "confirmedAdded"
    case unconfirmedAdded = "unconfirmedAdded"
    case unconfirmedRemoved = "unconfirmedRemoved"
    case partialAdded = "partialAdded"
    case partialRemoved = "partialRemoved"
    case cosignature = "cosignature"
    case status = "status"
}
