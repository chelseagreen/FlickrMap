//
//  ImageCache.swift
//  TheVirtualTourist
//
//  Created by Chelsea Green on 2/8/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//
import UIKit

// manage caching for photo images
class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    func imageWithPath(path: String) -> UIImage? {
        // First try the memory cache
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    func storeImage(image: UIImage?, withPath path: String) {
        // If the image is nil, remove images from the cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch _ {}
            
            return
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)!
        data.writeToFile(path, atomically: true)
    }
}