//
//  MultiByteCoderTests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-14.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

class MultiByteCoderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThreeByteSpan() throws {
        let bytes = AssembledMessage()

        let coder = try! MultiByteCoder(significantByte: 2, msb: 4, minorByte: 5, lsb: 7, signed: false, storedIn: bytes) // object under test


        coder.widenedToByte = 0
        XCTAssertEqual(coder.widenedToByte, 0)
        XCTAssertEqual(bytes.bytes.count, 5, "should increase buffer size to deepest byte")

        coder.widenedToByte = 1_234_567
        XCTAssertEqual(coder.widenedToByte, 1_234_567)

        coder.widenedToByte = 1
        XCTAssertEqual(coder.widenedToByte, 1)

        coder.widenedToByte = 32
        XCTAssertEqual(coder.widenedToByte, 32)
    }

    func testAdjacentSpan() throws {
        let bytes = AssembledMessage()

        let coder = try! MultiByteCoder(significantByte: 1, msb: 2, minorByte: 2, lsb: 7, signed: false, storedIn: bytes) // object under test


        coder.widenedToByte = 0
        XCTAssertEqual(coder.widenedToByte, 0)

        coder.widenedToByte = 9
        XCTAssertEqual(coder.widenedToByte, 9)

        coder.widenedToByte = 13
        XCTAssertEqual(coder.widenedToByte, 13)

        coder.widenedToByte = 1
        XCTAssertEqual(coder.widenedToByte, 1)
    }

    func testSingleByte() throws {
        let bytes = AssembledMessage()

        let coder = try! MultiByteCoder(significantByte: 2, msb: 3, minorByte: 2, lsb: 0, signed: false, storedIn: bytes) // object under test


        coder.widenedToByte = 0
        XCTAssertEqual(coder.widenedToByte, 0)

        coder.widenedToByte = 9
        XCTAssertEqual(coder.widenedToByte, 9)

        coder.widenedToByte = 13
        XCTAssertEqual(coder.widenedToByte, 13)

        coder.widenedToByte = 1
        XCTAssertEqual(coder.widenedToByte, 1)
    }
}
