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
open class BitStorageCore {
    /// Bytes in wire order.
    ///
    /// Interpretation of endian-ness should be done by `ByteCoder`s.
    public var bytes: Data {
        get { storage.bytes }
        set { storage.bytes = newValue }
    }

    let storage: AssembledMessage

    init() {
        // - Note: There is some magic here, even though magic should be avoided wherever possible.
        //
        // `storage` leverages Swift's rules for object initialization: all properties
        // of the derived class must be given some kind of value before the base class
        // initializer is called.
        //
        // During property initialization in the most-derived semantic layout classes,
        // the @Position property wrapper asks `AssembledMessage` for storage, and
        // AssembledMessage gives out references to the same storage (which each property
        // will gingerly use only the appropriate parts of).
        //
        // *After* the properties of the layout classes are set up in this way, this
        // base initializer is called, and the freezeAndRotateStorage call notifies
        // the `AssembledMessage` factory that the storage descriptions for this object
        // are complete, that this base class should be given access to the storage,
        // and that any initializers asking for storage in the future should
        // be directed to a new AssembledMessage to share amongst themselves.
        storage = AssembledMessage.freezeAndRotateStorage()
    }
}

