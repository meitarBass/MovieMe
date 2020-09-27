//
//  NetworkManager.swift
//  MovieMe
//
//  Created by Meitar Basson on 26/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation

struct NetworkServices {
    
    static let shared = NetworkServices()
    private init() {}
    
    func networkRequest<T: Codable> (url: String, modelType: T.Type, completion: @escaping (T?) -> ()) {
        guard let url = URL(string: "\(url)") else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                debugPrint(error.debugDescription)
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            completion(self.parseData(data: data, modelType: T.self))
        }
        task.resume()
    }
    
    private func parseData< T: Codable>(data: Data, modelType: T.Type) -> T? {
        let decoder = JSONDecoder()
        
        do {
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            print("error while decoding data", error)
            return nil
        }
    }
}
