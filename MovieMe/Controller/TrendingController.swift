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
    
    private var dataManager: DataManagerProtocol?
    private var apiManager: ApiMediaManager?
    
    private var data: Data!
    private var mediaMovies: [Media]!
    private var imagesMovies = [UIImage?]()

    private var mediaSeries: [Media]!
    private var imagesSeries = [UIImage?]()
    
    private var chosenMediaItem: Media!
    private var chosenMediaImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupCollectionViews()
        dependencyInjection()
        getData()
        
    }
    
    private func setupCollectionViews() {
        seriesCollectionView.delegate = self
        seriesCollectionView.dataSource = self

        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
    }
    
    private func getData() {
        self.apiManager?.fetchTrending(url: TRENDING_MOVIE_URL,completion: { (media) in
            guard let fetchedMedia = media else { return }
            self.mediaMovies = fetchedMedia
            for item in self.mediaMovies {
                self.apiManager?.fetchImage(imagePath: item.movieImagePath, completion: { (image) in
                    guard let fetchedImage = image else { return }
                    self.imagesMovies.append(fetchedImage)
                    DispatchQueue.main.sync {
                        self.moviesCollectionView.reloadData()
                    }
                })
            }
        })
        
        self.apiManager?.fetchTrending(url: TRENDING_SERIES_URL,completion: { (media) in
            guard let fetchedMedia = media else { return }
            self.mediaSeries = fetchedMedia
            for item in self.mediaSeries {
                self.apiManager?.fetchImage(imagePath: item.movieImagePath, completion: { (image) in
                    guard let fetchedImage = image else { return }
                    self.imagesSeries.append(fetchedImage)
                    DispatchQueue.main.sync {
                        self.seriesCollectionView.reloadData()
                    }
                })
            }
        })
    }
    
    private func dependencyInjection() {
        let data = Data(delegate: self)
        self.apiManager = data
    }


}

// MARK: UICollectionViewDelegate Methods

extension TrendingController: UICollectionViewDelegate {}

// MARK: UICollectionViewDataSource Methods

extension TrendingController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == moviesCollectionView {
            return imagesMovies.count
        } else {
            return imagesSeries.count
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == moviesCollectionView {
            let cell = moviesCollectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! CategoryCollectionCell
            cell.setCell(image: ((imagesMovies[indexPath.row]) ?? UIImage(named: "BackBtn"))!)
            return cell
        } else {
            let cell = seriesCollectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! CategoryCollectionCell
            cell.setCell(image: ((imagesSeries[indexPath.row]) ?? UIImage(named: "BackBtn"))!)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == moviesCollectionView {
            chosenMediaItem = mediaMovies[indexPath.row]
            chosenMediaImage = imagesMovies[indexPath.row]
        } else if collectionView == seriesCollectionView {
            chosenMediaItem = mediaSeries[indexPath.row]
            chosenMediaImage = imagesSeries[indexPath.row]
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
        guard let item = chosenMediaItem, let img = chosenMediaImage else { return }
        discoverVC.mediaItem = item
        discoverVC.mediaImg = img
        print(item.title)
    }
}
