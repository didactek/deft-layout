//
//  ByteArrayDescription.swift
//  radio
//
//  Created by Kit Transue on 2020-05-18.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

class ByteArrayDescription: BitStorageCore {
    struct PositionOptions: OptionSet {
        let rawValue: Int

        static let extendNegativeBit = PositionOptions(rawValue: 1 << 0)
    }

    @propertyWrapper
    struct Position<T: BitEmbeddable> {
        var coder: ByteCoder

        var wrappedValue: T {
            get {
                T(rawValue: T.RawValue(truncatingIfNeeded: coder.wideRepresentation))!
            }
            set {
                // for signed quantities, we deal with sign extension here, where we have
                // access to T.RawValue's width. N.B. RawValue is always unsigned, so
                // the truncatingIfNeeded functions won't extend sign for us.
                let raw = coder.extendingSign(of: UInt(truncatingIfNeeded: newValue.rawValue), fromPosition: T.RawValue.bitWidth)
                coder.wideRepresentation = raw
            }
        }

        init(wrappedValue: T, significantByte: Int, msb: Int,
             minorByte: Int, lsb: Int,
             _ options: PositionOptions = []) {

            self.coder = try! MultiByteCoder(significantByte: significantByte, msb: msb,
                                             minorByte: minorByte, lsb: lsb,
                                             signed: options.contains(.extendNegativeBit),
                                             storedIn: AssembledMessage.storageBuildInProgress())
            self.wrappedValue = wrappedValue
        }

        init(wrappedValue: T, ofByte: Int, msb: Int, lsb: Int, _ options: PositionOptions = []) {
            self.init(wrappedValue: wrappedValue, significantByte: ofByte, msb: msb,
                      minorByte: ofByte, lsb: lsb, options)
        }

        init(wrappedValue: T, ofByte: Int, bit: Int) {
            self.init(wrappedValue: wrappedValue, ofByte: ofByte, msb: bit, lsb: bit, [])
        }

        // FIXME: additional usage:
        // word-oriented positions (might be a separate wrapper?) (refactor MCP9808 to use)
        // whole-byte positions?
        // Fixed-point fractionals (again: separate wrapper)
    }
}
