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

enum DownloadStatus {
    case NotLoaded, Loading, Loaded
}

@objc(Photo)
class Photo: NSManagedObject {
    
    struct Keys {
        static let URL = "url"
        static let File = "file"
    }
    
    struct Config {
        static let flickrURLTemplate = ["https://farm", "{farm-id}", ".staticflickr.com/", "{server-id}", "/", "{id}", "_", "{secret}", "_z.jpg"]
        static let PhotoLoadedNotification = "PhotoLoadedNotification"
    }
    
    /// Whether all the photo has been downloaded
    var downloadStatus: DownloadStatus = .NotLoaded
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        if let image = ImageCache.Static.instance.imageWithIdentifier(file) {
            downloadStatus = .Loaded
        }
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        url = dictionary[Keys.URL] as! String
        file = dictionary[Keys.File] as! String
    }
    
    /**
     Builds the URL from the Flickr data
     
     :photo: The photo information
     :returns: The URL
     */
    class func buildFlickrUrl(photo: [String: AnyObject]) -> String {
        var photoUrlParts = Config.flickrURLTemplate
        photoUrlParts[1] = String(photo["farm"] as! Int)
        photoUrlParts[3] = photo["server"] as! String
        photoUrlParts[5] = photo["id"] as! String
        photoUrlParts[7] = photo["secret"] as! String
        
        return photoUrlParts.joinWithSeparator("")
    }
    
    /**
     Saves the image and marks the status as downloaded
     
     :param: image The image to save
     */
    func saveImage(image: UIImage) {
        ImageCache.Static.instance.storeImage(image, withIdentifier: file!)
        downloadStatus = .Loaded
        NSNotificationCenter.defaultCenter().postNotificationName(Config.PhotoLoadedNotification, object: self)
    }
    
    func delete() {
        ImageCache.Static.instance.deleteImage(self.file!)
        managedObjectContext?.deleteObject(self)
    }
}