//
//  AssembledMessage.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-14.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


/// Shareable representation of an assembled buffer.
///
/// Shared by a BitStorageCore instance and its ByteCoder properties.
/// Individual bits are read/written by `@Position` properties of subclasses of `BitStorageCore`.
///
/// - SeeAlso: `BitStorageCore`, `ByteCoder`
public class AssembledMessage {
    /// Buffer of UInt8 for sending or receiving a message, in wire order.
    ///
    /// Interpretation of endian-ness should be done by `ByteCoder`s.
    public var bytes = Data()

    // During their initialization, derived classes copy references to this underlying representation
    // for their property wrappers...
    private static var _storage = AssembledMessage()
    // ...after which the base class BitStorageCore initializer rolls the static storage over for the next instantiation. This means there is always a yet-to-be-used Storage lying in wait.
    static func freezeAndRotateStorage() -> AssembledMessage {
        let tmp = _storage
        _storage = AssembledMessage()
        return tmp
    }
    // FIXME: What would be cool: proof of use in a ByteCoder required for access.
    // This could be useful in debug prints of storage that decode object.
    // But it's not obvious how to implement this because it's a chicken-and-egg problem: you can't prove
    // you are a coder until you make one, and that requires a storage handle.
    // Same for self.
    static func storageBuildInProgress(/*coder _: ByteCoder*/) -> AssembledMessage {
        return _storage
    }
}
