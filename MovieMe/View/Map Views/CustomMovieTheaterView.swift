//
//  CustomMovieTheaterView.swift
//  MovieMe
//
//  Created by Meitar Basson on 01/10/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit

class CustomMovieTheaterView: UIView {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
    }
    
    func setLabels(name: String, distance: Int, address: String, city: String) {
        distanceLabel.text = "\(Double(distance) / 1000) km"
        nameLabel.text = name
        addressLabel.text = "\(city), \(address)"
        
        if name == city {
            addressLabel.text = ""
        }
    }
    
    func animShow(view: UIView) {
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
            view.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    
    func animHide(view: UIView) {
        self.bottomConstraint.constant = self.frame.height
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
            view.layoutIfNeeded()
        }) { (_) in
            self.isHidden = true
            if self.bottomConstraint.constant == 0 {
                self.animShow(view: view)
            }
        }
    }
}
