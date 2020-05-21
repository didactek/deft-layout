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
class SMBusWord: BitStorageCore {
    static var byteWidth: Int = 2

    struct PositionOptions: OptionSet {
        let rawValue: Int

        static let extendNegativeBit = PositionOptions(rawValue: 1 << 0)
    }

    @propertyWrapper
    struct Position<T: BitEmbeddable>: CoderAdapter {
        var coder: ByteCoder

        var wrappedValue: T {
            get { decodedValue}
            set { decodedValue = newValue }
        }

        init(wrappedValue: T, msb: Int, lsb: Int, _ options: PositionOptions = []) {
            assert(msb >= 0 && msb < (SMBusWord.byteWidth * 8))
            assert(lsb >= 0 && lsb < (SMBusWord.byteWidth * 8))
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
