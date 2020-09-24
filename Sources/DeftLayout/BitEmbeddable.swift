//
//  BitEmbeddable.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-18.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


///
/// - Note: protocol is a subset of RawRepresentable so enums can comply just by mentioning this protocol.
public protocol BitEmbeddable {
    associatedtype RawValue: FixedWidthInteger
    init?(rawValue: RawValue)
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


