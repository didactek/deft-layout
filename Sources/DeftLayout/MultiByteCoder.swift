//
//  MultiByteCoder.swift
//  radio
//
//  Created by Kit Transue on 2020-05-14.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

class MultiByteCoder: ByteCoder {
    let storage: AssembledMessage
    let startIndex: Int
    let endIndex: Int
    let msb: Int
    let lsb: Int
    let isSigned: Bool

    init(significantByte: Int, msb: Int, minorByte: Int, lsb: Int, signed: Bool, storedIn: AssembledMessage) throws {
        guard significantByte > 0 else { throw BitfieldRangeError.badByteIndex }
        guard significantByte <= minorByte else { throw BitfieldRangeError.badByteIndex }
        guard significantByte < minorByte || msb >= lsb else { throw BitfieldRangeError.bitOrdering }

        guard msb >= 0 else { throw BitfieldRangeError.byteWidthExceeded }
        guard msb < 8 else { throw BitfieldRangeError.byteWidthExceeded }
        guard lsb >= 0 else { throw BitfieldRangeError.byteWidthExceeded }
        guard lsb < 8 else { throw BitfieldRangeError.byteWidthExceeded }

        storage = storedIn

        self.startIndex = significantByte - 1
        self.endIndex = minorByte - 1
        self.msb = msb
        self.lsb = lsb
        self.isSigned = signed
    }

    // FIXME: unify 'raw' and 'encoded' terminology

    // traits:
    // terminology: "Mask" suggests 0 or more bits set; MaskedBit

    /// Count of bits available for coding.
    var encodedWidth: Int {
        8 * (endIndex - startIndex) + msb - lsb + 1
    }

    /// Mask with (high) bits that cannot be encoded set to 1.
    var excessMask: UInt {
        let valueMask = (UInt(1) << encodedWidth) - 1
        return ~valueMask
    }


    var signBitMaskedWide: UInt {
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
            // FIXME: clarify
            let topByteMask = UInt8((0b10 << msb) - 1)
            var value = UInt(storage.bytes[startIndex] & topByteMask)
            if startIndex < endIndex {
                for index in (startIndex + 1)...endIndex {
                    value = value << 8
                    value += UInt(storage.bytes[index])
                }
            }
            value = value >> lsb  // FIXME: we may have overflowed at this point if lsb + width > UInt.bitWidth

            return extendingSign(of: value, fromPosition: encodedWidth)
        }
        set {
            var remaining = newValue

            if isSigned{
                print("value:", Int(truncatingIfNeeded: newValue),
                      "as:", String(newValue, radix: 2),
                      "signBit:", String(signBitMaskedWide, radix: 2),
                      "mask", String(excessMask, radix: 2))
            }
            if isSigned && (newValue & signBitMaskedWide != 0) {
                assert( (remaining & excessMask) == excessMask, "negative number too negative to fit in allocated bits")
                remaining = remaining & ~excessMask  // clear the sign extension that won't appear in the encoded value
            }

            assert(remaining == (remaining & ~excessMask), "Raw value \(newValue) (possibly sign-contracted to \(remaining) will not fit starting in byte \(startIndex + 1), bit \(msb)")


            // grow storage:
            while storage.bytes.count <= endIndex {
                storage.bytes.append(0)
            }


            // chew off from the lsb:
            var lsb = self.lsb
            var msb = 7
            for index in stride(from: endIndex, through: startIndex, by: -1) {
                if index == startIndex {
                    msb = self.msb
                }
                let bitsConsumedInThisPass = msb - lsb + 1
                let mask = UInt8(truncatingIfNeeded: (0b1 << bitsConsumedInThisPass) - 1)
                let cleared = storage.bytes[index] & ~(mask << lsb)
                let chunk = UInt8(truncatingIfNeeded: remaining) & mask
                storage.bytes[index] = cleared | (chunk << lsb)

                lsb = 0
                remaining = remaining >> bitsConsumedInThisPass
            }
        }
    }
}
