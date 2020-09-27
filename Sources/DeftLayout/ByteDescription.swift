//
//  ByteDescription.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-20.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Base class for packing bits into a single storage byte. Provides `Position` property wrappers for
/// locating `BitEmbeddeble` properties within the byte.
///
/// Example:
///
///     class FlagAndSmallValue: ByteDescription {
///        @Position(bit: 7)
///        var flag = false
///
///        @Position(msb: 4, lsb: 0)
///        var smallValue = UInt8(0b1_1111) // max value of all 5 bits set
///     }
open class ByteDescription: BitStorageCore {
    public override init() {
        super.init()
    }

    static var byteWidth: Int = 1


    /// Help derived classes map a `BitEmbeddable` property into a bit or range of bits within the managed storage byte.
    @propertyWrapper
    public struct Position<T: BitEmbeddable>: CoderAdapter {
        var coder: ByteCoder

        public var wrappedValue: T {
            get { decodedValue}
            set { decodedValue = newValue }
        }

        // FIXME: either simplify this or factor common init work into protocol
        /// Map a `BitEmbeddable` property into a range of bits within the managed storage byte.
        /// - Parameter msb: Indexed position of the property's most significant bit when stored in the managed byte.
        /// - Parameter lsb: Indexed position of the property's least significant bit when stored in the managed byte.
        public init(wrappedValue: T, msb: Int, lsb: Int, signed: Bool = false) {
            assert(msb >= 0 && msb < (ByteDescription.byteWidth * 8))
            assert(lsb >= 0 && lsb < (ByteDescription.byteWidth * 8))
            assert(msb >= lsb)

            let (msbDistanceToEnd, msbOffset) = msb.quotientAndRemainder(dividingBy: 8)
            let (lsbDistanceToEnd, lsbOffset) = lsb.quotientAndRemainder(dividingBy: 8)

            self.coder = try! MultiByteCoder(significantByte: msbDistanceToEnd, msb: msbOffset,
                                             minorByte: lsbDistanceToEnd, lsb: lsbOffset,
                                             signed: signed,
                                             storedIn: AssembledMessage.storageBuildInProgress(),
                                             littleEndian: false
            )
            self.wrappedValue = wrappedValue
        }

        /// Map a `BitRepresentable` property into a single bit of the managed storage byte.
        public init(wrappedValue: T, bit: Int) {
            self.init(wrappedValue: wrappedValue, msb: bit, lsb: bit)
        }
    }
}
