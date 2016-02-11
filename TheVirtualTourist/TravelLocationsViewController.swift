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
    
    var droppedPin : Pin!
    var pins = [Pin]()
    var annotationsLocations = [Int:Pin]()
    var annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        longPress.minimumPressDuration = 0.6
        mapView.addGestureRecognizer(longPress)
        mapView.delegate = self
        
        restoreLastMapRegion()
        
        let pins = fetchAllPins()
  
        for p in pins{
                let annotation = MKPointAnnotation()
                let tapPoint = CLLocationCoordinate2D(latitude: Double(p.latitude), longitude: Double(p.longitude)) //We need to cast to double because the parameters were NSNumber
                annotation.coordinate = tapPoint
                annotationsLocations[annotation.hash] = p //Setting the dictionary that will enable us to segway to photo album
                self.mapView.addAnnotation(annotation)
        }
    }
    
    //MARK: Drop a new Pin
    func dropPin(sender: UIGestureRecognizer) {
        if sender.state == .Began {
            let annotation = MKPointAnnotation()
            let touchPoint:CGPoint = sender.locationInView(mapView)
            let touchCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            annotation.coordinate = touchCoord
            self.mapView.addAnnotation(annotation)
            self.annotation = annotation
            
        }
        else if sender.state == .Changed {
            let annotation = MKPointAnnotation()
            let touchPoint:CGPoint = sender.locationInView(self.mapView)
            let touchCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            annotation.coordinate = touchCoord
            self.mapView.addAnnotation(annotation)
            self.annotation = annotation
        }
        else if sender.state == .Ended {
            droppedPin = Pin(dictionary: ["latitude":self.annotation.coordinate.latitude,"longitude":self.annotation.coordinate.longitude], context: sharedContext)
                // download photos as soon as pin is dropped
                downloadPhotos(droppedPin)
            }
    }

    // Mark: Download photos from flickr to store in cache
    func downloadPhotos(pin: Pin) {
        FlickrClient.sharedInstance().getPhotos(droppedPin.latitude, longitude: droppedPin.longitude) {
            (result, error) in
            if (error != nil) {
                self.showError("download photos error: \(error)")
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    let photos = Photo.photosFromResult(result, context: self.sharedContext)
                    photos.pin = self.droppedPin
                    CoreDataStackManager.sharedInstance().saveContext()
                    }
                }
            }
        }
    
    
    //MARK: Show Pin Photos
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        
        if let l = annotationsLocations[view.annotation!.hash]{
            controller.pin = l
            droppedPin = l
            
            presentViewController(controller, animated: true, completion: nil)
            mapView.deselectAnnotation(view.annotation, animated: true)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }

    //MARK: Fetch saved Pins
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch let error as NSError {
            showError("Error in fetching pins")
            return [Pin]()
        }
    }
    
    //MARK: Save map region
    struct Keys {
        static let region = "region"
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    func restoreLastMapRegion() {
        if let regionDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(Keys.region) {
            
            let region = MKCoordinateRegionMake(
                CLLocationCoordinate2DMake(
                    regionDictionary["latitude"] as! Double,
                    regionDictionary["longitude"] as! Double
                ),
                MKCoordinateSpanMake(
                    regionDictionary["spanLatitude"] as! Double,
                    regionDictionary["spanLongitude"]as! Double
                )
            )
            mapView.setRegion(region, animated: true)
        }
    }
    
    func saveMapRegion() {
        let region = mapView.region
        let regionDictionary = [
            "latitude": region.center.latitude,
            "longitude": region.center.longitude,
            "spanLatitude":   region.span.latitudeDelta,
            "spanLongitude":   region.span.longitudeDelta
        ]
        
        NSUserDefaults.standardUserDefaults().setObject(regionDictionary, forKey: Keys.region)
    }
    
    // MARK: Core Data convenience method
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // Show an error message with alert
    func showError(error: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

}