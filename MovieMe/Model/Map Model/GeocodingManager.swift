//
//  GeocodingManager.swift
//  MovieMe
//
//  Created by Meitar Basson on 03/10/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation

protocol GeocodingApiManager: class {
    func fetchCity(url: String, completion: @escaping (LatLng) -> ())
}

class GeocodingManager {

    private weak var delegate: ControllerInput?
    
    init(delegate: ControllerInput) {
        self.delegate = delegate
    }
    
}

extension GeocodingManager: GeocodingApiManager {
    
     func fetchCity(url: String, completion: @escaping (LatLng) -> ()) {
        NetworkServices.shared.networkRequest(url: url, modelType: City.self) { (cityLocation) in
            // TODO: - handle error
            guard let cityLocation = cityLocation?.results.first?.locations.first?.latLng else { return }
            completion(cityLocation)
        }
    }
    
}
