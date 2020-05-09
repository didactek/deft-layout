//
//  BitStorageBoolTests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-09.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

class BitStorageBoolTests: XCTestCase {
    class BoolAndBit: BitStorageCore {
        @position(SubByte(ofByte: 1, bit: 7))
        var msb = true

        @position(SubByte(ofByte: 1, bit: 0))
        var lsb = false

        @position(SubByte(ofByte: 1, bit: 2))
        var mid = true
    }
    var coder = BoolAndBit()  // object under test

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInit() throws {
        XCTAssert(coder.storage.bytes.count == 1, "described bits should fit in single byte")
        XCTAssert(coder.msb == true, "initial value preserved")
        XCTAssert(coder.lsb == false, "initial value preserved")
        XCTAssert(coder.mid == true, "initial value preserved")

        XCTAssert(coder.storage.bytes[0] == 0b1000_0100, "encoding positions")
    }

    func testWrite() throws {
        // FIXME compiler lets me alter a 'let': does this expose an error in mutation sematics?
        coder.msb = false
        XCTAssert(coder.storage.bytes[0] == 0b0000_0100, "clear top bit")

        coder.lsb = true
        XCTAssert(coder.storage.bytes[0] == 0b0000_0101, "set bottom bit")
    }

    func testReadUnderlying() throws {
        coder.storage.bytes[0] = 0xff
        XCTAssert(coder.msb == true, "decoding all underlying bits set")
        XCTAssert(coder.mid == true, "decoding all underlying bits set")
        XCTAssert(coder.lsb == true, "decoding all underlying bits set")

        coder.storage.bytes[0] = 0x00
        XCTAssert(coder.msb == false, "decoding all underlying bits clear")
        XCTAssert(coder.mid == false, "decoding all underlying bits clear")
        XCTAssert(coder.lsb == false, "decoding all underlying bits clear")
    }

}
