//
//  MediaFavorite.swift
//  MovieMe
//
//  Created by Meitar Basson on 28/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation
import RealmSwift

class MediaFavourite: Object {
    
    @objc dynamic var id: Int = -1
    @objc dynamic var vote_average: Double = 0.0
    @objc dynamic var title: String?
    @objc dynamic var release_date: String?
    @objc dynamic var overview: String?
    @objc dynamic var poster_path: String?
        
}
