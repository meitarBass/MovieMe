//
//  MovieTheater.swift
//  MovieMe
//
//  Created by Meitar Basson on 30/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation

struct MovieTheater: Codable {
    let response: Groups
}

struct Groups: Codable {
    let groups: [Items]
}

struct Items: Codable {
    let items: [Venue]
}

struct Venue: Codable {
    let venue: MovieTheaterResult
}

struct MovieTheaterResult: Codable {
    
    let name: String?
    let location: Location
    
}

struct Location: Codable {
    let address: String?
    let lat: Double?
    let lng: Double?
    let distance: Int?
    let city: String?
}
