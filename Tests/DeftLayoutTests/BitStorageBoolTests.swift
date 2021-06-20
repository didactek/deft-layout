//
//  BitStorageBoolTests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-09.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import DeftLayout

class BitStorageBoolTests: XCTestCase {
    class BoolAndBit: ByteArrayDescription {
        @Position(ofByte: 1, bit: 7)
        var msb = true

        @Position(ofByte: 1, bit: 0)
        var lsb = false

        @Position(ofByte: 1, bit: 2)
        var mid = true
    }
    let coder = BoolAndBit()  // object under test

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInit() throws {
        XCTAssertEqual(coder.bytes.count, 1, "described bits should fit in single byte")
        XCTAssertEqual(coder.msb, true, "initial value preserved")
        XCTAssertEqual(coder.lsb, false, "initial value preserved")
        XCTAssertEqual(coder.mid, true, "initial value preserved")

        XCTAssert(coder.bytes[0] == 0b1000_0100, "encoding positions")
    }

    func testWrite() throws {
        coder.msb = false
        XCTAssertEqual(coder.bytes[0], 0b0000_0100, "clear top bit")

        coder.lsb = true
        XCTAssertEqual(coder.bytes[0], 0b0000_0101, "set bottom bit")
    }

    func testReadUnderlying() throws {
        coder.bytes[0] = 0xff
        XCTAssertEqual(coder.msb, true, "decoding all underlying bits set")
        XCTAssertEqual(coder.mid, true, "decoding all underlying bits set")
        XCTAssertEqual(coder.lsb, true, "decoding all underlying bits set")

        coder.bytes[0] = 0x00
        XCTAssertEqual(coder.msb, false, "decoding all underlying bits clear")
        XCTAssertEqual(coder.mid, false, "decoding all underlying bits clear")
        XCTAssertEqual(coder.lsb, false, "decoding all underlying bits clear")
    }

}
