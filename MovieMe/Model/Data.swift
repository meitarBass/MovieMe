//
//  Data.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

protocol DataManagerProtocol {
    func saveData()
    func getData() -> [Media]?
    func deleteFavorite(index: Int)
    func addNewFavorite()
}

protocol ApiMediaManager {
    func fetchTrending(url: String, completion: @escaping ([Media]?) -> Void)
    func fetchImage(imagePath: String, completion: @escaping (UIImage?) -> Void)
    func parseData(json: [String : Any]) -> [Media]?
}

protocol ApiActorManager {
    func fetchActor(id: String, completion: @escaping ([Actor]?) -> Void)
    func parseActor(json: [String : Any]) -> [Actor]?
    func fetchActorImage(imagePath: String, completion: @escaping (UIImage?) -> Void)
}

class Data {
    
    private var mediaMovies: [Media] = [Media]()
    private var mediaMoviesImages: [UIImage?] = [UIImage?]()
    
    private var mediaSeries: [Media] = [Media]()
    private var mediaSeriesImages: [UIImage?] = [UIImage?]()
    
    private var actors: [Actor] = [Actor]()
    
    private weak var delegate: ControllerInput?
    
    init(delegate: ControllerInput) {
        self.delegate = delegate
    }
    
}

extension Data: DataManagerProtocol {
    
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

extension Data: ApiMediaManager {

    func fetchTrending(url: String, completion: @escaping ([Media]?) -> Void) {
        guard let url = URL(string: "\(url)") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                debugPrint(error.debugDescription)
                completion(nil)
                return
            }
            
            guard let data = data else { return }
                do {
                   let jsonAny = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let json = jsonAny as? [String : Any] else { return }
                    completion(self.parseData(json: json))
                } catch {
                    debugPrint(error.localizedDescription)
                    return
                }
            }
         task.resume()
    }
    
    func fetchImage(imagePath: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: "\(IMAGE_BASE)" + imagePath) else { return }
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard error == nil else {
                debugPrint(error.debugDescription)
                completion(nil)
                return
            }
            guard let data = data else { return }
            if let image = UIImage(data: data) {
                completion(image)
            }
        }
        task.resume()
    }
    
    func parseData(json: [String : Any]) -> ([Media]?) {
        var type = ""
        
        if let newJSON = json["results"] as? [[String : Any]] {
            for item in newJSON {
                let media_type = item["media_type"] as? String ?? ""
                type = media_type
            
                let vote_average = item["vote_average"] as? Double ?? 0.0
                let poster_path = item["poster_path"] as? String ?? ""
                let overview = item["overview"] as? String ?? ""
                let id = item["id"] as? Int ?? 0
                
                if media_type == "tv" {
                    let title = item["name"]! as? String ?? ""
                    let release_date = item["first_air_date"] as? String ?? ""
                    let releaseYear = release_date.components(separatedBy: "-")[0]
                    
                    let media_item = Media(title: title, rating: vote_average, release_date: releaseYear, movieImagePath: poster_path, media_type: media_type, overview: overview, id: id)
                    self.mediaSeries.append(media_item)
                } else if media_type == "movie" {
                    let title = item["title"]! as? String ?? ""
                    let release_date = item["release_date"] as? String ?? ""
                    let releaseYear = release_date.components(separatedBy: "-")[0]
                    let media_item = Media(title: title, rating: vote_average, release_date: releaseYear, movieImagePath: poster_path, media_type: media_type, overview: overview, id: id)
                    self.mediaMovies.append(media_item)
                }
            }
            
            if type == "tv" {
                return mediaSeries
            } else if type == "movie" {
                return mediaMovies
            }
            
        }
        return nil
    }
}

extension Data: ApiActorManager {
    
    func fetchActor(id: String, completion: @escaping ([Actor]?) -> Void) {
        guard let url = URL(string: BASE_URL + "movie/\(id)/credits?api_key=" + API_KEY) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                debugPrint(error.debugDescription)
                return
            }
            
            guard let data = data else { return }
                do {
                   let jsonAny = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let json = jsonAny as? [String : Any] else { return }
                    completion(self.parseActor(json: json))
                } catch {
                    debugPrint(error.localizedDescription)
                    return
                }
            }
         task.resume()
    }
    
    func parseActor(json: [String : Any]) -> [Actor]? {
        if let newJSON = json["cast"] as? [[String : Any]] {
            for actor in newJSON {
                let name = actor["name"] as? String ?? ""
                let imagePath = actor["profile_path"] as? String ?? ""
                let actor = Actor(name: name, actorImagePath: imagePath)
                actors.append(actor)
            }
        }
        return actors
    }
    
    func fetchActorImage(imagePath: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: "\(IMAGE_BASE)" + imagePath) else { return }
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard error == nil else {
                debugPrint(error.debugDescription)
                completion(nil)
                return
            }
            guard let data = data else { return }
            if let image = UIImage(data: data) {
                completion(image)
            }
        }
        task.resume()
    }
}
