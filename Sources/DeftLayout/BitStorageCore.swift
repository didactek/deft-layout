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
    struct position<T> where T: RawRepresentable, T.RawValue == UInt8 {
        var coder: ByteCoder

        var wrappedValue: T {
            get {
                T(rawValue: coder.widenedToByte)!
            }
            set {
                coder.widenedToByte = newValue.rawValue
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

extension UInt8: RawRepresentable {
    public typealias RawValue = UInt8
    public init?(rawValue: RawValue) {
        self = rawValue
    }
    public var rawValue: UInt8 {
        return self
    }
}

extension Int8: RawRepresentable {
    public typealias RawValue = UInt8

    public init?(rawValue: RawValue) {
        self = Self(bitPattern: rawValue)
    }
    public var rawValue: UInt8 {
        return RawValue(bitPattern: self)
    }

}

extension Bool: RawRepresentable {
    public typealias RawValue = UInt8
    public init?(rawValue: RawValue) {
        self = rawValue == 1
    }
    public var rawValue: UInt8 {
        return self ? 1 : 0
    }
}
