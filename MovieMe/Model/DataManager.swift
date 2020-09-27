//
//  Data.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import RealmSwift

protocol DataManagerProtocol: class {
    func saveData()
//    func getData() -> [Media]?
    func deleteFavorite(index: Int)
    func addNewFavorite()
}

protocol ApiMediaManagerProtocol: class {
    func fetchMovies(url: String, completion: @escaping (Movie?) -> ())
    func fetchSeries(url: String, completion: @escaping (Series?) -> ())
    func fetchActors(url: String, completion: @escaping (Actor?) -> ())
}

class DataManager {
    
    private var actors: [Actor] = [Actor]()
    
    private weak var delegate: ControllerInput?
    
    init(delegate: ControllerInput) {
        self.delegate = delegate
    }
    
}

extension DataManager: DataManagerProtocol {
    
    func saveData() {
        print("Saved")
    }
    
    func getData() -> [Media]? {
        return nil
    }
    
    func deleteFavorite(index: Int) {
        print("Deleted")
    }
    
    func addNewFavorite() {
        print("Added")
    }
    
}

extension DataManager: ApiMediaManagerProtocol {
    
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
