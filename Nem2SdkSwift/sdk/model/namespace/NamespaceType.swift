// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// Namespace level type
public enum NamespaceType: UInt8, CaseIterable {
    /// Root namespace
    case rootNamespace = 0
    /// Sub namespace
    case subNamespace = 1
}