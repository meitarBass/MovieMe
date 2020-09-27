//
//  ViewController.swift
//  MovieMe
//
//  Created by Meitar Basson on 23/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

protocol ControllerInput: class {
    func handleError(error: Error)
}

class TrendingController: UIViewController {
    
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    private var dataManager: (DataManagerProtocol & ApiMediaManagerProtocol)?
    private var data: DataManager!

    private var movies: Movie?
    private var series: Series?
    
    private var chosenMovie: MoviesResults!
    private var chosenSeries: SeriesResults!
    private var chosenType: MediaType!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCollectionViews()
        dependencyInjection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getData()
    }
    
    private func setupCollectionViews() {
        seriesCollectionView.delegate = self
        seriesCollectionView.dataSource = self

        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
    }
    
    private func getData() {
        self.dataManager?.fetchMovies(url: TRENDING_MOVIE_URL, completion: {[weak self] movies in
            self?.movies = movies
            DispatchQueue.main.async {
                self?.moviesCollectionView.reloadData()
            }
        })
    
        self.dataManager?.fetchSeries(url: TRENDING_SERIES_URL, completion: {[weak self] series in
            self?.series = series
            DispatchQueue.main.async {
                self?.seriesCollectionView.reloadData()
            }
        })
    }
    
    private func dependencyInjection() {
        let dataManager = DataManager(delegate: self)
        self.dataManager = dataManager
    }

}

// MARK: UICollectionViewDelegate Methods

extension TrendingController: UICollectionViewDelegate {}

// MARK: UICollectionViewDataSource Methods

extension TrendingController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == moviesCollectionView {
            return movies?.results.count ?? 0
        } else {
            return series?.results.count ?? 0
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == moviesCollectionView {
            let cell = moviesCollectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! CollectionCell
            cell.setMovieCell(cellModel: self.movies?.results[indexPath.row])
            return cell
        } else {
            let cell = seriesCollectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! CollectionCell
            cell.setSeriesCell(cellModel: self.series?.results[indexPath.row])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == moviesCollectionView {
            chosenMovie = movies?.results[indexPath.row]
            chosenType = .Movie
        } else if collectionView == seriesCollectionView {
            chosenSeries = series?.results[indexPath.row]
            chosenType = .Series
        }
        performSegue(withIdentifier: "toDiscoverVC", sender: nil)
    }

}

// MARK: UICollectionViewDataSource Methods

extension TrendingController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.bounds.width
        
        if collectionView == moviesCollectionView {
            let cellDimension = (width / 2) - 15
            return CGSize(width: cellDimension, height: cellDimension)
        } else {
            let cellDimesnsion = (width / 2.75) - 30
            return CGSize(width: cellDimesnsion, height: cellDimesnsion)
        }
    }
}

// MARK: - ControllerInput Method

extension TrendingController: ControllerInput {
    func handleError(error: Error) {
//        self.presentAlert(title: "error", message: error.localizedDescription, actionText: nil) { (_) in}
    }
}

// MARK: - TrendingController Methods

extension TrendingController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let discoverVC = segue.destination as? DiscoverVC else { return }
        
        if chosenType == .Movie, let movie = chosenMovie {
            discoverVC.media = Media(mediaType: .Movie, movies: movie, series: nil)
        } else if let series = chosenSeries {
            discoverVC.media = Media(mediaType: .Series, movies: nil, series: series)
        }
    }
}
