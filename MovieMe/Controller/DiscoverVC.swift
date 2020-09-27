//
//  DiscoverVC.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

struct Media {
    
    var mediaType: MediaType
    var movies: MoviesResults?
    var series: SeriesResults?
    
}

// MARK: mediaType Enum

enum MediaType {
    case Movie
    case Series
}

class DiscoverVC: UIViewController {
    
    @IBOutlet weak var mediaImage: UIImageView!
    @IBOutlet weak var mediaTitleLabel: UILabel!
    @IBOutlet weak var mediaRatingLabel: UILabel!
    @IBOutlet weak var mediaReleaseYear: UILabel!
    @IBOutlet weak var mediaInfo: UILabel!
    @IBOutlet weak var actorsCollectionView: UICollectionView!
    
    private var dataManager: ApiMediaManagerProtocol?
    
    var media: Media!
        
    private var actors: Actor?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        actorsCollectionView.delegate = self
        actorsCollectionView.dataSource = self

        self.dependencyInjection()
        self.getData()
        self.setView(mediaType: media.mediaType)
            
    }
    
    private func getData() {
        var url = ""
        guard let media = media else { return }
        
        if media.mediaType == .Movie, let id = media.movies?.id {
            url = BASE_URL + "movie/\(id)/credits?api_key=\(API_KEY)"
        } else if media.mediaType == .Series, let id = media.series?.id {
            url = BASE_URL + "tv/\(id)/credits?api_key=\(API_KEY)"
        }
        
        self.dataManager?.fetchActors(url: url, completion: {[weak self] (actors) in
            self?.actors = actors
            DispatchQueue.main.async {
                self?.actorsCollectionView.reloadData()
            }
        })
    }
    
    private func dependencyInjection() {
        let dataManager = DataManager(delegate: self)
        self.dataManager = dataManager
    }

    @IBAction func favouriteButtonTapped(_ sender: Any) {
        print("add to favorite")
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setImage(imageUrl: String?) {
        if let imageUrl = URL(string: IMAGE_BASE + (imageUrl ?? "") ) {
            mediaImage.kf.indicatorType = .activity
            mediaImage.kf.setImage(
                with: imageUrl,
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.5)),
                    .cacheOriginalImage
            ])
        }
    }
}

// MARK: UICollectionViewDelegate Methods

extension DiscoverVC: UICollectionViewDelegate {}

// MARK: UICollectionViewDataSource Methods

extension DiscoverVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.actors?.cast.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = actorsCollectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as! CollectionCell
        cell.setActorCell(cellModel: self.actors?.cast[indexPath.row])
        return cell
    }
}

// MARK: UICollectionViewDataSource Methods

extension DiscoverVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.bounds.width
        let cellDimesnions = width / 4 - 30
        return CGSize(width: cellDimesnions, height: cellDimesnions)
    }
}

// MARK: ControllerInput Methods

extension DiscoverVC: ControllerInput {
    func handleError(error: Error) {
        
    }
}

// MARK: DiscoverVC Methods

extension DiscoverVC {
    private func setView(mediaType: MediaType) {
        switch mediaType {
        case .Movie:
            guard let movie = self.media.movies else { return }
            mediaTitleLabel.text = movie.title
            mediaRatingLabel.text = "\(movie.vote_average ?? 0.0) "
            mediaReleaseYear.text = getYear(date: movie.release_date)
            mediaInfo.text = movie.overview
            self.setImage(imageUrl: movie.poster_path)
        case .Series:
            guard let series = self.media.series else { return }
            mediaTitleLabel.text = series.name
            mediaRatingLabel.text = "\(series.vote_average ?? 0.0) "
            mediaReleaseYear.text = getYear(date: series.first_air_date)
            mediaInfo.text = series.overview
            self.setImage(imageUrl: series.poster_path)
        }
    }
    
    private func getYear(date: String?) -> String {
        guard let date = date else { return "" }
        let year = date.split(separator: "-")
        return "\(year[0])"
    }
}

