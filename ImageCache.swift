//
//  ImageCache.swift
//  TheVirtualTourist
//
//  Created by Chelsea Green on 2/8/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class ImageCache {
    
    struct Static {
        static let instance = ImageCache()
    }
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        var data: NSData?
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)

        // And in documents directory
        let data = UIImagePNGRepresentation(image!)
        data!.writeToFile(path, atomically: true)
    }
    
    /**
     Deletes the image from the cache and documents directory
     */
    func deleteImage(identifier: String) {
        // call store with nil for the image deletes the image
        storeImage(nil, withIdentifier: identifier)
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
    
    // MARK: Image retrieval
    
    func downloadImage(imageUrl: String, didComplete: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        let url = NSURL(string: imageUrl)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                didComplete(imageData: nil, error: error)
            } else {
                didComplete(imageData: data, error: nil)
            }
        }
        
        task.resume()
        return task
    }
}
