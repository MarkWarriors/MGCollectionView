//
//  CollectionViewController.swift
//  MGCollectionView
//
//  Created by Marco Guerrieri on 11/03/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

class CollectionViewController: ViewController, MGCollectionViewProtocol {
    
    public var cellForRow : (iphonePortrait: Int, iphoneLandscape: Int, ipadPortrait: Int, ipadLandscape: Int)?
    
    var testarray : [[String]] = []

    @IBOutlet weak var collectionView: MGCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...140 {
            var item : [String] = []
            item.append(randomString(length: 8) + " \(i)")
            item.append(randomString(length: 8) + " \(i)")
            testarray.append(item)
        }
        collectionView.protocolDelegate = self
        collectionView.pullToRefresh = true
        collectionView.useInfiniteScroll = true
        collectionView.cellIdentifier = MGCollectionViewCell.identifier
        collectionView.cellNibName = MGCollectionViewCell.identifier
        collectionView.cellProportion = CGSize.init(width: 2, height: 1)
        collectionView.cellsSpacing = (1, 1, 1, 1)
        collectionView.cellsForRow = cellForRow != nil ? cellForRow! : (iphonePortrait: 1, iphoneLandscape: 2, ipadPortrait: 3, ipadLandscape: 6)
    }

    func itemSelected(item: Any) {
        print(item)
    }
    
    func displayItem(_ item: Any, inCell cell: UICollectionViewCell) -> UICollectionViewCell{
        let cellMg = cell as! MGCollectionViewCell
        cellMg.setItem(item as! [String])
        return cellMg
    }
    
    
    func refreshControlStatus(animating: Bool) {
        print("Collection view refreshControl is animating? \(animating)")
    }
    
    
    func requestDataForPage(page: Int, valuesCallback: ([Any]?) -> ()) {
        print("Collection view request page \(page)")
        let itemPerPage : Int = 15
        let startIndex : Int = (itemPerPage * page)
        let endIndex : Int = min(startIndex + itemPerPage - 1, testarray.count - 1)
        var array : [[String]] = []
        for index in startIndex...endIndex-1 {
            array.append(testarray[index])
        }
        print("Collection view is getting  \(array.count > 0 ? array.count > 1 ? "\(array.count) elements" : "\(array.count) element " : "no elements")")
        valuesCallback(array)
    }
    

    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
