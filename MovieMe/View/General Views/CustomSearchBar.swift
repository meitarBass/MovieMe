//
//  CustomSearchBar.swift
//  MovieMe
//
//  Created by Meitar Basson on 27/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

class CustomSearchBar: UISearchBar {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        searchTextField.backgroundColor = #colorLiteral(red: 0.6465231776, green: 0.6465386748, blue: 0.6465303302, alpha: 0.6)
        searchTextField.font = UIFont(name: "AmericanTypewriter-Semibold", size: 14)
        searchTextField.textColor = .white
        placeholder = "Search..."
        backgroundImage = UIImage()
    }
}
