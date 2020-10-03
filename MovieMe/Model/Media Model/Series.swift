//
//  Series.swift
//  MovieMe
//
//  Created by Meitar Basson on 26/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation

struct Series: Codable {
    let results: [SeriesResults]
}

struct SeriesResults: Codable {
    
    let id: Int?
    let vote_average: Double?
    let name: String?
    let first_air_date: String?
    let overview: String?
    let poster_path: String?
//    let media_type: String?
    
}
