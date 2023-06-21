//
//  LocalFilm+CoreDataClass.swift
//  OscarBestPictures
//
//  Created by Yves Yang on 5/17/23.
//
//

import Foundation
import CoreData

@objc(LocalFilm)
public class LocalFilm: NSManagedObject {
    func toFilm() -> Film {
        let film = Film(named: self.name ?? "",
                        genre: self.genre ?? "",
                        posterImgUrl: self.posterImgUrl ?? "",
                        largePosterImgUrl: self.largePosterImgUrl ?? "",
                        imdbRating: self.imdbRating,
                        director: self.director ?? "",
                        country: self.country ?? "",
                        year: self.year,
                        plot: self.plot ?? "",
                        imdbUrl: self.imdbUrl ?? "",
                        like: self.like,
                        confirmedWatched: self.confirmedWatched,
                        addedToWatch: self.confirmedToWatch,
                        id: self.id ?? "",
                        myRating: self.myRating,
                        myComment: self.myComment ?? "")
        return film
    }
}
