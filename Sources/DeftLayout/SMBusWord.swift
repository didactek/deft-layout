//
//  SMBusWord.swift
//  radio
//
//  Created by Kit Transue on 2020-05-17.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


/// Encode a 16-bit, little-endian word (or fractions thereof) for SMBus use.
class SMBusWord {
    static var byteWidth: Int = 2

    // FIXM: storage rotation pattern copied from BitStorageCore. Should factor.
    let storage: AssembledMessage
    init() {
        storage = AssembledMessage.freezeAndRotateStorage()
    }

    struct PositionOptions: OptionSet {
        let rawValue: Int

        static let extendNegativeBit = PositionOptions(rawValue: 1 << 0)
    }


    @propertyWrapper
    struct position<T: BitEmbeddable> {
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

        init(wrappedValue: T, msb: Int, lsb: Int, _ options: PositionOptions = []) {
            assert(lsb >= 0 && lsb <= 15)
            assert(lsb >= 0 && lsb <= 15)
            assert(msb >= lsb)

            let (msbDistanceToEnd, msbOffset) = msb.quotientAndRemainder(dividingBy: 8)
            let (lsbDistanceToEnd, lsbOffset) = lsb.quotientAndRemainder(dividingBy: 8)

            self.coder = try! MultiByteCoder(significantByte: SMBusWord.byteWidth - msbDistanceToEnd, msb: msbOffset,
                                             minorByte: SMBusWord.byteWidth - lsbDistanceToEnd, lsb: lsbOffset,
                                             signed: options.contains(.extendNegativeBit),
                                             storedIn: AssembledMessage.storageBuildInProgress(),
                                             littleEndian: true
            )
            self.wrappedValue = wrappedValue
        }

        init(wrappedValue: T, bit: Int) {
            self.init(wrappedValue: wrappedValue, msb: bit, lsb: bit)
        }
    }
}
