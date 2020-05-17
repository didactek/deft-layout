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
    let bytes = AssembledMessage()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThreeByteSpan() throws {
        let coder = try! MultiByteCoder(significantByte: 2, msb: 4, minorByte: 5, lsb: 7, signed: false, storedIn: bytes) // object under test


        coder.wideRepresentation = 0
        XCTAssertEqual(coder.wideRepresentation, 0)
        XCTAssertEqual(bytes.bytes.count, 5, "should increase buffer size to deepest byte")

        coder.wideRepresentation = 1_234_567
        XCTAssertEqual(coder.wideRepresentation, 1_234_567)

        coder.wideRepresentation = 1
        XCTAssertEqual(coder.wideRepresentation, 1)

        coder.wideRepresentation = 32
        XCTAssertEqual(coder.wideRepresentation, 32)
    }

    func testAdjacentSpan() throws {
        let coder = try! MultiByteCoder(significantByte: 1, msb: 2, minorByte: 2, lsb: 7, signed: false, storedIn: bytes) // object under test


        coder.wideRepresentation = 0
        XCTAssertEqual(coder.wideRepresentation, 0)

        coder.wideRepresentation = 9
        XCTAssertEqual(coder.wideRepresentation, 9)

        coder.wideRepresentation = 0b1101
        XCTAssertEqual(coder.wideRepresentation, 0b1101)
        XCTAssertEqual(bytes.bytes[0], 0b110)
        XCTAssertEqual(bytes.bytes[1], 0b1_000_0000)

        coder.wideRepresentation = 1
        XCTAssertEqual(coder.wideRepresentation, 1)
    }

    func testSingleByte() throws {
        let coder = try! MultiByteCoder(significantByte: 2, msb: 3, minorByte: 2, lsb: 0, signed: false, storedIn: bytes) // object under test


        coder.wideRepresentation = 0
        XCTAssertEqual(coder.wideRepresentation, 0)

        coder.wideRepresentation = 9
        XCTAssertEqual(coder.wideRepresentation, 9)

        coder.wideRepresentation = 13
        XCTAssertEqual(coder.wideRepresentation, 13)

        coder.wideRepresentation = 1
        XCTAssertEqual(coder.wideRepresentation, 1)
    }

    func testSpanning64BitUnsigned() throws {
        // 64 bits offset by 4 bits
        let coder = try! MultiByteCoder(significantByte: 1, msb: 3, minorByte: 9, lsb: 4, signed: false, storedIn: bytes) // object under test

        let reallyBig = UInt64.max - 2
        coder.wideRepresentation = UInt(reallyBig)
        XCTAssertEqual(UInt64(coder.wideRepresentation), reallyBig)
    }

    func testLittleEndian() throws {
        // three bits in major; one bit in minor
        let coder = try! MultiByteCoder(significantByte: 2, msb: 2, minorByte: 1, lsb: 7, signed: false, storedIn: bytes, littleEndian: true) // object under test

        coder.wideRepresentation = 0
        XCTAssertEqual(coder.wideRepresentation, 0)

        coder.wideRepresentation = 9
        XCTAssertEqual(coder.wideRepresentation, 9)

        coder.wideRepresentation = 0b1101
        XCTAssertEqual(coder.wideRepresentation, 0b1101)
        XCTAssertEqual(bytes.bytes[0], 0b1_000_0000, "least significant bit encoded in first byte")
        XCTAssertEqual(bytes.bytes[1], 0b110, "most-significant bits encoded in second byte")

        coder.wideRepresentation = 1
        XCTAssertEqual(coder.wideRepresentation, 1)
    }
}
