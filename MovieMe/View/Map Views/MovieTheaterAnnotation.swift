//
//  MovieTheaterAnnotation.swift
//  MovieMe
//
//  Created by Meitar Basson on 02/10/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import MapKit

class MovieTheaterAnnotation: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = UIImage(named: "pin40")
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        canShowCallout = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
