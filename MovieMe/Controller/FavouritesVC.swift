//
//  FavouritesVC.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import RealmSwift

class FavouritesVC: UIViewController {
    
    @IBOutlet weak var favouritesCollection: UICollectionView!
    @IBOutlet weak var favouritesSearchBar: CustomSearchBar!
    
    private var realmManager: RealmManagerProtocol?
    
    private var media: Results<MediaFavourite>?
    private var movieToTransform: MoviesResults?
    private var seriesToTransform: SeriesResults?
    
    private var mediaType: MediaType?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        favouritesCollection.delegate = self
        favouritesCollection.dataSource = self
        favouritesSearchBar.delegate = self
        
        dependencyInjection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    private func dependencyInjection() {
        let realmManager = RealmManager(delegate: self)
        self.realmManager = realmManager
    }
    
    private func loadData() {
        guard let loadedData = realmManager?.loadData(modelType: MediaFavourite.self) else { return }
        media = loadedData.filter("isFavourite == %@", true)
        favouritesCollection.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let discoverVC = segue.destination as? DiscoverVC, let mediaType = self.mediaType else { return }
        switch mediaType {
        case .Movie:
            discoverVC.media = Media(mediaType: mediaType, movies: movieToTransform, series: nil)
        case .Series:
            discoverVC.media = Media(mediaType: mediaType, movies: nil, series: seriesToTransform)
        }
    }
}


// MARK: UICollectionViewDelegate Methods

extension FavouritesVC: UICollectionViewDelegate {}

// MARK: UICollectionViewDataSource Methods

extension FavouritesVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = favouritesCollection.dequeueReusableCell(withReuseIdentifier: "favouriteCell", for: indexPath) as! CollectionCell
        cell.setFavouriteCell(cellModel: media?[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let media = self.media else { return }
        let specificMedia = media[indexPath.row]
        guard let mediaType = MediaType(rawValue: specificMedia.type) else { return }
        self.mediaType = mediaType
        switch mediaType {
        
        case .Movie:
            movieToTransform = MoviesResults(id: specificMedia.id, vote_average: specificMedia.vote_average, title: specificMedia.title, release_date: specificMedia.release_date, overview: specificMedia.overview, poster_path: specificMedia.poster_path)
        case .Series:
            seriesToTransform = SeriesResults(id: specificMedia.id, vote_average: specificMedia.vote_average, name: specificMedia.title, first_air_date: specificMedia.release_date, overview: specificMedia.overview, poster_path: specificMedia.poster_path)
        }
        
        performSegue(withIdentifier: "toDiscoverVC", sender: nil)
    }
}

// MARK: UICollectionViewDataSource Methods

extension FavouritesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = view.bounds.width
        let cellDimesnions = width / 2 - 15
        return CGSize(width: cellDimesnions, height: cellDimesnions + 80)
    }
}

// MARK: ControllerInput Methods

extension FavouritesVC: ControllerInput {
    func handleError(error: Error) {
        self.presentAlert(title: "error", err: error.localizedDescription, errType: nil)
    }
}

// MARK: Search Methods

extension FavouritesVC: UISearchBarDelegate {
    
    // TODO: Show a text for no search results
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.loadData()
        if searchText.count > 0 {
            self.media = self.media?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "vote_average", ascending: false)
            self.favouritesCollection.reloadData()
        }
    }
}
