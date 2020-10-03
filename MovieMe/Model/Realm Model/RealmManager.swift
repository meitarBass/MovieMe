//
//  RealmManager.swift
//  MovieMe
//
//  Created by Meitar Basson on 03/10/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import RealmSwift

protocol RealmManagerProtocol: class {
    func saveData<T>(object: Object, modelType: T.Type)
    func loadData<T: Object>(modelType: T.Type) -> Results<T>?
    func deleteData<T>(object: Object, modelType: T.Type)
    func deleteDataFromId<T>(id: Int?, modelType: T.Type) where T : Object
    
    func isMovieLiked<T>(id: Int?, modelType: T.Type) -> Bool where T : Object
    func isMediaSaved<T>(id: Int?, modelType: T.Type) -> Bool where T : Object
    func isPointSaved<T>(lat: Double?, lng: Double?, modelType: T.Type) -> Bool where T : Object
}

class RealmManager {
    
    private let realm = try! Realm()
    
    private weak var delegate: ControllerInput?
    
    init(delegate: ControllerInput) {
        self.delegate = delegate
    }
    
}

extension RealmManager: RealmManagerProtocol {
        
    func saveData<T>(object: Object, modelType: T.Type) {
        do {
            try realm.write({
                realm.add(object)
            })
        } catch {
            print("Error saving category \(error)")
            self.delegate?.handleError(error: error)
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
            self.delegate?.handleError(error: error)
            print("Error deleting category \(error)")
        }
    }
    
    func deleteDataFromId<T>(id: Int?, modelType: T.Type) where T : Object {
        guard let id = id else { return }
        guard let trashData = realm.objects(modelType).filter("id == %@", id).first else { return }
        self.deleteData(object: trashData, modelType: modelType)
    }
    
    func isMovieLiked<T>(id: Int?, modelType: T.Type) -> Bool where T : Object {
        guard let id = id else { return false }
        if realm.objects(modelType).filter("id == %@ AND isFavourite == %@", id, true).isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func isMediaSaved<T>(id: Int?, modelType: T.Type) -> Bool where T : Object {
        guard let id = id else { return false}
        if realm.objects(modelType).filter("id == %@", id).isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func isPointSaved<T>(lat: Double?, lng: Double?, modelType: T.Type) -> Bool where T : Object {
        guard let lat = lat, let lng = lng else { return false }
        if realm.objects(modelType).filter("lat == %@ AND lng == %@", lat, lng).isEmpty {
            return false
        } else {
            return true
        }
    }
    
}
