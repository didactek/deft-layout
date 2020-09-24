//
//  ByteCoder.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-11.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Requirements for accessing widened/raw representations of values.
///
/// Implementors of this protocol are expected to store the data in a more compact form than a UInt.
/// For instance, a `MultiByteCoder` stores only a specified number of bits in a particular offset in a Data byte array.
protocol ByteCoder {
    /// Extract raw value from its store and represent as a full-width UInt.
    var wideRepresentation: UInt { get set }

    /// Extend the sign bit of a BitEmbeddable value **if appropriate for the intemediate type**.
    ///
    /// This is used when converting a BitEmbeddable RawValue type to a UInt for storage or conversion.
    /// If the ByteCoder is encoding an unsigned type, then this will return the rawValue passed to it.
    /// If the ByteCoder encodes a signed type and the fromPosition bit is set, the sign is extended to the width of the UInt.
    func extendingSignIfNeeded(of rawValue: UInt, fromPosition bit: Int) -> UInt
}

enum BitfieldRangeError: Error {
    case badByteIndex
    case bitOrdering
    case byteWidthExceeded
}

