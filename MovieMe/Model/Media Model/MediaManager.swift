//
//  Data.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

protocol ApiMediaManagerProtocol: class {
    func fetchMovies(url: String, completion: @escaping (Movie?) -> ())
    func fetchSeries(url: String, completion: @escaping (Series?) -> ())
    func fetchActors(url: String, completion: @escaping (Actor?) -> ())
}

class MediaManager {
    
    private weak var delegate: ControllerInput?
    
    init(delegate: ControllerInput) {
        self.delegate = delegate
    }
    
}

extension MediaManager: ApiMediaManagerProtocol {
        
    func fetchMovies(url: String, completion: @escaping (Movie?) -> ()) {
        NetworkServices.shared.networkRequest(url: url, modelType: Movie.self) { movie in
            completion(movie)
        }
    }
    
    func fetchSeries(url: String, completion: @escaping (Series?) -> ()) {
        NetworkServices.shared.networkRequest(url: url, modelType: Series.self) { series in
            completion(series)
        }
    }
    
    func fetchActors(url: String, completion: @escaping (Actor?) -> ()) {
        NetworkServices.shared.networkRequest(url: url, modelType: Actor.self) { (actors) in
            completion(actors)
        }
    }
}


