//
//  Extensions.swift
//  MovieMe
//
//  Created by Meitar Basson on 03/10/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlert(title: String, err: String, errType: Err?) {
        let alert = UIAlertController(title: title, message: err, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
}

enum Err {
    
}
