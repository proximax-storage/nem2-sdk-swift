// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// The namespace name info structure describes basic information of a namespace and name.
public struct NamespaceName {
    // MARK: Properties
    /// Namespace id
    public let namespaceId: NamespaceId
    /// Namespace name
    public let name: String
    /// Parent namespace id
    public let parentId: NamespaceId?
}
