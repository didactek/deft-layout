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
/// Implementors of this protocol are expected to store the data in a more compact form than a UInt. For instance, a `MultiByteCoder` stores only a specified number of bits in a particular offset in a Data byte array.
protocol ByteCoder {
    /// Extract raw value from its store and represent as a full-width UInt.
    var wideRepresentation: UInt { get set }

    /// Interpret fromPosition as a sign bit, and set all bits above that to the same value.
    ///
    /// If the extended value is reinterpreted as a signed Int, it will be negative if the fromPosition bit was set.
    func extendingSign(of rawValue: UInt, fromPosition bit: Int) -> UInt
}

enum BitfieldRangeError: Error {
    case badByteIndex
    case bitOrdering
    case byteWidthExceeded
}

