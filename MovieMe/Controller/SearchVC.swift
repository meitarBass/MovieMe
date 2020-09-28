//
//  SearchVC.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {

    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: CustomSearchBar!
    
    private var dataManager: ApiMediaManagerProtocol?
    private var media : [Media] = [Media]()
    
    private var chosenMovie: MoviesResults!
    private var chosenSeries: SeriesResults!
    private var chosenType: MediaType!
    
    private var loadCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        
        searchBar.delegate = self
                
        self.dependencyInjection()
    }
    
    private func dependencyInjection() {
        let dataManager = DataManager(delegate: self)
        self.dataManager = dataManager
    }
    
    func getData(title: String) {
        let urlMovies = SEARCH_URL_MOVIES + title
        let urlSeries = SEARCH_URL_SERIES + title

        self.dataManager?.fetchMovies(url: urlMovies, completion: {[weak self] movies in
            
            guard let movies = movies else { return }
            for movie in movies.results {
                let mediaItem = Media(mediaType: .Movie, movies: movie, series: nil)
                self?.media.append(mediaItem)
            }
            self?.processMedia()
        })
        
        self.dataManager?.fetchSeries(url: urlSeries, completion: {[weak self] series in
            guard let series = series else { return }
            for series in series.results {
                let mediaItem = Media(mediaType: .Series, movies: nil, series: series)
                self?.media.append(mediaItem)
            }
            self?.processMedia()
        })
    }
    
    private func processMedia() {
        loadCount += 1
        guard loadCount == 2 else { return }
        self.sortMediaByRating { [weak self] media in
            self?.media = media
            DispatchQueue.main.async {
                self?.loadCount = 0
                self?.searchCollectionView.reloadData()
            }
        }
    }
    
    private func sortMediaByRating(completion: @escaping ([Media]) -> ()) {
        let sortedMedia = self.media.sorted { (media1, media2) -> Bool in
            switch media1.mediaType {
            case .Movie:
                switch media2.mediaType {
                case .Movie:
                    return media1.movies?.vote_average ?? 0.0 > media2.movies?.vote_average ?? 0.0
                case .Series:
                    return media1.movies?.vote_average ?? 0.0 > media2.series?.vote_average ?? 0.0
                }
            case .Series:
                switch media2.mediaType {
                    case .Movie:
                        return media1.series?.vote_average ?? 0.0 > media2.movies?.vote_average ?? 0.0
                    case .Series:
                        return media1.series?.vote_average ?? 0.0 > media2.series?.vote_average ?? 0.0
                }
            }
        }
        completion(sortedMedia)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let discoverVC = segue.destination as? DiscoverVC else { return }
        
        if chosenType == .Movie, let movie = chosenMovie {
            discoverVC.media = Media(mediaType: .Movie, movies: movie, series: nil)
        } else if let series = chosenSeries {
            discoverVC.media = Media(mediaType: .Series, movies: nil, series: series)
        }
    }

}

// MARK: UICollectionViewDelegate Methods

extension SearchVC: UICollectionViewDelegate {}

// MARK: UICollectionViewDataSource Methods

extension SearchVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! CollectionCell
        cell.setSearchCell(cellModel: media[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch media[indexPath.row].mediaType {
        case .Movie:
            chosenMovie = media[indexPath.row].movies
            chosenType = .Movie
        case .Series:
            chosenSeries = media[indexPath.row].series
            chosenType = .Series
        }
        performSegue(withIdentifier: "toDiscoverVC", sender: nil)
    }
}

// MARK: UICollectionViewDataSource Methods

extension SearchVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = view.bounds.width
        let cellDimesnions = width / 2 - 15
        return CGSize(width: cellDimesnions, height: cellDimesnions)
    }
}

// MARK: ControllerInput Methods

extension SearchVC: ControllerInput {
    func handleError(error: Error) {
        
    }
}

// MARK: UISearchBarDelegate Methods

extension SearchVC: UISearchBarDelegate {
    
    // TODO: Show a text for no search results
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        media.removeAll()
//        searchCollectionView.reloadData()
//        if searchText.count > 0 {
//            let textToSearch = searchText.replacingOccurrences(of: " ", with: "%20")
//            self.getData(title: textToSearch)
//        }
        if searchText.count == 0 {
            media.removeAll()
            searchCollectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        if searchText.count > 0 {
            let textToSearch = searchText.replacingOccurrences(of: " ", with: "%20")
            media.removeAll()
            getData(title: textToSearch)
        }
    }
}
    
