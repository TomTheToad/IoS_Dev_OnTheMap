//
//  CoreDataStack.swift
//  P3_OnTheMap_CoreData
//
//  Created by VICTOR ASSELTA on 5/22/16.
//  Adapted from the Intermediate Core Data series on raywenderlich.com
//  Many thanks to Greg Heo for the excellent course.
//
//

import Foundation
import CoreData

class CoreDataStack {
    
    /* Fields */
    static let moduleName = "P3_OnTheMap_CoreData"
    
    // Managed Object Model
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(moduleName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    // Helper to access documents directory for app
    lazy var applicationDocumentDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }()
    
    // Persistent Store Coordinator
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let persistentStoreURL = self.applicationDocumentDirectory.URLByAppendingPathComponent("\(moduleName).sqlite")
        
        // Attempt to add a persistend store to the coordinator
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: persistentStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Persistent store error! \(error)")
            }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    /* Methods */
    func saveMainContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("Error saving main managed object context! \(error)")
            }
        }
    }
}
