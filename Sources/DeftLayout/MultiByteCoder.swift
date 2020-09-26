//
//  MultiByteCoder.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-14.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Encoding that packs a ByteCoder.UnpackedRawValue in and out of a range of bits of a multi-byte array.
///
/// When packing, the value is truncated to the bits available. When unpacking, the value is padded with zeros
/// unless it is a signed value and the most significant packed bit is set, in which case the value is sign-extended
/// (packed with ones).
///
/// Outside the range of bits designated for storing the value, the storage is unchanged by MultiByteCoder.
/// Storage may be (and is typically) shared by different coder instances responsible for interpreting different
/// segments of the underlying storage.
class MultiByteCoder: ByteCoder {
    private let storage: AssembledMessage
    private let mostSignificantByteIndex: Int
    private let leastSignificantByteIndex: Int
    private let msb: Int
    private let lsb: Int
    private let isSigned: Bool
    private let littleEndian: Bool

    /// - Parameters:
    ///  - significantByte: Index of the byte within storage bytes that should hold the most significant bit.
    ///  - msb: Index (0...7) of the most significant bit of the `signifcantByte`.
    ///  - minorByte: Index of the byte within storage bytes that should hold the least significant bit.
    ///  - lsb: Index (0...7) of the least significant bit of the `minorByte`.
    ///  - signed: Value may be negative, and should be sign-extended when expanding.
    ///  - storedIn: Underlying storage for the packed value.
    ///  - littleEndian: If the least significant *byte* should come before the most significant in storage.
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

    /// Fill in sign bits if the stored version in its shortened form is negative.
    ///
    /// - Parameter of: Value with just the storage bits set that may need sign extension.
    private func extendingSignIfNeeded(of rawValue: UnpackedRawValue) -> UnpackedRawValue {
        guard isSigned else {
            return rawValue
        }

        let signBitMaskedRaw = UnpackedRawValue(1) << (encodedWidth - 1)

        if rawValue & signBitMaskedRaw == 0 {
            // non-negative: no work to do.
            return rawValue
        }

        // excessMask *is* all the high bits that need to be sign-extended:
        return rawValue | excessMask
    }

    var wideRepresentation: UnpackedRawValue {
        get {
            var value = UnpackedRawValue(0)

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
                value |= UnpackedRawValue(bitsRead)

                msb = 7
            }
            return extendingSignIfNeeded(of: value)
        }
        set {
            var remaining = newValue

            if isSigned && (newValue & signBitMaskedWide != 0) {
                assert( (remaining & excessMask) == excessMask, "negative number too negative to fit in allocated bits")
                remaining = remaining & ~excessMask  // clear the sign extension that won't appear in the encoded value
            }

            // FIXME: check for overflow, including negative numbers
//            assert(remaining == (remaining & ~excessMask), "Raw value \(newValue) (possibly sign-contracted to \(remaining) will not fit starting in byte \(mostSignificantByteIndex + 1), bit \(msb)")


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
