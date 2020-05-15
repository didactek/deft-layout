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

class BitStorageCore {
    let storage: AssembledMessage

    init() {
        storage = AssembledMessage.freezeAndRotateStorage()
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
                // for signed quantities, we deal with sign extension here, where we have
                // access to T.RawValue's width. N.B. RawValue is always unsigned, so
                // the truncatingIfNeeded functions won't extend sign for us.
                let raw = coder.extendSign(ofBit: T.RawValue.bitWidth, rightAlignedRawValue: UInt(truncatingIfNeeded:  newValue.rawValue))
                coder.widenedToByte = raw
            }
        }

        init(wrappedValue: T, ofByte: Int, msb: Int, lsb: Int, _ options: PositionOptions = []) {
            self.coder = try! MultiByteCoder(significantByte: ofByte, msb: msb, minorByte: ofByte, lsb: lsb, signed: options.contains(.extendNegativeBit), storedIn: AssembledMessage.storageBuildInProgress())

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
