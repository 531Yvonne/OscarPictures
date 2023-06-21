//
//  FilmTest.swift
//  OscarBestPicturesTests
//
//  Created by Yves Yang on 4/14/23.
//

import XCTest
// Import our app below in order to access data inside.
@testable import OscarBestPictures

final class FilmTest: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testFilmDebugDescription() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        // Given
        let subjectUnderTest = Film(
            named: "Fake Movie",
            genre: "Fake Genre",
            posterImgUrl: "https://newsroom.gy/wp-content/uploads/2020/03/fake-web.jpg",
            largePosterImgUrl: "https://happywall-img-gallery.imgix.net/17145/fake_display.jpg",
            imdbRating: 0.1,
            director: "Yves Yang",
            country: "United States",
            year: 2023,
            plot: "This is a fake but real movie")
        
        // When
        let actualValue = subjectUnderTest.debugDescription // debugDescription is a property defined in Film class file.
        
        // Then
        let expectedValue = "Film(name: Fake Movie, genre: Fake Genre)"
        XCTAssertEqual(actualValue, expectedValue)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
