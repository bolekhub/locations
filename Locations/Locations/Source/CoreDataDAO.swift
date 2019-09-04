//
//  CoreDataRepository.swift
//  VODApp
//
//  Created by Boris Chirino on 23/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import CoreData

/// specific implementation to save items with coreData. Due to persistent container must be
/// the same along all app. This class representing coredata storage its a singleton.
class CoreDataDAO: DAOConformable  {
    
    /// singleton instance
    static let shared: CoreDataDAO = CoreDataDAO()
    
    /// object representing core data stack.
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                debugPrint("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    private init(){}
    
    /// context to be used by main thread
    lazy var mainContext: NSManagedObjectContext? = {
        [unowned self] in
        return self.persistentContainer.viewContext
        }()
    
    /// background context
    lazy var privateContext: NSManagedObjectContext? = {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = self.mainContext
        return privateMOC
            //self.persistentContainer.newBackgroundContext()
    }()
    
    /// return the specified fetch request
    ///
    /// - Parameter name: the name of the fetchrequest declared in the model
    /// see (VODAppTest.xcdatamodel) FETCH REQUESTS section for more detail
    /// - Returns: NSFetchRequest<NSFetchRequestResult>?
    private func fetchTemplate(withname name : String) -> NSFetchRequest<NSFetchRequestResult>? {
        return self.persistentContainer.managedObjectModel.fetchRequestTemplate(forName: name)
    }
    
    func batchBackgroundSave(fromModel itemsVO: [CameraMetaDataVO], completion: @escaping (Bool) -> Void) {
        
        guard let ctx = self.privateContext else {
            return
        }
        
        ctx.perform { [weak self] in
            
            itemsVO.forEach { (metaDataItem) in
                
                if let existingEntity = self?.getBy(id: metaDataItem.id, context: ctx) {
                    existingEntity.title = metaDataItem.title
                    existingEntity.direction = metaDataItem.direction
                    existingEntity.url = metaDataItem.stringUrl
                    existingEntity.identifier = metaDataItem.id
                    existingEntity.timestamp = Date.timeStamp()
                    existingEntity.lat = metaDataItem.latitude
                    existingEntity.lon = metaDataItem.longitude
                    existingEntity.region = metaDataItem.region
                } else {
                    let entity = TrafficCameraItem(context: ctx)
                    entity.title = metaDataItem.title
                    entity.direction = metaDataItem.direction
                    entity.url = metaDataItem.stringUrl
                    entity.identifier = metaDataItem.id
                    entity.timestamp = Date.timeStamp()
                    entity.lat = metaDataItem.latitude
                    entity.lon = metaDataItem.longitude
                    entity.region = metaDataItem.region
                }
            }
            
            self?.saveContext(context: ctx)
            completion(true)
        }
    }
    
    
    func getBy(id: String, context: NSManagedObjectContext?) -> TrafficCameraItem? {
        
        let context = context == nil ? self.mainContext : self.privateContext
        let findFetchRequest =
            self.persistentContainer.managedObjectModel.fetchRequestFromTemplate(withName: "getById",
                                                                                 substitutionVariables: ["id" : id])
        var result: TrafficCameraItem?
        do {
            
            let fetch_result = try context?.fetch(findFetchRequest!) as? [TrafficCameraItem]
            guard !(fetch_result?.isEmpty)! else {
                return nil
            }
            result = fetch_result?.first
        } catch {
            
            print("A problem occured while getting entity. Error : \(error)")
        }
        
        return result
    }
    
    func getAll() -> [TrafficCameraItem]? {
        
        let getAllCachedRequest = self.fetchTemplate(withname: "getAllCached")
        var result: [TrafficCameraItem]?
        
        do {
            let fetch_result = try self.mainContext?.fetch(getAllCachedRequest!) as? [TrafficCameraItem]
            result = fetch_result
        } catch {
            print("A problem occured while getting entity. Error : \(error)")
        }
        return result
    }
    
    
    private func saveContext (context :NSManagedObjectContext) {
        
        if context.parent != nil {
            do {
                try context.save()
                context.parent?.performAndWait({
                    
                    do{
                        try context.parent?.save()
                    }catch{
                        fatalError("Error saving main context \(error)")
                    }
                    
                })
            } catch  {
                fatalError("Error saving private context \(error)")
                
            }
        }else {
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
            
            
        }
    }
    
}



extension Date {
    
    static func timeStamp() -> TimeInterval {
        let now = Date.init()
        return now.timeIntervalSince1970
    }
    
    static func timestamp(fromTimeInterval interval: TimeInterval) -> TimeInterval{
        let date = Date.init(timeIntervalSince1970: interval)
        return date.timeIntervalSince1970
    }
}
