//
//  WordDescriptionTests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-21.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import DeftLayout

class WordDescriptionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBitEncoding() throws {
        class WordBit: WordDescription {
            @Position(bit: 6)
            var x = true

            @Position(bit: 15)
            var y = true
        }

        let object = WordBit()
        XCTAssertEqual(object.bytes[0], 0b1000_0000, "MSB first")
        XCTAssertEqual(object.bytes[1], 0b0100_0000, "LSB first")
    }

    func testStorageWidth() throws {
        class WordBit: WordDescription {
            @Position(bit: 6)
            var x = true

            @Position(bit: 15)
            var y = true
        }

        let object = WordBit()
        XCTAssertEqual(object.bytes.count, 2, "Word should be stored in two bytes")
     }

 }
