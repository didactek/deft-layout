//
//  WordDescription.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-20.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Encode a 16-bit, big-endian word (or fractions thereof) for SMBus use.
open class WordDescription: BitStorageCore {
    public override init() {
        super.init()
    }

    static var byteWidth: Int = 2

    public struct PositionOptions: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let extendNegativeBit = PositionOptions(rawValue: 1 << 0)
    }

    @propertyWrapper
    public struct Position<T: BitEmbeddable>: CoderAdapter {
        var coder: ByteCoder

        public var wrappedValue: T {
            get { decodedValue}
            set { decodedValue = newValue }
        }

        public init(wrappedValue: T, msb: Int, lsb: Int, _ options: PositionOptions = []) {
            assert(msb >= 0 && msb < (WordDescription.byteWidth * 8))
            assert(lsb >= 0 && lsb < (WordDescription.byteWidth * 8))
            assert(msb >= lsb)

            let (msbDistanceToEnd, msbOffset) = msb.quotientAndRemainder(dividingBy: 8)
            let (lsbDistanceToEnd, lsbOffset) = lsb.quotientAndRemainder(dividingBy: 8)

            self.coder = try! MultiByteCoder(significantByte: WordDescription.byteWidth - msbDistanceToEnd - 1, msb: msbOffset,
                                             minorByte: WordDescription.byteWidth - lsbDistanceToEnd - 1, lsb: lsbOffset,
                                             signed: options.contains(.extendNegativeBit),
                                             storedIn: AssembledMessage.storageBuildInProgress(),
                                             littleEndian: false
            )
            self.wrappedValue = wrappedValue
        }

        public init(wrappedValue: T, bit: Int) {
            self.init(wrappedValue: wrappedValue, msb: bit, lsb: bit)
        }
    }
}
