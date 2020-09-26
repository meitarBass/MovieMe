//
//  SeriesCollectionCell.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

class SeriesCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var seriesImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setSeriesCell(seriesImage image: UIImage) {
        seriesImage.image = image
    }
    
}
