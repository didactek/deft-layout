//
//  BitStorageSignedTests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-09.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

class BitStorageSignedTests: XCTestCase {
    typealias SmallSigned = Int8 // Start with unsigned for TDD

    class SignedRange: BitStorageCore {
        @position(SubByte(ofByte: 1, msb: 7, lsb: 4))
        var highNibble: SmallSigned = 0

        @position(SubByte(ofByte: 2, msb: 5, lsb: 1))
        var midNibble: SmallSigned = 0

        @position(SubByte(ofByte: 3, msb: 4, lsb: 0))
        var lowNibble: SmallSigned = 0

        @position(SubByte(ofByte: 4, msb: 6, lsb: 1))
        var sixBits: SmallSigned = 0
    }
    var coder = SignedRange()  // object under test

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSignRepresentationAndMask() throws {
        let minusThree: SmallSigned = 0b1111_1011
        // msb edge
        coder.storage.bytes[0] = 0
        coder.highNibble = minusThree // FIXME: all -3 when type allows it
        XCTAssertEqual(coder.storage.bytes[0], 0b1011_0000, "two's complement, shifted four")

        coder.storage.bytes[0] = 0xff
        coder.highNibble = minusThree
        XCTAssertEqual(coder.storage.bytes[0], 0b1011_1111, "two's complement, shifted four")

        // middle of the byte
        coder.storage.bytes[1] = 0
        coder.midNibble = minusThree
        XCTAssertEqual(coder.storage.bytes[1], 0b00_1011_00, "two's complement, shifted two")

        coder.storage.bytes[1] = 0xff
        coder.midNibble = minusThree
        XCTAssertEqual(coder.storage.bytes[1], 0b11_1011_11, "two's complement, shifted two")


        // lsb edge
        coder.storage.bytes[2] = 0
        coder.lowNibble = minusThree
        XCTAssertEqual(coder.storage.bytes[1], 0b0000_1011, "two's complement")

        coder.storage.bytes[2] = 0xff
        coder.lowNibble = minusThree
        XCTAssertEqual(coder.storage.bytes[1], 0b1111_1011, "two's complement")
    }

    func testSignExtension() {
        coder.sixBits = 0b1111_1100
        XCTAssertEqual(coder.sixBits, 0b1111_1100, "top two bits should be sign-extended")

        coder.sixBits = 29
        XCTAssertEqual(coder.sixBits, 29, "no sign extension for positive values")

        coder.sixBits = -29
        XCTAssertEqual(coder.sixBits, -29, "top two bits should be sign-extended")
    }
}
