//
//  CoderAdapter.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-18.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Protocol for moving typed BitEmebeddable values in and out of their ByteCoder storage.
protocol CoderAdapter {
    associatedtype T: BitEmbeddable
    var coder: ByteCoder { get set }

    /// Encode or decode an object of type T.
    ///
    /// Note: ideally, this could be named "wrappedValue" and an extension would automatically fulfill the requirements of any property wrapper struct implementing this protocol.
    /// I think there is a compiler bug as of Swift 5.2: when instantiating property wrappers, the compiler checks for wrappedValue without considering the extensions in scope. If extensions could provide get/set for "wrappedValue", we nevertheless get the error:
    ///     Property wrapper type 'ByteArrayDescription.position' does not contain a non-static property named 'wrappedValue'
    /// One can work around this by creating an extension that provides a value with a different name and forward to it,
    /// achieving code reuse at the cost of some boilerplate.
    var decodedValue: T { get set }
}

extension CoderAdapter {
    var decodedValue /*wrappedValue*/: T {
        get {
            T(rawValue: T.RawValue(truncatingIfNeeded: coder.wideRepresentation))!
        }
        set {
            let zeroPadded = UInt(truncatingIfNeeded: newValue.rawValue)
            coder.wideRepresentation = coder.extendingSignIfNeeded(of: zeroPadded, fromPosition: T.RawValue.bitWidth)
        }
    }
}
