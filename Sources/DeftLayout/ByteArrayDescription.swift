//
//  ByteArrayDescription.swift
//  radio
//
//  Created by Kit Transue on 2020-05-18.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

open class ByteArrayDescription: BitStorageCore {
    public override init() {
        super.init()
    }

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

        public init(wrappedValue: T, significantByte: Int, msb: Int,
             minorByte: Int, lsb: Int,
             _ options: PositionOptions = []) {

            self.coder = try! MultiByteCoder(significantByte: significantByte - 1, msb: msb,
                                             minorByte: minorByte - 1, lsb: lsb,
                                             signed: options.contains(.extendNegativeBit),
                                             storedIn: AssembledMessage.storageBuildInProgress())
            self.wrappedValue = wrappedValue
        }

        public init(wrappedValue: T, ofByte: Int, msb: Int, lsb: Int, _ options: PositionOptions = []) {
            self.init(wrappedValue: wrappedValue, significantByte: ofByte, msb: msb,
                      minorByte: ofByte, lsb: lsb, options)
        }

        public init(wrappedValue: T, ofByte: Int, bit: Int) {
            self.init(wrappedValue: wrappedValue, ofByte: ofByte, msb: bit, lsb: bit, [])
        }

        // FIXME: additional usage:
        // whole-byte positions?
        // Fixed-point fractionals (again: separate wrapper)
    }
}
