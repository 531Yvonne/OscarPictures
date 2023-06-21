//
//  FilmListViewControllerTests.swift
//  OscarBestPicturesTests
//
//  Created by Yves Yang on 4/18/23.
//

import XCTest
@testable import OscarBestPictures

final class FilmListViewControllerTests: XCTestCase {
    var systemUnderTest: FilmListViewController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        self.systemUnderTest = navigationController.topViewController as? FilmListViewController
        
        UIApplication.shared.windows
//            .filter { window in return window.isKeyWindow}
// or can write as:
            .filter { $0.isKeyWindow}
            .first!
            .rootViewController = self.systemUnderTest
        
        XCTAssertNotNil(navigationController.view)
        XCTAssertNotNil(self.systemUnderTest.view)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTableView_loadsFilms() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        // Given
        let mockFilmService = MockFilmService()
        let mockFilms = [
            Film(
                named: "Fake Movie 1",
                genre: "Fake Genre",
                posterImgUrl: "https://newsroom.gy/wp-content/uploads/2020/03/fake-web.jpg",
                largePosterImgUrl: "https://happywall-img-gallery.imgix.net/17145/fake_display.jpg",
                imdbRating: 0.1,
                director: "Yves Yang",
                country: "United States",
                year: 2021,
                plot: "This is a fake but real movie"),
            Film(
                named: "Fake Movie 2",
                genre: "Fake Genre",
                posterImgUrl: "https://newsroom.gy/wp-content/uploads/2020/03/fake-web.jpg",
                largePosterImgUrl: "https://happywall-img-gallery.imgix.net/17145/fake_display.jpg",
                imdbRating: 0.2,
                director: "Yves Yang",
                country: "United States",
                year: 2022,
                plot: "This is a fake but real movie"),
            Film(
                named: "Fake Movie 3",
                genre: "Fake Genre",
                posterImgUrl: "https://newsroom.gy/wp-content/uploads/2020/03/fake-web.jpg",
                largePosterImgUrl: "https://happywall-img-gallery.imgix.net/17145/fake_display.jpg",
                imdbRating: 0.3,
                director: "Yves Yang",
                country: "United States",
                year: 2023,
                plot: "This is a fake but real movie")
        ]
        mockFilmService.mockFilms = mockFilms
        
        self.systemUnderTest.viewDidLoad()
        self.systemUnderTest.filmService = mockFilmService
        
        
        XCTAssertEqual(0, self.systemUnderTest.tableView.numberOfRows(inSection: 0))
        // When
        self.systemUnderTest.viewWillAppear(false)
        
        // Then
        XCTAssertEqual(mockFilms.count, self.systemUnderTest.films.count)
        XCTAssertEqual(mockFilms.count, self.systemUnderTest.tableView.numberOfRows(inSection: 0))
    }

    class MockFilmService: FilmService {
        var mockFilms: [Film]?
        var mockError: Error?
        
        override func getFilms(completion: @escaping ([Film]?, Error?) -> ()) {
            completion(mockFilms, mockError)
        }
        
    }
    
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
