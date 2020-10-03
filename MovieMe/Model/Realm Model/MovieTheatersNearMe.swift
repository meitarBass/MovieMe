//
//  MovieTheatersNearMe.swift
//  MovieMe
//
//  Created by Meitar Basson on 03/10/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation
import RealmSwift

class MovieTheatersNearMe: Object {
    
    @objc dynamic var name: String?
    @objc dynamic var address: String?
    @objc dynamic var city: String?
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    @objc dynamic var distance: Int = 0
    
}
