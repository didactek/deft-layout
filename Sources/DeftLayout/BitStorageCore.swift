//
//  BitStorageCore.swift
//  radio
//
//  Created by Kit Transue on 2020-05-03.
//  Prototyped 2020-05-02 in BitManip project
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


protocol BitEmbeddable {
    associatedtype RawValue: FixedWidthInteger
    init?(rawValue: RawValue)
    var rawValue: RawValue { get }
}

/// Shareable representation of an assembled buffer.
///
/// Shared by a BitStorageCore instance and its ByteCoder properties.
/// Individual bits are read/written by `@position` properties of subclasses of `BitStorageCore`.
///
/// - SeeAlso: `BitStorageCore`, `ByteCoder`
class CommonUnderlayment {
    var bytes = Data()

    // During their initialization, derived classes copy references to this underlying representation
    // for their property wrappers...
    private static var _storage = CommonUnderlayment()
    // ...after which the base class BitStorageCore initializer rolls the static storage over for the next instantiation. This means there is always a yet-to-be-used Storage lying in wait.
    static func freezeAndRotateStorage() -> CommonUnderlayment {
        let tmp = _storage
        _storage = CommonUnderlayment()
        return tmp
    }
    // FIXME: What would be cool: proof of use in a ByteCoder required for access.
    // This could be useful in debug prints of storage that decode object.
    // But it's not obvious how to implement this because it's a chicken-and-egg problem: you can't prove
    // you are a coder until you make one, and that requires a storage handle.
    // Same for self.
    static func storageBuildInProgress(/*coder _: ByteCoder*/) -> CommonUnderlayment {
        return _storage
    }
}

class BitStorageCore {
    let storage: CommonUnderlayment

    init() {
        storage = CommonUnderlayment.freezeAndRotateStorage()
    }

    struct PositionOptions: OptionSet {
        let rawValue: Int

        static let extendNegativeBit = PositionOptions(rawValue: 1 << 0)
    }


    @propertyWrapper
    struct position<T: BitEmbeddable> {
        var coder: ByteCoder

        var wrappedValue: T {
            get {
                T(rawValue: T.RawValue(coder.widenedToByte))!
            }
            set {
                coder.widenedToByte = UInt8(newValue.rawValue)
            }
        }

        init(wrappedValue: T, ofByte: Int, msb: Int, lsb: Int, _ options: PositionOptions = []) {
            if options.contains(.extendNegativeBit) {
                self.coder = try! SignExtended(ofByte: ofByte, msb: msb, lsb: lsb, storedIn: CommonUnderlayment.storageBuildInProgress())
            }
            else {
                self.coder = try! SubByte(ofByte: ofByte, msb: msb, lsb: lsb, storedIn: CommonUnderlayment.storageBuildInProgress())
            }

            self.wrappedValue = wrappedValue
        }

        init(wrappedValue: T, ofByte: Int, bit: Int) {
            self.init(wrappedValue: wrappedValue, ofByte: ofByte, msb: bit, lsb: bit, [])
        }
    }
}

extension UInt8: BitEmbeddable {
    public typealias RawValue = UInt8
    public init?(rawValue: RawValue) {
        self = rawValue
    }
    public var rawValue: UInt8 {
        return self
    }
}

extension Int8: BitEmbeddable {
    public typealias RawValue = UInt8

    public init?(rawValue: RawValue) {
        self = Self(bitPattern: rawValue)
    }
    public var rawValue: UInt8 {
        return RawValue(bitPattern: self)
    }
}

extension Int: BitEmbeddable {
    public typealias RawValue = UInt8

    public init?(rawValue: RawValue) {
        // FIXME: this probably sign-extends Int8s with the high bit set. (Int7 OK for all values)
        self = Self(truncatingIfNeeded: Int8(bitPattern: rawValue))
    }
    public var rawValue: UInt8 {
        return RawValue(truncatingIfNeeded: self)
    }
}

extension Bool: BitEmbeddable {
    public typealias RawValue = UInt8
    public init?(rawValue: RawValue) {
        self = rawValue == 1
    }
    public var rawValue: UInt8 {
        return self ? 1 : 0
    }
}


// It would be nice to give generic instruction to the compiler that certain protocols can and should be adapted to BitEmbeddable when they are needed for the property wrapper.
//
// Such a feature would reduce the user-facing boilerplate in every enum declaration--declarations where the compiler synthetically injects the RawRepresentable but doesn't know about our desire for conformance to another protocol.
//
// extension FixedWidthInteger: BitEmbeddable ...
// extension RawRepresentable: BitEmbeddable where RawValue: UInt8
//
// As of Swift 5.1, extending protocols in this way is not part of the language, but there is discussion surrounding it. It would be useful (and expressive) in cases like this, but it would also complicate runtime facets of the type system. For more, see:
// https://github.com/apple/swift/blob/main/docs/GenericsManifesto.md#retroactive-protocol-refinement
