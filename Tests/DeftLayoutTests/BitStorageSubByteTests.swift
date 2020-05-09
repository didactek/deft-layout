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
        XCTAssertThrowsError( try {
            let _ = try BitStorageCore.SubByte(ofByte: 2, checkingMsb: 8, checkingLsb: 6)
        }(),
                              "msb outside of the byte")

        XCTAssertThrowsError( try {
            let _ = try BitStorageCore.SubByte(ofByte: 1, checkingMsb: 2, checkingLsb: 3)
        }(),
        "enforce lsb and msb ordering" )

        XCTAssertThrowsError( try {
            let _ = try BitStorageCore.SubByte(ofByte: 1, checkingMsb: 2, checkingLsb: -1)
        }(),
        "lsb must not be negative" )

        XCTAssertThrowsError( try {
            let _ = try BitStorageCore.SubByte(ofByte: 0, checkingMsb: 3, checkingLsb: 3)
        }(),
        "byte offset is one-indexed; zero or below should be disallowed" )
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
