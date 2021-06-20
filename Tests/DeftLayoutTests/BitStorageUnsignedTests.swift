//
//  BitStorageUnsignedTests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-09.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import DeftLayout

class BitStorageUnsignedTests: XCTestCase {
    class UnsignedRange: ByteArrayDescription {
        @Position(ofByte: 1, msb: 7, lsb: 4)
        var highNibble: UInt8 = 0b1010

        @Position(ofByte: 1, msb: 3, lsb: 2)
        var midWord: UInt8 = 0b00

        @Position(ofByte: 1, msb: 1, lsb: 0)
        var lastWord: Int8 = 0b11
    }
    var coder = UnsignedRange()  // object under test

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInit() throws {
        XCTAssertEqual(coder.bytes.count, 1, "described bits should fit in single byte")
        XCTAssertEqual(coder.highNibble, 0b1010, "initial value preserved")
        XCTAssertEqual(coder.midWord, 0b00, "initial value preserved")
        XCTAssertEqual(coder.lastWord, 0b11, "initial value preserved")

        XCTAssertEqual(coder.bytes[0],  0b1010_0011, "encoding positions")
    }

    func testWrite() throws {
        coder.bytes[0] = 0

        coder.lastWord = 3
        XCTAssertEqual(coder.bytes[0], 0b0000_0011, "set low bits")
        coder.midWord = 3
        XCTAssertEqual(coder.bytes[0], 0b0000_1111, "set mid bits")
        coder.highNibble = 15
        XCTAssertEqual(coder.bytes[0], 0b1111_1111, "set high bits")

        coder.highNibble = 0
        XCTAssertEqual(coder.bytes[0], 0b0000_1111, "clear high bits")
        coder.midWord = 0
        XCTAssertEqual(coder.bytes[0], 0b0000_0011, "clear mid bits")
        coder.lastWord = 0
        XCTAssertEqual(coder.bytes[0], 0b0000_0000, "clear low bits")
    }

    func testReadUnderlying() throws {
        coder.bytes[0] = 0xff
        XCTAssertEqual(coder.highNibble, 15, "decoding all underlying bits set")
        XCTAssertEqual(coder.midWord, 3, "decoding all underlying bits set")
        XCTAssertEqual(coder.lastWord, 3, "decoding all underlying bits set")

        coder.bytes[0] = 0x00
        XCTAssertEqual(coder.highNibble, 0, "decoding all underlying bits clear")
        XCTAssertEqual(coder.midWord, 0, "decoding all underlying bits clear")
        XCTAssertEqual(coder.lastWord, 0, "decoding all underlying bits clear")
    }
}
