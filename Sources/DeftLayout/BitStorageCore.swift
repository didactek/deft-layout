//
//  BitStorageCore.swift
//  radio
//
//  Created by Kit Transue on 2020-05-03.
//  Prototyped 2020-05-02 in BitManip project
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


open class BitStorageCore {
    public let storage: AssembledMessage

    init() {
        storage = AssembledMessage.freezeAndRotateStorage()
    }
}

