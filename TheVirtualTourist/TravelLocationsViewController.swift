//
//  TravelLocationsViewController.swift
//  TheVirtualTourist
//
//  Created by Chelsea Green on 2/2/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        sharedContext = appDelegate.managedObjectContext
    
        let longPress = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        
        mapView.delegate = self
        
        mapView.addAnnotations(fetchAllPins())
    }
    
    //MARK: New Pin
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        if UIGestureRecognizerState.Began == gestureRecognizer.state {
            //initialize our Pin with our coordinates and the context from AppDelegate
            let pin = Pin(annotationLatitude: touchMapCoordinate.latitude, annotationLongitude: touchMapCoordinate.longitude, context: appDelegate.managedObjectContext)
            //add the pin to the map
            mapView.addAnnotation(pin)
            //save our context. We can do this at any point but it seems like a good idea to do it here.
            appDelegate.saveContext()
        }
    }
    
    //MARK: Remove Pin
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //cast pin
        let pin = view.annotation as! Pin
        //delete from our context
        sharedContext.deleteObject(pin)
        //remove the annotation from the map
        mapView.removeAnnotation(pin)
        //save our context
        appDelegate.saveContext()
    }
    
    //MARK: Fetch saved Pins
    func fetchAllPins() -> [Pin] {
        
        let error: NSErrorPointer = nil
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        // Execute the Fetch Request
        let results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error.memory = error1
            results = nil
        }
        // Check for Errors
        if error != nil {
            print("Error in fectchAllActors(): \(error)")
        }
        // Return the results, cast to an array of Pin objects
        return results as! [Pin]
    }
    
    
    
    
    //MARK: - MKMapViewDelegate methods
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
    
        
        let fetched = self.fetchedResultController.fetchedObjects as! [Pin]
        for pin in fetched {
            if pin.coordinate.latitude == view.annotation.coordinate.latitude && pin.coordinate.longitude == view.annotation.coordinate.longitude {
                
                
                // Once the corresponding pin is found, show the photoalbum and pass the data (pin)
                let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
                
                // Pass the corresponding pin to the controller
                controller.pin = pin
                
                // Check if a photo album already exist for this pin
                if !pin.photos.isEmpty {
                    
                    // If it does, segue to the album controller
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                    
                    // Otherwise, get the images paths from flickr, using the pin coordinates
                else {
                    
                    FlickrClient.sharedInstance().getImagesFromFlickrBySearch(searchLongitude: pin.coordinate.longitude, searchLatitude: pin.coordinate.latitude) { photos, error in
                        
                        if let error = error {
                            //Handle error
                            
                        } else {
                            
                            // Check if images were found for the given location.
                            if photos?.count == 0 {
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.activityIndicator.stopAnimating()
                                    self.displayLabelNoPhotoFound()
                                }
                                
                            } else {
                                
                                // map the array of dictionary to photo objects
                                var photo = photos?.map() { (dictionary: [String:AnyObject]) -> Photo in
                                    let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                                    
                                    photo.pin = pin
                                    
                                    return photo
                                }
                                
                                // Save the context
                                CoreDataStackManager.sharedInstance().saveContext()
                                
                                // Segue to the PhotoAlbum
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.navigationController?.pushViewController(controller, animated: true)
                                }
                            }
                        }
                    }
                }
                // Deselect the annotation
                mapView.deselectAnnotation(pin, animated: true)
            }
        }
    }
    
    
    
}
