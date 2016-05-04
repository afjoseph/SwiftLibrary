//
//  Book+CoreDataProperties.swift
//  SwiftLibrary
//
//  Created by Abdullah on 4/10/16.
//  Copyright © 2016 Mindvalley. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Book {

    @NSManaged var author: String?
    @NSManaged var desc: String?
    @NSManaged var descUri: String?
    @NSManaged var id: String?
    @NSManaged var imageURi: String?
    @NSManaged var title: String?
    @NSManaged var rating: NSNumber?
    @NSManaged var publishDate: String?

}
