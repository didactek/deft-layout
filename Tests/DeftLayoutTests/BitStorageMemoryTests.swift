//
//  BitStorageMemoryTests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-21.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

class BitStorageMemoryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testARC() throws {
        class OneBit: ByteDescription {
            @Position(bit: 6)
            var bit = true

            @Position(bit: 2)
            var smallerBit = false
        }

        var allocated: OneBit? = OneBit()
        weak var storage = allocated!.storage
        allocated = nil

        XCTAssertTrue(storage == nil, "storage should have been freed")
    }

}
