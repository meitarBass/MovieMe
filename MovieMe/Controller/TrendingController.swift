//
//  ViewController.swift
//  MovieMe
//
//  Created by Meitar Basson on 23/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import RealmSwift

protocol ControllerInput: class {
    func handleError(error: Error)
}

class TrendingController: UIViewController {
    
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    private var dataManager: ApiMediaManagerProtocol?
    private var realmManager: RealmManagerProtocol?
    
    private var data: MediaManager!

    private var movies: Movie?
    private var series: Series?
    
    private var chosenMovie: MoviesResults!
    private var chosenSeries: SeriesResults!
    private var chosenType: MediaType!
    
    private var trendingMedia: Results<MediaFavourite>?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCollectionViews()
        dependencyInjection()
        
        getTrendingMedia()
        parseDataIntoMovies()
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
        let dataManager = MediaManager(delegate: self)
        self.dataManager = dataManager
        
        let realmManager = RealmManager(delegate: self)
        self.realmManager = realmManager
    }

}

// MARK: UICollectionViewDelegate Methods

extension TrendingController: UICollectionViewDelegate {}

// MARK: UICollectionViewDataSource Methods

extension TrendingController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == moviesCollectionView {
            self.saveTrendingMoviesForOfflineMode()
            return movies?.results.count ?? 0
        } else {
            self.saveTrendingSeriesForOfflineMode()
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
            return CGSize(width: cellDimension, height: cellDimension + 110)
        } else {
            let cellDimesnsion = (width / 2) - 30
            return CGSize(width: cellDimesnsion - 30, height: cellDimesnsion + 20)
        }
    }
}

// MARK: - ControllerInput Method

extension TrendingController: ControllerInput {
    func handleError(error: Error) {
        self.presentAlert(title: "error", err: error.localizedDescription, errType: nil)
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

// MARK: - TrendingController Offline Mode

extension TrendingController {
    
    private func saveTrendingMoviesForOfflineMode() {
        guard let movies = self.movies else { return }
        for movie in movies.results {
            let movieToSave = MediaFavourite()
            
            movieToSave.id = movie.id ?? -1
            movieToSave.poster_path = movie.poster_path
            movieToSave.overview = movie.overview
            movieToSave.release_date = movie.release_date
            movieToSave.title = movie.title
            movieToSave.vote_average = movie.vote_average ?? 0.0
            movieToSave.type = MediaType.Movie.rawValue
            
            if !(self.realmManager?.isMediaSaved(id: movieToSave.id, modelType: MediaFavourite.self) ?? true) {
                self.realmManager?.saveData(object: movieToSave, modelType: MediaFavourite.self)
            }
        }
    }
    
    private func saveTrendingSeriesForOfflineMode() {
        guard let series = self.series else { return }
        for series in series.results {
            let seriesToSave = MediaFavourite()
            
            seriesToSave.id = series.id ?? -1
            seriesToSave.poster_path = series.poster_path
            seriesToSave.overview = series.overview
            seriesToSave.release_date = series.first_air_date
            seriesToSave.title = series.name
            seriesToSave.vote_average = series.vote_average ?? 0.0
            seriesToSave.type = MediaType.Series.rawValue
            
            if !(self.realmManager?.isMediaSaved(id: seriesToSave.id, modelType: MediaFavourite.self) ?? true) {
                self.realmManager?.saveData(object: seriesToSave, modelType: MediaFavourite.self)
            }
        }
    }
    
    private func getTrendingMedia() {
        guard let loadedData = realmManager?.loadData(modelType: MediaFavourite.self) else { return }
        trendingMedia = loadedData
    }
    
    private func parseDataIntoMovies() {
        guard let trendingMedia = self.trendingMedia else { return }
        var trendingMovies: [MoviesResults] = [MoviesResults]()
        var trendingSeries: [SeriesResults] = [SeriesResults]()
        
        for media in trendingMedia {
            if media.type == MediaType.Movie.rawValue {
                let movie = MoviesResults(id: media.id, vote_average: media.vote_average, title: media.title, release_date: media.release_date, overview: media.overview, poster_path: media.poster_path)
                trendingMovies.append(movie)
            } else if media.type == MediaType.Series.rawValue {
                let series = SeriesResults(id: media.id, vote_average: media.vote_average, name: media.title, first_air_date: media.release_date, overview: media.overview, poster_path: media.poster_path)
                trendingSeries.append(series)
            }
        }
        
        movies = Movie(results: trendingMovies)
        series = Series(results: trendingSeries)
        
        self.moviesCollectionView.reloadData()
        self.seriesCollectionView.reloadData()
    }
    
}
