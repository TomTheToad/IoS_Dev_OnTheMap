//
//  StudentLocation+CoreDataProperties.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 5/25/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension StudentLocation {

    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var studentID: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var mediaURL: String?
    @NSManaged var parseID: String?

}
