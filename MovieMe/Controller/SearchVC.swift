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
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var dataManager: ApiMediaManagerProtocol?
    private var media : [Media] = [Media]()
    
    private var chosenMovie: MoviesResults!
    private var chosenSeries: SeriesResults!
    private var chosenType: MediaType!
    
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
            for movie in movies!.results {
                let mediaItem = Media(mediaType: .Movie, movies: movie, series: nil)
                self?.media.append(mediaItem)
            }
            
            DispatchQueue.main.async {
                self?.searchCollectionView.reloadData()
            }
        })
        
        self.dataManager?.fetchSeries(url: urlSeries, completion: {[weak self] series in
            for series in series!.results {
                let mediaItem = Media(mediaType: .Series, movies: nil, series: series)
                self?.media.append(mediaItem)
            }
            DispatchQueue.main.async {
                self?.searchCollectionView.reloadData()
            }
        })
    }
    
//    private func sortByRating() {
//        media.sorted(by: {($0.movies?.vote_average)! > ($1.movies?.vote_average)!})
//    }
    
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
        if media[indexPath.row].mediaType == .Movie {
            chosenMovie = media[indexPath.row].movies
            chosenType = .Movie
        } else if media[indexPath.row].mediaType == .Series {
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        media.removeAll()
        if searchText.count > 0 {
            let textToSearch = searchText.replacingOccurrences(of: " ", with: "%20")
            getData(title: textToSearch)
        } else if searchText.count == 0 {
            searchCollectionView.reloadData()
        }
    }
}
