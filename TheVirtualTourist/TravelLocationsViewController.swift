//
//  TravelLocationsViewController.swift
//  TheVirtualTourist
//
//  Created by Chelsea Green on 2/2/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//
import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var droppedPin : PinAnnotation?
    
    var cancelDownload = false
    
    override func viewDidLoad() {
        mapView.delegate = self
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        recognizer.minimumPressDuration = 0.6
        mapView.addGestureRecognizer(recognizer)
        
        let pins = fetchAllPins()
        var annotations = [PinAnnotation]()
        for pin in pins {
            let annotation = PinAnnotation(pin: pin)
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        
        restoreLastMapRegion()
    }
    
    override func viewWillAppear(animated: Bool) {
        cancelDownload = false
    }
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            return try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch let error as NSError {
            showError("Error in fetchAllPins(): \(error)")
            return [Pin]()
        }
    }
    
    func dropPin(sender: UIGestureRecognizer) {
        if sender.state == .Began {
            let touchPoint = sender.locationInView(mapView)
            let touchCoord = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            
            droppedPin = PinAnnotation(coordinate: touchCoord)
            
            mapView.addAnnotation(droppedPin!)
        }
        else if sender.state == .Changed {
            if let pin = droppedPin {
                let touchPoint = sender.locationInView(mapView)
                let touchCoord = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
                pin.updateCoordinate(touchCoord)
            }
        }
        else if sender.state == .Ended {
            if let pin = droppedPin {
                let touchPoint = sender.locationInView(mapView)
                let touchCoord = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
                pin.updateCoordinate(touchCoord)
                
                pin.pin  = Pin(longitude: pin.coordinate.longitude, latitude: pin.coordinate.latitude, context: CoreDataStackManager.sharedInstance().managedObjectContext)
                CoreDataStackManager.sharedInstance().saveContext()
                
                // download photos as soon as pin is dropped
                downloadPhotos(pin.pin!)
            }
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        
        // signal to cancel download in case there is a download in progress in background thread
        cancelDownload = true
        
        // deselect the pin so we can comeback and select it again
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        controller.pin = (view.annotation as! PinAnnotation).pin
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    // Download photos from flickr into local cache
    func downloadPhotos(pin: Pin) {
        FlickrClient.sharedInstance().getPhotos(pin.latitude, longitude: pin.longitude) {
            (result, error) in
            if (error != nil) {
                self.showError("download photos error: \(error)")
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    if (!self.cancelDownload) {
                        let photos = Photo.photosFromResult(result, context: CoreDataStackManager.sharedInstance().managedObjectContext)
                        for photo in photos {
                            photo.pin = pin
                        }
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                }
                
            }
        }
    }
    
    //Save and restore map zoom and region
    struct Keys {
        static let region = "region"
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
            "spanLatitude": region.span.latitudeDelta,
            "spanLongitude": region.span.longitudeDelta
        ]
        
        NSUserDefaults.standardUserDefaults().setObject(regionDictionary, forKey: Keys.region)
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