//
//  FilmServiceTests.swift
//  OscarBestPicturesTests
//
//  Created by Yves Yang on 4/18/23.
//

import XCTest
// First import our app below in order to access data inside.
@testable import OscarBestPictures

final class FilmServiceTests: XCTestCase {
    var systemUnderTest: FilmService!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.systemUnderTest = FilmService()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.systemUnderTest = nil
    }

    func testAPI_returnSuccessfulResult() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        // Given
        var films: [Film]!
        var error: Error?
        let promise = expectation(description: "Completion handler is invoked")
        
        // When
        self.systemUnderTest.getFilms(completion: {data, shouldntHappen in
            films = data
            error = shouldntHappen
            promise.fulfill()
        })
        wait(for: [promise], timeout: 5)
    
        // Then
        XCTAssertNotNil(films)
        XCTAssertNil(error)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
