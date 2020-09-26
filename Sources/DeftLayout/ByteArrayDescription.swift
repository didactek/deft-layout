//
//  ByteArrayDescription.swift
//  Deft -- DEvices from swiFT
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

    @propertyWrapper
    public struct Position<T: BitEmbeddable>: CoderAdapter {
        var coder: ByteCoder

        public var wrappedValue: T {
            get { decodedValue}
            set { decodedValue = newValue }
        }

        public init(wrappedValue: T, significantByte: Int, msb: Int,
             minorByte: Int, lsb: Int,
             extendNegativeBit: Bool = false) {

            self.coder = try! MultiByteCoder(significantByte: significantByte - 1, msb: msb,
                                             minorByte: minorByte - 1, lsb: lsb,
                                             signed: extendNegativeBit,
                                             storedIn: AssembledMessage.storageBuildInProgress())
            self.wrappedValue = wrappedValue
        }

        public init(wrappedValue: T, ofByte: Int, msb: Int, lsb: Int, extendNegativeBit: Bool = false) {
            self.init(wrappedValue: wrappedValue, significantByte: ofByte, msb: msb,
                      minorByte: ofByte, lsb: lsb, extendNegativeBit: extendNegativeBit)
        }

        public init(wrappedValue: T, ofByte: Int, bit: Int) {
            self.init(wrappedValue: wrappedValue, ofByte: ofByte, msb: bit, lsb: bit)
        }

        // FIXME: additional usage:
        // whole-byte positions?
        // Fixed-point fractionals (again: separate wrapper)
    }
}
