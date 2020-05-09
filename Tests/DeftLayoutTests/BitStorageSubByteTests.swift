//
//  BitStorageSubByteTests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-09.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

class BitStorageSubByteTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitBounds() throws {
//        var subByte = BitStorageCore.SubByte(ofByte: 2, bit: 3)
    }

    func testStorageAliasing() throws {
        class SomeStoreKind: BitStorageCore {
            @position(SubByte(ofByte: 1, bit: 4))
            var blargh = true
        }

        let a = SomeStoreKind()
        let b = SomeStoreKind()

        XCTAssert(!(a.storage === b.storage), "BitStorageCore.init() should rotate storage to prevent aliasing")
    }
}
