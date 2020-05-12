//
//  ByteCoder.swift
//  radio
//
//  Created by Kit Transue on 2020-05-11.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

protocol ByteCoder {
    var widenedToByte: UInt8 { get set }
}

class SubByte: ByteCoder {
    let storage: Storage
    let index: Int
    let msb: Int
    let lsb: Int

    let mask: UInt8

    init(ofByte: Int, msb: Int, lsb: Int, storedIn: Storage) throws {
        enum RangeError: Error {
            case badByteIndex
            case bitOrdering
            case byteWidthExceeded
        }
        guard ofByte > 0 else { throw RangeError.badByteIndex }
        guard msb >= lsb else { throw RangeError.bitOrdering }
        guard msb < 8 else { throw RangeError.byteWidthExceeded }
        guard lsb >= 0 else { throw RangeError.byteWidthExceeded }

        storage = storedIn

        index = ofByte - 1
        self.msb = msb
        self.lsb = lsb
        mask = UInt8((0b10 << (msb - lsb)) - 1)
    }

    var widenedToByte: UInt8 {
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
    let unsignedRepresentation: SubByte
    let signMask: UInt8
    let signFill: UInt8

    var widenedToByte: UInt8 {
        get {
            var raw = unsignedRepresentation.widenedToByte
            if raw & signMask != 0 {
                raw |= signFill
            }
            return raw
        }
        set {
            var raw = newValue
            if raw & signMask != 0 {
                assert(signFill & raw == signFill, "Raw value \(newValue) will not fit in byte \(unsignedRepresentation.index + 1)")
                raw &= ~signFill
            }
            unsignedRepresentation.widenedToByte = raw
        }
    }

    init(ofByte: Int, msb: Int, lsb: Int, storedIn: Storage) throws {
        unsignedRepresentation = try SubByte(ofByte: ofByte, msb: msb, lsb: lsb, storedIn: storedIn)

        signMask = 1 << (msb - lsb)
        signFill = 0xff ^ unsignedRepresentation.mask
    }
}

