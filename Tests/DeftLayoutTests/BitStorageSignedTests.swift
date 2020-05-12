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
    typealias SmallSigned = Int8

    class SignedRange: BitStorageCore {
        @position(ofByte: 1, msb: 7, lsb: 4, .extendNegativeBit)
        var highNibble: SmallSigned = 0

        @position(ofByte: 2, msb: 5, lsb: 2, .extendNegativeBit)
        var midNibble: SmallSigned = 0

        @position(ofByte: 3, msb: 3, lsb: 0, .extendNegativeBit)
        var lowNibble: SmallSigned = 0

        @position(ofByte: 4, msb: 6, lsb: 1, .extendNegativeBit)
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
        let minusThree: SmallSigned = -3  // 1111_1101 in two's complement
        // msb edge
        coder.storage.bytes[0] = 0
        coder.highNibble = minusThree // FIXME: all -3 when type allows it
        XCTAssertEqual(coder.storage.bytes[0], 0b1101_0000, "got: \(String(coder.storage.bytes[0], radix: 2))")

        coder.storage.bytes[0] = 0xff
        coder.highNibble = minusThree
        XCTAssertEqual(coder.storage.bytes[0], 0b1101_1111, "got: \(String(coder.storage.bytes[0], radix: 2))")

        // middle of the byte
        coder.storage.bytes[1] = 0
        coder.midNibble = minusThree
        XCTAssertEqual(coder.storage.bytes[1], 0b00_1101_00, "got: \(String(coder.storage.bytes[1], radix: 2))")

        coder.storage.bytes[1] = 0xff
        coder.midNibble = minusThree
        XCTAssertEqual(coder.storage.bytes[1], 0b11_1101_11, "got: \(String(coder.storage.bytes[1], radix: 2))")


        // lsb edge
        coder.storage.bytes[2] = 0
        coder.lowNibble = minusThree
        XCTAssertEqual(coder.storage.bytes[2], 0b0000_1101, "got: \(String(coder.storage.bytes[2], radix: 2))")

        coder.storage.bytes[2] = 0xff
        coder.lowNibble = minusThree
        XCTAssertEqual(coder.storage.bytes[2], 0b1111_1101, "got: \(String(coder.storage.bytes[2], radix: 2))")
    }

    func testSignExtension() throws {
        coder.sixBits = -4
        XCTAssertEqual(coder.sixBits, -4, "top two bits should be sign-extended")

        coder.sixBits = 29
        XCTAssertEqual(coder.sixBits, 29, "no sign extension for positive values")

        coder.sixBits = -29
        XCTAssertEqual(coder.sixBits, -29, "top two bits should be sign-extended")
    }
}
