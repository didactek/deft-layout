//
//  ByteCoder.swift
//  radio
//
//  Created by Kit Transue on 2020-05-11.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

protocol ByteCoder {
    var wideRepresentation: UInt { get set }
    func extendingSign(of rawValue: UInt, fromPosition bit: Int) -> UInt
}

enum BitfieldRangeError: Error {
    case badByteIndex
    case bitOrdering
    case byteWidthExceeded
}

