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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let longPress = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        longPress.minimumPressDuration = 0.6
        mapView.addGestureRecognizer(longPress)
        mapView.delegate = self
        
        restoreLastMapRegion()
        
        mapView.addAnnotations(fetchAllPins())
    }
    
    //MARK: New Pin
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        if UIGestureRecognizerState.Began == gestureRecognizer.state {
            //initialize our Pin with our coordinates and the context from AppDelegate
            let pin = Pin(annotationLatitude: touchMapCoordinate.latitude, annotationLongitude: touchMapCoordinate.longitude, context: CoreDataStackManager.sharedInstance().managedObjectContext)
            //add the pin to the map
            mapView.addAnnotation(pin)
            //save our context. We can do this at any point but it seems like a good idea to do it here.
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    //MARK: Show Pin Photos
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //cast pin
        let pin = view.annotation as! Pin
        performSegueWithIdentifier("showAlbum", sender: view.annotation)
    }
    
    // MARK: Segue to Album
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController.childViewControllers[0] as! PhotoAlbumViewController
        vc.pin = sender as! Pin
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
}