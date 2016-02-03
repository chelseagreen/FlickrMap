//
//  ViewController.swift
//  TheVirtualTourist
//
//  Created by Chelsea Green on 2/2/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //making sure we have the appDelegate at hand with the context save method
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //initializing our context here
        sharedContext = appDelegate.managedObjectContext
        
        //long press gesture recognizer allowing us call our "dropPin" method.
        let longPress = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        //the minimumPress duration has to be 0.5 seconds
        longPress.minimumPressDuration = 0.5
        //add the recognizer to mapView
        mapView.addGestureRecognizer(longPress)
        
        //Set ViewController as mapView delegate
        mapView.delegate = self
        
        //add pins to map
        mapView.addAnnotations(fetchAllPins())
    }
    
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
    
}
