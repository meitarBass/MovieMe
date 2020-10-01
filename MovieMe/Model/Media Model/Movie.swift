//
//  MovieData.swift
//  MovieMe
//
//  Created by Meitar Basson on 26/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation

struct Movie: Codable {
    let results: [MoviesResults]
}

struct MoviesResults: Codable {
    
    let id: Int?
    let vote_average: Double?
    let title: String?
    let release_date: String?
    let overview: String?
    let poster_path: String?
    
}
