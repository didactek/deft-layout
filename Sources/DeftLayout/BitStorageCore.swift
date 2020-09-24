//
//  BitStorageCore.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-03.
//  Prototyped 2020-05-02 in BitManip project
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


/// Base class for layout descriptions that connects the derived class's layout properties with
/// underlying storage for those properties.
///
/// There are two tiers of classes built on top of this class:
/// - a byte layout adapter (`ByteDescription`, `ByteArrayDescription`, or `WordDescription`
/// that provides the property wrapper adapters that write into the storage member here. These classes do not
/// have instance properties on their own.
/// - domain-specific layouts, which introduce properties. Using the property wrappers in the adapter layer,
/// these properties are exposed as semantic types, but their storage is mapped by the layout adapter
/// property wrappers into the storage here.

/// - Note: There is some magic here, even though magic should be avoided wherever possible.
/// `storage` leverages Swift's rules for object initialization: all properties of the derived class must be
/// given some kind of value before the base class initializer is called.
///
/// In collaboration with  `AssembledMessage` and the property wrappers in the middle layer, the
/// semantic layout classes build their properties first. Each property wrapper asks `AssembledMessage`
/// for storage, and all are given the same storage (which they will gingerly use only the appropriate parts of).
///
/// *After* the properties of the layout classes are set up in this way, the base initializer is called, and it also
/// goes to the `AssembledMessage` factory to indicate that the storage descriptions are complete, that
/// it should be given access to the storage, and that any initializers asking for storage in the future should
/// be directed to something new for themselves.
open class BitStorageCore {
    public let storage: AssembledMessage

    init() {
        storage = AssembledMessage.freezeAndRotateStorage()
    }
}

