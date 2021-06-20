//
//  AssembledMessage.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-14.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


/// Infrastructure for managing a shared representation of a Data buffer.
///
/// Shared by a BitStorageCore instance and its ByteCoder properties.
class AssembledMessage {
    /// Encoded buffer of UInt8, for sending or receiving a message.
    public var bytes = Data()

    // During their initialization, derived classes copy references to this underlying representation
    // for their property wrappers...
    private static var _storage = AssembledMessage()

    /// End the sharing provided by `storageBuildInProgress` and prepare to serve a new batch of owners.
    static func freezeAndRotateStorage() -> AssembledMessage {
        let tmp = _storage
        _storage = AssembledMessage()
        return tmp
    }

    /// Obtain a reference to the current AssembledMessage instance.
    ///
    /// The property wrappers that want to manage a fraction of the shared Assembled Message obtain
    /// that AssembledMessage through this function.
    ///
    /// Important: To have all the properties and the base class end up with exclusive and consistent access to
    /// one AssembledMessage, the property wrappers must all be constructed first, and then
    /// `freezeAndRotateStorage` must be called. Because Swift requries that all properties be
    /// assigned at least some value before super.init is called, the `freezeAndRotateStorage` can be
    /// placed in the layout superclass. This pattern is provided when deriving from `BitStorageCore`.
    ///
    /// - Important: This uses a static pool and is not thread-safe. Initialize in turn each object sharing AssembledMessages
    /// with its properties.
    static func storageBuildInProgress(/*coder _: ByteCoder*/) -> AssembledMessage {
        return _storage
    }
}
