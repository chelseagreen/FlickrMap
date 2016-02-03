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

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    let identifier = "photoCELL"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    var collectionLabel:UILabel!
    var pin: Pin!
    
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        collectionView.delegate = self
        newCollectionButton.hidden = true 
        
        //fetchedResultsController.delegate = self
  
    }
    
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func newCollectionPressed(sender: UIButton) {
        
    }

    @IBAction func goBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

