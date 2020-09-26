//
//  ByteCoder.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-11.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Requirements for retreiving and storing a value while treating it as a widened, raw representation.
///
/// Implementors of this protocol are expected to store the data in a more compact form than a UInt.
/// See`MultiByteCoder`, which stores a specified number of bits into set of bits in a Data byte array.
protocol ByteCoder {
    typealias UnpackedRawValue = UInt

    /// Value in the store expanded and represenedt as a full-width UInt.
    /// Writing to this value should update the underlying store; read should extract from the store.
    var wideRepresentation: UnpackedRawValue { get set }

    /// Extend the sign bit of a BitEmbeddable value **if appropriate for the intermediate type**.
    ///
    /// This is used when converting a BitEmbeddable RawValue type to a UInt for storage or conversion.
    /// If the ByteCoder is encoding an unsigned type, then this will return the rawValue passed to it.
    /// If the ByteCoder encodes a signed type and the fromPosition bit is set, the sign is extended to the width of the UInt.
    func extendingSignIfNeeded(of rawValue: UnpackedRawValue, fromPosition bit: Int) -> UnpackedRawValue
}

enum BitfieldRangeError: Error {
    case badByteIndex
    case bitOrdering
    case byteWidthExceeded
}

