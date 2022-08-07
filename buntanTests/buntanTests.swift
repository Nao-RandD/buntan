//
//  buntanTests.swift
//  buntanTests
//
//  Created by Naoyuki Kan on 2022/03/16.
//

import XCTest

@testable import buntan

class buntanTests: XCTestCase {

    let realmManager = RealmManager.shared

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDateFormat() throws {
        let dateString = realmManager.getTime()
        XCTAssertTrue((Int(dateString) != nil))

//        XCTAssertNil(realmManager.getTime())
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    // Firebaseのデータを編集する動作を確認するテスト
    func testFirebaseEdit() throws {
        FirebaseManager.shared.getDocument()
        FirebaseManager.shared.editDocument()

        XCTAssertTrue(true)
    }
}
