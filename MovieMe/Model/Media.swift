//
//  Movie.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation

struct Media: Codable {
    
    let title: String
    let rating: Double
    let release_date: String
    let movieImagePath: String
    let media_type: String
    let overview: String
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case rating = "vote_average"
        case release_date
        case movieImagePath = "poster_path"
        case media_type
        case overview
        case id
    }
}
