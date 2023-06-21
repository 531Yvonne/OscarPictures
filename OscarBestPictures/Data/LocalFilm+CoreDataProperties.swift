//
//  LocalFilm+CoreDataProperties.swift
//  OscarBestPictures
//
//  Created by Yves Yang on 5/17/23.
//
//

import Foundation
import CoreData


extension LocalFilm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalFilm> {
        return NSFetchRequest<LocalFilm>(entityName: "LocalFilm")
    }

    @NSManaged public var confirmedToWatch: Bool
    @NSManaged public var confirmedWatched: Bool
    @NSManaged public var country: String?
    @NSManaged public var director: String?
    @NSManaged public var genre: String?
    @NSManaged public var id: String?
    @NSManaged public var imdbRating: Double
    @NSManaged public var imdbUrl: String?
    @NSManaged public var largePosterImgUrl: String?
    @NSManaged public var like: Bool
    @NSManaged public var myRating: Double
    @NSManaged public var name: String?
    @NSManaged public var plot: String?
    @NSManaged public var posterImgUrl: String?
    @NSManaged public var watchedDate: Date?
    @NSManaged public var year: Int64
    @NSManaged public var myComment: String?

}

extension LocalFilm : Identifiable {

}
