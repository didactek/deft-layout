//
//  CoderAdapter.swift
//  radio
//
//  Created by Kit Transue on 2020-05-18.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

protocol CoderAdapter {
    associatedtype T: BitEmbeddable
    var coder: ByteCoder { get set }

    var decodedValue: T { get set }
}

extension CoderAdapter {
    // I think there is a compiler bug: in instantiating property wrappers, the compiler checks for wrappedValue before filling in the extensions in scope, giving the error:
    // Property wrapper type 'ByteArrayDescription.position' does not contain a non-static property named 'wrappedValue'
    // One can work around this by creating an extension that provides a value with a different name and forward to it:
    var decodedValue /*wrappedValue*/: T {
        get {
            T(rawValue: T.RawValue(truncatingIfNeeded: coder.wideRepresentation))!
        }
        set {
            // for signed quantities, we deal with sign extension here, where we have
            // access to T.RawValue's width. N.B. RawValue is always unsigned, so
            // the truncatingIfNeeded functions won't extend sign for us.
            let raw = coder.extendingSign(of: UInt(truncatingIfNeeded: newValue.rawValue), fromPosition: T.RawValue.bitWidth)
            coder.wideRepresentation = raw
        }
    }
}
