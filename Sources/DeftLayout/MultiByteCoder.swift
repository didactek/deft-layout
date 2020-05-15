//
//  MultiByteCoder.swift
//  radio
//
//  Created by Kit Transue on 2020-05-14.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

class MultiByteCoder {
    let storage: AssembledMessage
    let startIndex: Int
    let endIndex: Int
    let msb: Int
    let lsb: Int

    init(significantByte: Int, msb: Int, minorByte: Int, lsb: Int, storedIn: AssembledMessage) throws {
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
    }

    var widenedToByte: UInt {
        get {
            let topByteMask = UInt8((0b10 << msb) - 1)
            var value = UInt(storage.bytes[startIndex] & topByteMask)
            if startIndex < endIndex {
                for index in (startIndex + 1)...endIndex {
                    value = value << 8
                    value += UInt(storage.bytes[index])
                }
            }
            value = value >> lsb
            return value
        }
        set {
            // FIXME: range checking...
//            assert(newValue == (newValue & mask), "Raw value \(newValue) will not fit in byte \(index + 1), lsb \(lsb)")
            // grow storage:
            while storage.bytes.count <= endIndex {
                storage.bytes.append(0)
            }

            var remaining = newValue
            // chew off from the lsb:
            var lsb = self.lsb
            for index in stride(from: endIndex, to: startIndex, by: -1) {
                let bitsConsumedInThisPass = 8 - lsb
                let mask = UInt8((0b1 << bitsConsumedInThisPass) - 1)
                let cleared = storage.bytes[index] & ~(mask << lsb)
                let chunk = UInt8(truncatingIfNeeded: remaining) & mask
                storage.bytes[index] = cleared | (chunk << lsb)

                lsb = 0
                remaining = remaining >> bitsConsumedInThisPass
            }
            assert(msb > lsb, "should still be work left to do")
            let mask = UInt8((0b10 << (msb - lsb)) - 1)
            //assert(index == startIndex, "I think?")
            let cleared = storage.bytes[startIndex] & ~(mask << lsb)
            storage.bytes[startIndex] = cleared | (UInt8(remaining) << lsb)
        }
    }
}
