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
        let modelURL = Bundle.main.url(forResource: moduleName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    // Helper to access documents directory for app
    lazy var applicationDocumentDirectory: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()
    
    // Persistent Store Coordinator
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let persistentStoreURL = self.applicationDocumentDirectory.appendingPathComponent("\(moduleName).sqlite")
        
        // Attempt to add a persistend store to the coordinator
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Persistent store error! \(error)")
            }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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
        } else {
            print("No Changes to save")
        }
        print("Core Data changes saved")
    }
}
