//
//  Photo.swift
//  TheVirtualTourist
//
//  Created by Chelsea Green on 2/2/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


@objc(Photo)
class Photo: NSManagedObject {
    
    @NSManaged var url: String
    @NSManaged var file: String
    @NSManaged var id: String
    @NSManaged var pin: Pin?
    
    struct Keys {
        static let Url = "url_m"
        static let ID = "id"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        url = dictionary[Keys.Url] as! String
        id = dictionary[Keys.ID] as! String
        file = pathForIdentifier(id)
    }
    override func prepareForDeletion() {
        FlickrClient.Caches.imageCache.storeImage(nil, withPath: file)
    }
    
    var photoImage: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithPath(file)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withPath: file)
        }
    }
    
    // Parse the flickr api result into an array of photo objects
    static func photosFromResult(result: AnyObject, context: NSManagedObjectContext) -> [Photo]{
        var photos = [Photo]()
        
        if let photosResult = result["photos"] as? NSDictionary {
            if let photosArray = photosResult["photo"] as? [[String: AnyObject]] {
                for dict in photosArray {
                    let photo = Photo(dictionary: dict, context: context)
                    photos.append(photo)
                }
            }
        }
        return photos
    }
    
    // Determine a photo's image file path given its identifier
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}