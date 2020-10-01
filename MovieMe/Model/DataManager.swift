//
//  Data.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import RealmSwift

protocol RealmManagerProtocol: class {
    func saveData<T>(object: Object, modelType: T.Type)
    func loadData<T: Object>(modelType: T.Type) -> Results<T>?
    func deleteData<T>(object: Object, modelType: T.Type)
}

protocol ApiMediaManagerProtocol: class {
    func fetchMovies(url: String, completion: @escaping (Movie?) -> ())
    func fetchSeries(url: String, completion: @escaping (Series?) -> ())
    func fetchActors(url: String, completion: @escaping (Actor?) -> ())
    
    func fetchMovieTheaters(url: String, completion: @escaping (MovieTheater?) -> ())
    func fetchMovieResultsIntoTheaters(theatersResult: MovieTheater?) -> [MovieTheaterResult]?
}

class DataManager {
    
    private let realm = try! Realm()
    
    private weak var delegate: ControllerInput?
    
    init(delegate: ControllerInput) {
        self.delegate = delegate
    }
    
}

extension DataManager: RealmManagerProtocol {
        
    func saveData<T>(object: Object, modelType: T.Type) {
        do {
            try realm.write({
                realm.add(object)
            })
        } catch {
            print("Error saving category \(error)")
        }
    }
    
    func loadData<T: Object>(modelType: T.Type) -> Results<T>? {
        let loadedData = realm.objects(modelType)
        return loadedData
    }

    func deleteData<T>(object: Object, modelType: T.Type) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error deleting category \(error)")
        }
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
    
    func fetchMovieTheaters(url: String, completion: @escaping (MovieTheater?) -> ()) {
        NetworkServices.shared.networkRequest(url: url, modelType: MovieTheater.self) { (movieTheaters) in
            completion(movieTheaters)
        }
    }
    
    func fetchMovieResultsIntoTheaters(theatersResult: MovieTheater?) -> [MovieTheaterResult]? {
        var venueArr = [MovieTheaterResult]()
        guard let result = theatersResult else { return nil}
        for group in result.response.groups {
            for item in group.items {
                venueArr.append(item.venue)
            }
        }
        return venueArr
    }
    
}
