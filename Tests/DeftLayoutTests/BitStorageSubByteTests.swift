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
        let storage = CommonUnderlayment()
        XCTAssertThrowsError( try SubByte(ofByte: 2, msb: 8, lsb: 6, storedIn: storage),
                              "msb outside of the byte")

        XCTAssertThrowsError( try SubByte(ofByte: 1, msb: 2, lsb: 3, storedIn: storage),
                              "enforce lsb and msb ordering" )

        XCTAssertThrowsError( try SubByte(ofByte: 1, msb: 2, lsb: -1, storedIn: storage),
                              "lsb must not be negative" )

        XCTAssertThrowsError( try SubByte(ofByte: 0, msb: 3, lsb: 3, storedIn: storage),
                              "byte offset is one-indexed; zero or below should be disallowed" )
    }


    func testStorageAliasing() throws {
        class SomeStoreKind: BitStorageCore {
            @position(ofByte: 1, bit: 4)
            var blargh = true
        }

        let a = SomeStoreKind()
        let b = SomeStoreKind()

        XCTAssert(!(a.storage === b.storage), "BitStorageCore.init() should rotate storage to prevent aliasing")
    }
}
