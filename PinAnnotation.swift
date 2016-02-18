//
//  PinAnnotation.swift
//  TheVirtualTourist
//
//  Created by Chelsea Green on 2/9/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation
import MapKit

class PinAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pin : Pin?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    init(pin : Pin) {
        self.pin = pin
        self.coordinate = pin.getCoordinate()
    }
    
    func updateCoordinate(newCoordinate: CLLocationCoordinate2D)->Void {
        willChangeValueForKey("coordinate")
        coordinate = newCoordinate
        didChangeValueForKey("coordinate")
    }
}
