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
//    static var isSigned: Bool { get }
}

class Storage {
    var bytes: [UInt8] = []
}

class BitStorageCore {
    // SubByte will take references from this pool
    // for all its property wrappers...
    private static var _storage = Storage()

    let storage: Storage

    required init() {
        // HACK HACK HACK BARF BARF BARF:
        storage = Self._storage
        // rotate the factory
        // ...and when construction is done, roll over for the next instantiation
        Self._storage = Storage()
    }

    struct PositionOptions: OptionSet {
        let rawValue: Int

        static let extendNegativeBit = PositionOptions(rawValue: 1 << 0)
    }


    @propertyWrapper
    struct position<T> where T: BitEmbeddable {
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
                self.coder = try! SignExtended(ofByte: ofByte, msb: msb, lsb: lsb, storedIn: BitStorageCore._storage)
            }
            else {
                self.coder = try! SubByte(ofByte: ofByte, msb: msb, lsb: lsb, storedIn: BitStorageCore._storage)
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

extension Bool: BitEmbeddable {
    static var isSigned: Bool {
        false
    }

    public typealias RawValue = UInt8
    public init?(rawValue: RawValue) {
        self = rawValue == 1
    }
    public var rawValue: UInt8 {
        return self ? 1 : 0
    }
}


// how do I assert that some RawRepresentables can be adapted to BitEmbeddable
// where RawValue is a FixedWidthInteger?
//extension RawRepresentable: BitEmbeddable where RawValue: FixedWidthInteger

// This doesn't do anything:
//extension RawRepresentable where Self: BitEmbeddable {
////    static var isSigned: Bool = false
//}
