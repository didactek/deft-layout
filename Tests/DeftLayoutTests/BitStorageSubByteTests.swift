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
        let storage = AssembledMessage()
        XCTAssertThrowsError( try MultiByteCoder(significantByte: 2, msb: 8, minorByte: 2, lsb: 6, signed: false, storedIn: storage),
                              "msb outside of the byte")

        XCTAssertThrowsError( try MultiByteCoder(significantByte: 1, msb: 2, minorByte: 1, lsb: 3, signed: false, storedIn: storage),
                              "enforce lsb and msb ordering" )

        XCTAssertThrowsError( try MultiByteCoder(significantByte: 1, msb: 2, minorByte: 1, lsb: -1, signed: false, storedIn: storage),
                              "lsb must not be negative" )

        XCTAssertThrowsError( try MultiByteCoder(significantByte: 0, msb: 3, minorByte: 0, lsb: 3, signed: false, storedIn: storage),
                              "byte offset is one-indexed; zero or below should be disallowed" )
    }


    func testStorageAliasing() throws {
        class SomeStoreKind: ByteArrayDescription {
            @Position(ofByte: 1, bit: 4)
            var blargh = true
        }

        let a = SomeStoreKind()
        let b = SomeStoreKind()

        XCTAssert(!(a.storage === b.storage), "BitStorageCore.init() should rotate storage to prevent aliasing")
    }
}
