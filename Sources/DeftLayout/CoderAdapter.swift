//
//  CoderAdapter.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-18.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Protocol outlining procedure for moving typed BitEmebeddable values in and out of their ByteCoder storage.
///
/// When adopted by Position property wrappers, the implementation in the default extension does most of
/// the work managing the wrappedValue. The property wrapper needs only to set up the `ByteCoder` to use.
protocol CoderAdapter { // FIXME: would a different name be better? "CompressedStore"? "CodedStore"? "StoreWrapper"?
    associatedtype T: BitEmbeddable

    /// Coder to use to move value in and out of storage.
    var coder: ByteCoder { get set }

    /// Move an object of type T in or out of storage using the coder.
    ///
    /// - Note: ideally, this could be named "wrappedValue" and an extension would automatically fulfill
    /// the requirements of any property wrapper struct implementing this protocol.
    ///
    /// - Bug: I think there is a compiler bug as of Swift 5.2: when instantiating property wrappers, the
    /// compiler checks for wrappedValue without considering the extensions in scope. If extensions could
    /// provide get/set for "wrappedValue", we nevertheless get the error:
    ///
    ///      Property wrapper type 'ByteArrayDescription.position' does not contain a non-static property named 'wrappedValue'
    ///
    /// One can work around this by creating an extension that provides a get/set property with a different
    /// name from `wrappedValue` and forward to it, achieving code reuse at the cost of some boilerplate.
    var decodedValue /*wrappedValue*/: T { get set }
}

extension CoderAdapter {
    var decodedValue /*wrappedValue*/: T {
        get {
            T(rawValue: T.RawValue(truncatingIfNeeded: coder.wideRepresentation))!
        }
        set {
            coder.wideRepresentation = UInt(truncatingIfNeeded: newValue.rawValue)
        }
    }
}
