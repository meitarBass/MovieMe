//
//  DiscoverVC.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import RealmSwift

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
    @IBOutlet weak var heartButton: UIButton!
    
    private var dataManager: ApiMediaManagerProtocol?
    private var realmManager: RealmManagerProtocol?
    
    var media: Media!
    private var favouriteMedia: Results<MediaFavourite>?
        
    private var actors: Actor?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        actorsCollectionView.delegate = self
        actorsCollectionView.dataSource = self

        self.dependencyInjection()
        self.getData()
        self.setView(mediaType: media.mediaType)
        
        guard let _ = wasMovieLiked() else { return }
        heartButton.setImage(UIImage(named: "heartYellow"), for: .normal)
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
        
        guard let loadedData = realmManager?.loadData(modelType: MediaFavourite.self) else { return }
        favouriteMedia = loadedData
    }
    
    private func deleteFavourite(object: Object) {
        realmManager?.deleteData(object: object, modelType: MediaFavourite.self)
    }
    
    private func wasMovieLiked() -> Results<MediaFavourite>? {
        switch media.mediaType {

        case .Movie:
            guard let favouritesToDelete = self.favouriteMedia?.filter("id == %@", (media.movies?.id)!) else { return nil }
            if favouritesToDelete.count > 0 {
                return favouritesToDelete
            }
            return nil
        case .Series:
            guard let favouritesToDelete = self.favouriteMedia?.filter("id == %@", (media.series?.id)!) else { return nil }
            if favouritesToDelete.count > 0 {
                return favouritesToDelete
            }
            return nil
        }
        
    }
    
    private func dependencyInjection() {
        let dataManager = DataManager(delegate: self)
        self.dataManager = dataManager
        
        let realmManager = DataManager(delegate: self)
        self.realmManager = realmManager
    }

    @IBAction func favouriteButtonTapped(_ sender: Any) {
    
        let media_to_save = MediaFavourite()
        
        switch media.mediaType {
        case .Movie:
            guard let media = media.movies else { return }
            media_to_save.release_date = media.release_date
            media_to_save.title = media.title
            media_to_save.id = media.id ?? -1
            media_to_save.vote_average = media.vote_average ?? 0.0
            media_to_save.overview = media.overview
            media_to_save.poster_path = media.poster_path
        case .Series:
            guard let media = media.series else { return }
            media_to_save.release_date = media.first_air_date
            media_to_save.title = media.name
            media_to_save.id = media.id ?? -1
            media_to_save.vote_average = media.vote_average ?? 0.0
            media_to_save.overview = media.overview
            media_to_save.poster_path = media.poster_path
        }
        
        guard let mediaToDelete = wasMovieLiked() else {
            self.realmManager?.saveData(object: media_to_save, modelType: MediaFavourite.self)
            heartButton.setImage(UIImage(named: "heartYellow"), for: .normal)
            return
        }
        
        for media in mediaToDelete {
            self.realmManager?.deleteData(object: media, modelType: MediaFavourite.self)
        }
        heartButton.setImage(UIImage(named: "heartWhite"), for: .normal)
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

