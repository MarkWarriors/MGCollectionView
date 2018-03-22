//
//  MGCollectionViewCell.swift
//  MGCollectionView
//
//  Created by Marco Guerrieri on 11/03/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

class MGCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    static let identifier = "MGCollectionViewCell"
    
    func setItem(_ item: [String]){
        self.title.text = item[0]
        self.subtitle.text = item[1]
    }
}
