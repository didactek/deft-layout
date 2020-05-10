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

extension RawRepresentable {
    static func requiresSignExtension() -> Bool {
        return false
    }
}

protocol ByteCoder {
    var byte: UInt8 { get set }
}

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

    class SubByte: ByteCoder {
        let storage: Storage
        let index: Int
        let msb: Int
        let lsb: Int

        let mask: UInt8

        init(ofByte: Int, checkingMsb msb: Int, checkingLsb lsb: Int) throws {
            enum RangeError: Error {
                case badByteIndex
                case bitOrdering
                case byteWidthExceeded
            }
            guard ofByte > 0 else { throw RangeError.badByteIndex }
            guard msb >= lsb else { throw RangeError.bitOrdering }
            guard msb < 8 else { throw RangeError.byteWidthExceeded }
            guard lsb >= 0 else { throw RangeError.byteWidthExceeded }

            storage = BitStorageCore._storage

            index = ofByte - 1
            self.msb = msb
            self.lsb = lsb
            mask = UInt8((0b10 << (msb - lsb)) - 1)
        }

        convenience init(ofByte: Int, msb: Int, lsb: Int) {
            try! self.init(ofByte: ofByte, checkingMsb: msb, checkingLsb: lsb)
        }

        convenience init(ofByte: Int, bit: Int) {
            try! self.init(ofByte: ofByte, checkingMsb: bit, checkingLsb: bit)
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

    class SignExtended: ByteCoder {
        let subByte: SubByte
        let signMask: UInt8
        let signFill: UInt8

        var byte: UInt8 {
            get {
                var raw = subByte.byte
                if raw & signMask != 0 {
                    raw |= signFill
                }
                return raw
            }
            set {
                var raw = newValue
                if raw & signMask != 0 {
                    assert(signFill & raw == signFill, "Raw value \(newValue) will not fit in byte \(subByte.index + 1)")
                    raw &= ~signFill
                }
                subByte.byte = raw
            }
        }

        init(subByte: SubByte) {
            self.subByte = subByte

            signMask = 1 << (subByte.msb - subByte.lsb)
            signFill = 0xff ^ (subByte.mask)
        }
    }

    @propertyWrapper
    struct position<T> where T: RawRepresentable, T.RawValue == UInt8 {
        var storage: ByteCoder

        var wrappedValue: T {
            get {
                T(rawValue: storage.byte)!
            }
            set {
                storage.byte = newValue.rawValue
            }
        }

        init(wrappedValue: T, _ subByte: SubByte) {
            if T.requiresSignExtension() {  // FIXME: doesn't get overridden
                self.storage = SignExtended(subByte: subByte)
            }
            else {
                self.storage = subByte
            }
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

extension Int8: RawRepresentable {
    public typealias RawValue = UInt8

    static func requiresSignExtension() -> Bool {
        return true
    }

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
