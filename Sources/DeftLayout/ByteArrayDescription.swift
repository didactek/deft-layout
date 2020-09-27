//
//  ByteArrayDescription.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-18.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Base class for packing bits into a range of bytes. Provides `Position` property wrappers for
/// locating `BitEmbeddeble` properties within the storage.
///
/// Example:
///
///     class SomeMappedValues: ByteArrayDescription {
///        @Position(ofByte: 1, bit: 7)
///        var leadingFlag = false
///
///        @Position(significantByte: 1, msb: 4,
///                  minorByte: 3, lsb: 5, extendNegativeBit: true)
///        var spanningSignedWord: Int16 = -1
///
///        @Position(ofByte: 3, msb: 4, lsb: 0)
///        var smallValue = UInt8(0b1_1111) // max value of all 5 bits set
///     }
/// - Important: Byte positions are 1-indexed to align with datasheets.
open class ByteArrayDescription: BitStorageCore {
    public override init() {
        super.init()
    }

    /// Help derived classes map a `BitEmbeddable` property into a bit or range of bits within the managed storage.
    @propertyWrapper
    public struct Position<T: BitEmbeddable>: CoderAdapter {
        var coder: ByteCoder

        public var wrappedValue: T {
            get { decodedValue}
            set { decodedValue = newValue }
        }

        /// Map a `BitEmbeddable` property into a range of bits within the managed storage byte array.
        /// - Parameter significantByte: Position (starting from 1) of the byte within storage bytes that should hold the most significant bit.
        /// - Parameter msb: Index (0...7) of the most significant bit of the `signifcantByte`.
        /// - Parameter minorByte: Position (starting from 1) of the byte within storage bytes that should hold the least significant bit.
        /// - Parameter lsb: Index (0...7) of the least significant bit of the `minorByte`.
        /// - Parameter extendNegativeBit: Value may be negative, and should be sign-extended when expanding.
        public init(wrappedValue: T, significantByte: Int, msb: Int,
             minorByte: Int, lsb: Int,
             extendNegativeBit: Bool = false) {

            self.coder = try! MultiByteCoder(significantByte: significantByte - 1, msb: msb,
                                             minorByte: minorByte - 1, lsb: lsb,
                                             signed: extendNegativeBit,
                                             storedIn: AssembledMessage.storageBuildInProgress())
            self.wrappedValue = wrappedValue
        }

        /// Map a `BitEmbeddable` property into a range of bits into a single byte within the managed storage array.
        /// - Parameter ofByte: Position (starting from 1) of the byte within storage that should hold the bits.
        /// - Parameter msb: Index (0...7) of the most significant bit of the `ofByte`.
        /// - Parameter lsb: Index (0...7) of the least significant bit of the `ofByte`.
        /// - Parameter extendNegativeBit: Value may be negative, and should be sign-extended when expanding.
        public init(wrappedValue: T, ofByte: Int, msb: Int, lsb: Int, extendNegativeBit: Bool = false) {
            self.init(wrappedValue: wrappedValue, significantByte: ofByte, msb: msb,
                      minorByte: ofByte, lsb: lsb, extendNegativeBit: extendNegativeBit)
        }

        /// Map a `BitEmbeddable` property into one bit of a single byte within the managed storage array.
        /// - Parameter ofByte: Position (starting from 1) of the byte within storage that should hold the bit.
        /// - Parameter bit: Index (0...7) of the bit of the `ofByte` to store.
        public init(wrappedValue: T, ofByte: Int, bit: Int) {
            self.init(wrappedValue: wrappedValue, ofByte: ofByte, msb: bit, lsb: bit)
        }

        // FIXME: additional usage:
        // whole-byte positions?
        // Fixed-point fractionals (again: separate wrapper)
    }
}
