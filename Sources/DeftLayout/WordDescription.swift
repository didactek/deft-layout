//
//  WordDescription.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-20.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Base class for packing 16 bits into two storage bytes. The storage is considerd big-endian:
/// the most-significant bits are stored first. Provides `Position` property wrappers for
/// locating `BitEmbeddeble` properties within the two-byte word.
///
/// Example:
///
///     class FlagAndMediumValue: WordDescription {
///        @Position(bit: 15)
///        var flag = false
///
///        @Position(msb: 13, lsb: 3)
///        var mediumValue = UInt16(0b111_1111_1111) // max value of all 11 bits set
///     }
open class WordDescription: BitStorageCore {
    public override init() {
        super.init()
    }

    static var byteWidth: Int = 2

    /// Help derived classes map a `BitEmbeddable` property into a bit or range of bits within the word of managed storage.
    @propertyWrapper
    public struct Position<T: BitEmbeddable>: CoderAdapter {
        var coder: ByteCoder

        public var wrappedValue: T {
            get { decodedValue}
            set { decodedValue = newValue }
        }

        /// Map a `BitEmbeddable` property into a range of bits within the managed storage.
        /// - Parameter msb: Indexed position of the property's most significant bit when stored in the managed bytes.
        /// - Parameter lsb: Indexed position of the property's least significant bit when stored in the managed bytes.
        public init(wrappedValue: T, msb: Int, lsb: Int, extendNegativeBit: Bool = false) {
            assert(msb >= 0 && msb < (WordDescription.byteWidth * 8))
            assert(lsb >= 0 && lsb < (WordDescription.byteWidth * 8))
            assert(msb >= lsb)

            let (msbDistanceToEnd, msbOffset) = msb.quotientAndRemainder(dividingBy: 8)
            let (lsbDistanceToEnd, lsbOffset) = lsb.quotientAndRemainder(dividingBy: 8)

            self.coder = try! MultiByteCoder(significantByte: WordDescription.byteWidth - msbDistanceToEnd - 1, msb: msbOffset,
                                             minorByte: WordDescription.byteWidth - lsbDistanceToEnd - 1, lsb: lsbOffset,
                                             signed: extendNegativeBit,
                                             storedIn: AssembledMessage.storageBuildInProgress(),
                                             littleEndian: false
            )
            self.wrappedValue = wrappedValue
        }

        /// Map a `BitEmbeddable` property into one bit within the managed storage.
        /// - Parameter bit: Indexed position of the property when stored in the managed bytes.
        public init(wrappedValue: T, bit: Int) {
            self.init(wrappedValue: wrappedValue, msb: bit, lsb: bit)
        }
    }
}
