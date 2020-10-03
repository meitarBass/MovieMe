//
//  CustomImageView.swift
//  MovieMe
//
//  Created by Meitar Basson on 26/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 8.0
    }

}
