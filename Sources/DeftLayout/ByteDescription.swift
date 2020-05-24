//
//  ByteDescription.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-20.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

open class ByteDescription: BitStorageCore {
    public override init() {
        super.init()
    }

    static var byteWidth: Int = 1

    public struct PositionOptions: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        static let extendNegativeBit = PositionOptions(rawValue: 1 << 0)
    }

    @propertyWrapper
    public struct Position<T: BitEmbeddable>: CoderAdapter {
        var coder: ByteCoder

        public var wrappedValue: T {
            get { decodedValue}
            set { decodedValue = newValue }
        }

        // FIXME: either simplify this or factor common init work into protocol
        public init(wrappedValue: T, msb: Int, lsb: Int, _ options: PositionOptions = []) {
            assert(msb >= 0 && msb < (ByteDescription.byteWidth * 8))
            assert(lsb >= 0 && lsb < (ByteDescription.byteWidth * 8))
            assert(msb >= lsb)

            let (msbDistanceToEnd, msbOffset) = msb.quotientAndRemainder(dividingBy: 8)
            let (lsbDistanceToEnd, lsbOffset) = lsb.quotientAndRemainder(dividingBy: 8)

            self.coder = try! MultiByteCoder(significantByte: msbDistanceToEnd, msb: msbOffset,
                                             minorByte: lsbDistanceToEnd, lsb: lsbOffset,
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
