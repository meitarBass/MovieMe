//
//  City.swift
//  MovieMe
//
//  Created by Meitar Basson on 03/10/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation

struct City: Codable {
    let results: [Result]
}

struct Result: Codable {
    let locations: [location]
}

struct location: Codable {
    let latLng: LatLng
}

struct LatLng: Codable {
    let lat: Double?
    let lng: Double?
}
