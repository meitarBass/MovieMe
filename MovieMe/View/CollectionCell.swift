//
//  MovieCollectionCell.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import Kingfisher

class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setMovieCell(cellModel: MoviesResults?) {
        setCellImage(imageUrl: cellModel?.poster_path)
        ratingLabel.text = "\(cellModel?.vote_average ?? 0.0)"
        titleLabel.text = cellModel?.title
    }
    
    func setSeriesCell(cellModel: SeriesResults?) {
        setCellImage(imageUrl: cellModel?.poster_path)
        ratingLabel.text = "\(cellModel?.vote_average ?? 0.0)"
        titleLabel.text = cellModel?.name
    }
    
    func setActorCell(cellModel: ActorResults?) {
        if let imgUrl = cellModel?.profile_path {
            setCellImage(imageUrl: imgUrl)
        } else {
            cellImage.image = UIImage(named: "actorPlaceHolder")!
        }
    }
    
    func setSearchCell(cellModel: Media) {
        switch cellModel.mediaType {
        case .Movie:
            setMovieCell(cellModel: cellModel.movies)
        case .Series:
            setSeriesCell(cellModel: cellModel.series)
        }
    }
    
    private func setCellImage(imageUrl: String?) {
        if let imageUrl = URL(string: IMAGE_BASE + (imageUrl ?? "") ) {
            cellImage.kf.indicatorType = .activity
            cellImage.kf.setImage(
                with: imageUrl,
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.5)),
                    .cacheOriginalImage
            ])
        }
    }
    
}
