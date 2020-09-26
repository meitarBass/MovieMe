//
//  DiscoverVC.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

class DiscoverVC: UIViewController {
    
    @IBOutlet weak var mediaImage: UIImageView!
    @IBOutlet weak var mediaTitleLabel: UILabel!
    @IBOutlet weak var mediaRatingLabel: UILabel!
    @IBOutlet weak var mediaReleaseYear: UILabel!
    @IBOutlet weak var mediaInfo: UILabel!
    @IBOutlet weak var actorsCollectionView: UICollectionView!
    
    var mediaItem: Media!
    var mediaImg: UIImage!
    
    private var apiActorManager: ApiActorManager?
    
    private var actors: [Actor]!
    private var actorsImage: [UIImage] = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mediaImage.image = mediaImg
        
        guard let media = mediaItem else { return }
        mediaTitleLabel.text = media.title
        mediaRatingLabel.text = "\(media.rating)"
        mediaReleaseYear.text = media.release_date
        mediaInfo.text = media.overview
        
        actorsCollectionView.delegate = self
        actorsCollectionView.dataSource = self
        
        self.dependencyInjection()
        self.getData()
    }
    
    private func getData() {
        self.apiActorManager?.fetchActor(id: "\(mediaItem.id)", completion: { (actors) in
            guard let fetchedActors = actors else { return }
            self.actors = fetchedActors
            for actor in self.actors {
                self.apiActorManager?.fetchActorImage(imagePath: actor.actorImagePath, completion: { (img) in
                    guard let fetchedImage = img else {
                        self.actorsImage.append(UIImage(named: "BackBtn")!)
                        return
                    }
                    self.actorsImage.append(fetchedImage)
                    DispatchQueue.main.async {
                        self.actorsCollectionView.reloadData()
                    }
                })
            }
        })
    }
    
    private func dependencyInjection() {
        let data = Data(delegate: self)
        self.apiActorManager = data
    }

    @IBAction func favouriteButtonTapped(_ sender: Any) {
        
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDelegate Methods

extension DiscoverVC: UICollectionViewDelegate {}

// MARK: UICollectionViewDataSource Methods

extension DiscoverVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.actorsImage.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = actorsCollectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as! CategoryCollectionCell
        cell.setCell(image: actorsImage[indexPath.row])
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

extension DiscoverVC: ControllerInput {
    func handleError(error: Error) {
        
    }
}
