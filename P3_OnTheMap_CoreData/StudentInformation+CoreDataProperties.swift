//
//  StudentInformation+CoreDataProperties.swift
//  P3_OnTheMap_CoreData
//
//  Created by VICTOR ASSELTA on 5/20/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension StudentInformation {

    @NSManaged var firstName: String?
    @NSManaged var id: String?
    @NSManaged var lastName: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var mediaURL: String?

}
