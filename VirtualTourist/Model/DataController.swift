//
//  DataController.swift
//  VirtualTourist
//
//  Created by Mohammed ALZAHRANI on 09/02/2019.
//  Copyright © 2019 Mohammed ALZAHRANI. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let presistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return presistentContainer.viewContext
    }
    
    
    init(model:String) {
        presistentContainer = NSPersistentContainer(name: model)
    }
    func load(completion: (() -> Void)? = nil) {
        presistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
