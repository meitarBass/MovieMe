//
//  MapManager.swift
//  MovieMe
//
//  Created by Meitar Basson on 03/10/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

protocol LocationApiManager: class {
    func fetchMovieTheaters(url: String, completion: @escaping ([Venue]?) -> ())
}

class MapManager {

    private weak var delegate: ControllerInput?
    
    private var theaters: [Venue] = [Venue]()
    
    init(delegate: ControllerInput) {
        self.delegate = delegate
    }
    
}


extension MapManager: LocationApiManager {
    func fetchMovieTheaters(url: String, completion: @escaping ([Venue]?) -> ()) {
        NetworkServices.shared.networkRequest(url: url, modelType: MovieTheater.self) { (movieTheaters) in
            // TODO: - handle
            guard let movieTheaters = movieTheaters?.response.groups.first?.items else {
                completion(nil)
                return
            }
            completion(movieTheaters)
        }
    }
}
