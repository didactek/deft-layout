//
//  BitEmbeddable.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-18.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


/// Protocol to move a value in and out of a set of bits.
///
/// Required for `CoderAdapter` to connect a type to a `ByteCoder`.
///
/// - Note: To make it easy to encode enums in Layout classes, we strive to avoid requiring *any*
/// extensions to enums. Enums that specify an encoding conform to `RawRepresentable`,
/// which provides all needed functionality. Identifying a minimal subset of `RawRepresentable`'s
/// needed functionality makes it less work to adapt additional types.
public protocol BitEmbeddable {
    /// Integer wide enough to hold any representation of this type. The representation should
    /// be reasonably compact and use bits of RawValue starting from the least signficant.
    associatedtype RawValue: FixedWidthInteger
    /// Convert from a RawValue into an instance of the conforming type, if the bits in rawValue
    /// can be interpreted as a valid object.
    init?(rawValue: RawValue)
    /// Encode the object using an integer, using the lowest necessary bits of RawValue.
    var rawValue: RawValue { get }
}

// It would be nice to give generic instruction to the compiler that certain protocols can and should be adapted to BitEmbeddable when they are needed for the property wrapper.
//
// Such a feature would reduce the user-facing boilerplate in every enum declaration--declarations where the compiler synthetically injects the RawRepresentable but doesn't know about our desire for conformance to another protocol.
//
// extension FixedWidthInteger: BitEmbeddable ...
// extension RawRepresentable: BitEmbeddable where RawValue: UInt8
//
// As of Swift 5.2, extending protocols in this way is not part of the language, but there is discussion surrounding it. It would be useful (and expressive) in cases like this, but it would also complicate runtime facets of the type system. For more, see:
// https://github.com/apple/swift/blob/main/docs/GenericsManifesto.md#retroactive-protocol-refinement


extension Int: BitEmbeddable {
    public typealias RawValue = UInt

    public init?(rawValue: RawValue) {
        // FIXME: this probably sign-extends Int8s with the high bit set. (Int7 OK for all values)
        self = Self(truncatingIfNeeded: rawValue)
    }
    public var rawValue: RawValue {
        return RawValue(truncatingIfNeeded: self)
    }
}

extension Bool: BitEmbeddable {
    public typealias RawValue = UInt8
    public init?(rawValue: RawValue) {
        self = rawValue == 1
    }
    public var rawValue: RawValue {
        return self ? 1 : 0
    }
}


// There may not be value in user code of encoding the following, since it's easy to work with the wider "Int/UInt" types, and they get decoded with the same range checking anyway.
extension UInt8: BitEmbeddable {
    public typealias RawValue = UInt8
    public init?(rawValue: RawValue) {
        self = rawValue
    }
    public var rawValue: RawValue {
        return self
    }
}

extension Int8: BitEmbeddable {
    public typealias RawValue = UInt8

    public init?(rawValue: RawValue) {
        self = Self(bitPattern: rawValue)
    }
    public var rawValue: RawValue {
        return RawValue(bitPattern: self)
    }
}

extension UInt16: BitEmbeddable {
    public typealias RawValue = UInt16
    public init?(rawValue: RawValue) {
        self = rawValue
    }
    public var rawValue: RawValue {
        return self
    }
}

extension Int16: BitEmbeddable {
    public typealias RawValue = UInt16

    public init?(rawValue: RawValue) {
        self = Self(truncatingIfNeeded: rawValue)
    }
    public var rawValue: RawValue {
        return RawValue(truncatingIfNeeded: self)
    }
}


