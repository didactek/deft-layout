//
//  MultiByteCoder.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-14.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

class MultiByteCoder: ByteCoder {
    private let storage: AssembledMessage
    private let mostSignificantByteIndex: Int
    private let leastSignificantByteIndex: Int
    private let msb: Int
    private let lsb: Int
    private let isSigned: Bool
    private let littleEndian: Bool

    init(significantByte: Int, msb: Int, minorByte: Int, lsb: Int, signed: Bool, storedIn: AssembledMessage, littleEndian: Bool = false) throws {
        guard significantByte >= 0 else { throw BitfieldRangeError.badByteIndex }
        guard minorByte >= 0 else { throw BitfieldRangeError.badByteIndex }

        if !littleEndian {
            guard significantByte <= minorByte else { throw BitfieldRangeError.badByteIndex }
            guard significantByte < minorByte || msb >= lsb else { throw BitfieldRangeError.bitOrdering }
        }
        else {
            guard significantByte >= minorByte else { throw BitfieldRangeError.badByteIndex }
            guard significantByte > minorByte || msb >= lsb else { throw BitfieldRangeError.bitOrdering }
        }

        guard msb >= 0 else { throw BitfieldRangeError.byteWidthExceeded }
        guard msb < 8 else { throw BitfieldRangeError.byteWidthExceeded }
        guard lsb >= 0 else { throw BitfieldRangeError.byteWidthExceeded }
        guard lsb < 8 else { throw BitfieldRangeError.byteWidthExceeded }

        storage = storedIn

        self.mostSignificantByteIndex = significantByte
        self.leastSignificantByteIndex = minorByte
        self.msb = msb
        self.lsb = lsb
        self.isSigned = signed
        self.littleEndian = littleEndian
    }

    // FIXME: unify 'raw' and 'encoded' terminology

    // traits:
    // terminology: "Mask" suggests 0 or more bits set; MaskedBit

    /// Count of bits available for coding.
    private var encodedWidth: Int {
        8 * (leastSignificantByteIndex - mostSignificantByteIndex) + msb - lsb + 1
    }

    /// Mask with (high) bits that cannot be encoded set to 1.
    private var excessMask: UInt {
        var valueMask = UInt(1) << encodedWidth
        valueMask &-= 1
        return ~valueMask
    }


    private var signBitMaskedWide: UInt {
        UInt(1) << (UInt.bitWidth - 1)
    }

    func extendingSign(of rawValue: UInt, fromPosition bit: Int) -> UInt {
        guard isSigned else {
            return rawValue
        }

        let signBitMaskedRaw = UInt(1) << (bit - 1)

        if rawValue & signBitMaskedRaw == 0 {
            // non-negative: no work to do.
            return rawValue
        }

        // excessMask *is* all the high bits that need to be sign-extended:
        return rawValue | excessMask
    }

    var wideRepresentation: UInt {
        get {
            var value = UInt(0)

            var lsb = 0
            var msb = self.msb
            for index in stride(from: mostSignificantByteIndex, through: leastSignificantByteIndex, by: littleEndian ? -1 : 1 ) {
                if index == leastSignificantByteIndex {
                    lsb = self.lsb
                }
                let bitsToAddThisPass = msb - lsb + 1
                value <<= bitsToAddThisPass
                let mask = UInt8(truncatingIfNeeded: (0b1 << bitsToAddThisPass) - 1)
                let bitsRead = (storage.bytes[index] >> lsb) & mask
                value |= UInt(bitsRead)

                msb = 7
            }
            return extendingSign(of: value, fromPosition: encodedWidth)
        }
        set {
            var remaining = newValue

            if isSigned && (newValue & signBitMaskedWide != 0) {
                assert( (remaining & excessMask) == excessMask, "negative number too negative to fit in allocated bits")
                remaining = remaining & ~excessMask  // clear the sign extension that won't appear in the encoded value
            }

            assert(remaining == (remaining & ~excessMask), "Raw value \(newValue) (possibly sign-contracted to \(remaining) will not fit starting in byte \(mostSignificantByteIndex + 1), bit \(msb)")


            // grow storage:
            while storage.bytes.count <= max(leastSignificantByteIndex, mostSignificantByteIndex) {
                storage.bytes.append(0)
            }


            // chew off from the lsb:
            var lsb = self.lsb
            var msb = 7
            for index in stride(from: leastSignificantByteIndex, through: mostSignificantByteIndex, by: littleEndian ? 1 : -1) {
                if index == mostSignificantByteIndex {
                    msb = self.msb
                }
                let bitsConsumedInThisPass = msb - lsb + 1
                let mask = UInt8(truncatingIfNeeded: (0b1 << bitsConsumedInThisPass) - 1)
                let cleared = storage.bytes[index] & ~(mask << lsb)
                let chunk = UInt8(truncatingIfNeeded: remaining) & mask
                storage.bytes[index] = cleared | (chunk << lsb)

                lsb = 0
                remaining >>= bitsConsumedInThisPass
            }
        }
    }
}
