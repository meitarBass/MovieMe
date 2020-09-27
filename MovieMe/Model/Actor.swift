//
//  Actor.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation

struct Actor: Codable {
    let cast: [ActorResults]
}

struct ActorResults: Codable {
    
    let name: String?
    let profile_path: String?
    
}
