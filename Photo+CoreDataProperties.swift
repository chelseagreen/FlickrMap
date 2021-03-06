//
//  Photo+CoreDataProperties.swift
//  TheVirtualTourist
//
//  Created by Chelsea Green on 2/2/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {
    
    @NSManaged var id: String
    @NSManaged var imageUrl: String
    @NSManaged var file: String
    @NSManaged var pin: Pin?

}