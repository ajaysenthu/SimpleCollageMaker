//
//  PhotoCollectionViewCell.swift
//  SimpleCollageMaker
//
//  Created by mac on 11/07/20.
//  Copyright © 2020 Aj. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var highlightedButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func select() {
        
        highlightedButton.isHidden = false
    }
    
    func deSelect() {
        
        highlightedButton.isHidden = true
    }
}
