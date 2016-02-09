//
//  CollectionViewCell.swift
//  TheVirtualTourist
//
//  Created by Chelsea Green on 2/2/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}