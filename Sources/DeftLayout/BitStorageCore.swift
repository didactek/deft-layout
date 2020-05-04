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

class BitStorageCore {
    class Storage {
        var bytes: [UInt8] = []
    }

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

    class SubByte {
        let storage: Storage
        let index: Int
        let lsb: Int
        let mask: UInt8

        init(ofByte: Int, msb: Int, lsb: Int) {
            assert(ofByte > 0)
            assert(msb >= lsb)
            assert(msb < 8)
            storage = BitStorageCore._storage
            index = ofByte - 1
            self.lsb = lsb
            mask = UInt8((0b10 << (msb - lsb)) - 1)
        }

        convenience init(ofByte: Int, bit: Int) {
            self.init(ofByte: ofByte, msb: bit, lsb: bit)
        }

        var byte: UInt8 {
            get {
                return (storage.bytes[index] >> lsb) & mask
            }
            set {
                assert(newValue == (newValue & mask), "Raw value \(newValue) will not fit in byte \(index + 1), lsb \(lsb)")
                while storage.bytes.count <= index {
                    storage.bytes.append(0)
                }
                let cleared = storage.bytes[index] & ~(mask << lsb)
                storage.bytes[index] = cleared | (newValue << lsb)
            }
        }
    }

    @propertyWrapper
    struct position<T> where T: RawRepresentable, T.RawValue == UInt8 {
        var storage: SubByte

        var wrappedValue: T {
            get {
                T(rawValue: storage.byte)!
            }
            set {
                storage.byte = newValue.rawValue
            }
        }

        init(wrappedValue: T, _ subByte: SubByte) {
            self.storage = subByte
            self.wrappedValue = wrappedValue
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

extension Bool: RawRepresentable {
    public typealias RawValue = UInt8
    public init?(rawValue: RawValue) {
        self = rawValue == 1
    }
    public var rawValue: UInt8 {
        return self ? 1 : 0
    }
}
