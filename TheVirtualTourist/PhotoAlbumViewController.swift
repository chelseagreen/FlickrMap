//
//  PhotoAlbumViewController.swift
//  TheVirtualTourist
//
//  Created by Chelsea Green on 2/2/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    var collectionLabel:UILabel!
    var pin: Pin!
    var cache = ImageCache.Static.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        fetch()
       
        collectionView.delegate = self
        collectionView.dataSource = self
        newCollectionButton.hidden = true 
        
        mapView.addAnnotation(pin)
        centerMapOnLocation(pin.coordinate)
    }
    
    /// use fetched result controller to fetch
    func fetch() {
        var error = NSErrorPointer()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print ("error")
        }
    }
    
    @IBAction func newCollectionPressed(sender: UIButton) {
        
    }

    @IBAction func goBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Collection view datasource implementation
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! CollectionViewCell
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        cell.imageView.image = UIImage(named: "no-image")
        if let image = cache.imageWithIdentifier(photo.file) {
            cell.imageView.image = image
        } else if photo.downloadStatus == .NotLoaded {
            getRemoteImage(cell, photo: photo)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    /// Delete the item when pressed
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        if photo.downloadStatus == .Loaded {
            photo.delete()
        }
    }
    
    // MARK: - Fetched results controller
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            let photo = anObject as! Photo
        case .Delete:
            collectionView.deleteItemsAtIndexPaths([indexPath!])
        default: ()
        }
    }
    
    // MARK: - Remote image download
    /**
    Downloads the given photo and sets the image in the cell. Stores the image in the cache for later use.
    
    :param: cell The PhotoCell
    :param: photo The Photo
    */
    func getRemoteImage(cell: CollectionViewCell, photo: Photo) {
        let task = cache.downloadImage(photo.file!) { imageData, error in
            if imageData != nil {
                let image = UIImage(data: imageData!)
                photo.saveImage(image!)
                cell.imageView.image = image
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    print("error downloading image \(error)")
                    photo.delete()
                }
            }
        }
        cell.taskToCancelifCellIsReused = task
    }
    
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext,sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        
    }()

    // MARK: - Map view convenience method
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
   
    // MARK: Core Data convenience method
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
}