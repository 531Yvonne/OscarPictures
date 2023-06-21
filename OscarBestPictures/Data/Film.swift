//
//  Film.swift
//  OscarBestPictures
//
//  Created by Yves Yang on 4/1/23.
//

import Foundation
import CoreData

class Film: CustomDebugStringConvertible, Codable {
    // Print the message below in the debugging output panel when click on one record.
    var debugDescription: String {
        return "Film(name: \(self.name), genre: \(self.genre))"
    }
    
    // Discover View information
    var name: String
    var genre: String
    var posterImgUrl: String
    
    // Detail View information
    var largePosterImgUrl: String
    var imdbRating: Double
    var director: String
    var country: String
    var year: Int64
    var plot: String
    var imdbUrl: String
    
    // Record related
    var id: String = "0"
    var like: Bool = false
    var confirmedWatched: Bool = false
    var addedToWatch: Bool = false
    var myComment: String = "Add Your Comments"
    var myRating: Double = 0.0
    
    // Added for extracting data from API.
    private enum CodingKeys: String, CodingKey {
        case name, genre, posterImgUrl, largePosterImgUrl, imdbRating, director, country, year, plot, imdbUrl, id
    }
    
    
    init(named name: String, genre: String, posterImgUrl: String, largePosterImgUrl: String, imdbRating: Double, director: String, country: String, year: Int64, plot: String, imdbUrl: String, like: Bool, confirmedWatched: Bool, addedToWatch: Bool, id: String, myRating: Double, myComment: String) {
    // "named" is an argument label, when construct a new Film type record: Film(named: String, genre: String)
        self.name = name
        self.genre = genre
        self.posterImgUrl = posterImgUrl
        self.largePosterImgUrl = largePosterImgUrl
        self.imdbRating = imdbRating
        self.director = director
        self.country = country
        self.year = year
        self.plot = plot
        self.imdbUrl = imdbUrl
        self.like = like
        self.confirmedWatched = confirmedWatched
        self.addedToWatch = addedToWatch
        self.id = id
        self.myComment = myComment
        self.myRating = myRating
    }
    
    
    // Map the Film class attributes to the corresponding Core Data LocalFilm entity attributes
    func toManagedObject(context: NSManagedObjectContext) -> LocalFilm {
        let localFilm = LocalFilm(context: context)
        
        localFilm.name = self.name
        localFilm.genre = self.genre
        localFilm.posterImgUrl = self.posterImgUrl
        localFilm.largePosterImgUrl = self.largePosterImgUrl
        localFilm.imdbRating = self.imdbRating
        localFilm.director = self.director
        localFilm.country = self.country
        localFilm.year = self.year
        localFilm.plot = self.plot
        localFilm.imdbUrl = self.imdbUrl
        localFilm.like = self.like
        localFilm.confirmedWatched = self.confirmedWatched
        localFilm.confirmedToWatch = self.addedToWatch
        localFilm.id = self.id
        localFilm.myRating = self.myRating
        localFilm.myComment = self.myComment
        
        return localFilm
    }
}

// Added for extracting data from API.
struct FilmResult: Codable {
    let films: [Film]
}
