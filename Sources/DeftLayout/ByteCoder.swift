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

    /// Value in the store expanded and represenedt as a full-width UInt and sign-extended if appropriate.
    /// Writing to this value should update the underlying store; read should extract from the store.
    var wideRepresentation: UnpackedRawValue { get set }
}

enum BitfieldRangeError: Error {
    case badByteIndex
    case bitOrdering
    case byteWidthExceeded
}

