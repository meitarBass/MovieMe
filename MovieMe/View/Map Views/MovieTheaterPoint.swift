//
//  MovieTheaterPoint.swift
//  MovieMe
//
//  Created by Meitar Basson on 02/10/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import MapKit

class MovieTheaterPoint: MKPointAnnotation {
    
    var index: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setAnnotationPoint(pointModel: MovieTheaterResult?, index: Int) {
        title = pointModel?.name
        subtitle = pointModel?.location.address
        coordinate = CLLocationCoordinate2D(latitude: pointModel?.location.lat ?? 0.0, longitude: pointModel?.location.lng ?? 0.0)
        self.index = index
    }
}
