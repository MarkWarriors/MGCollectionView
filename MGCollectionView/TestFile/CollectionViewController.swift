//
//  CollectionViewController.swift
//  MGCollectionView
//
//  Created by Marco Guerrieri on 11/03/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

class CollectionViewController: ViewController, MGCollectionViewProtocol {
    
    public var useFixedDimesnions : Bool = false
    public var fixedDimensions : CGSize = CGSize.init(width: 0, height: 0)
    public var cellForRow : (iphonePortrait: Int, iphoneLandscape: Int, ipadPortrait: Int, ipadLandscape: Int) = (1, 3, 3, 4)
    public var cellSpacing : (left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) = (1, 1, 1, 1)
    public var cellProportion : (width: CGFloat, height: CGFloat) = (width: 1, height: 1)
    public var usePullToRefresh : Bool = false
    public var useInfiniteScroll : Bool = false
    public var testWithRequest : Bool = false
    
    private var testarray : [[String]] = []
    private let spacexLaunchUrl : URL = URL.init(string: "https://api.spacexdata.com/v2/launches/")!

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
        collectionView.pullToRefresh = usePullToRefresh
        collectionView.useInfiniteScroll = useInfiniteScroll
        collectionView.cellIdentifier = MGCollectionViewCell.identifier
        collectionView.cellNib = UINib.init(nibName: MGCollectionViewCell.identifier, bundle: nil)
        if useFixedDimesnions {
            collectionView.initWithCellFixed(width: fixedDimensions.width, height: fixedDimensions.height)
        }
        else {
            collectionView.initWithCellFixedNumberOf(cellForRow, cellProportions: cellProportion, andSpacing: cellSpacing)
        }
        
    }

    func collectionViewItemSelected(item: Any) {
        print(item)
    }
    
    func collectionViewDisplayItem(_ item: Any, inCell cell: UICollectionViewCell) -> UICollectionViewCell{
        let cellMg = cell as! MGCollectionViewCell
        cellMg.setItem(item as! [String])
        return cellMg
    }
    
    
    func collectionViewPullToRefreshControlStatusIs(animating: Bool) {
        print("Collection view refreshControl is animating? \(animating)")
    }
    
    func collectionViewEndUpdating(totalElements: Int){
        print("Collection view end update with a total of \(totalElements) elements")
    }
    
    func collectionViewRequestDataForPage(page: Int, valuesCallback: @escaping ([Any]?) -> ()) {
        let itemPerPage : Int = 15
        if testWithRequest {
            print("Collection view request page \(page) - Test with web request")
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: { // Just for show the loader
                var request = URLRequest(url: self.spacexLaunchUrl)
                request.httpMethod = "GET"
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print(error?.localizedDescription ?? "No data")
                        return
                    }
                    var flightArray : [[String]] = []
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [[String: Any]] {
                        let startIndex : Int = min((itemPerPage * page), responseJSON.count)
                        let endIndex : Int = min(startIndex + itemPerPage - 1, responseJSON.count - 1)
                        if startIndex < endIndex {
                            let arraySlice = responseJSON[startIndex...endIndex]
                            for flight in arraySlice {
                                if let rocket = flight["rocket"] as? [String:Any] {
                                    var item : [String] = []
                                    let flightNumber = flight["flight_number"] as? Int ?? 0
                                    let rocketName = rocket["rocket_name"] as? String ?? ""
                                    let date : String = flight["launch_year"] as? String ?? ""
                                    let details = flight["details"]
                                    item.append("Flight \(flightNumber): \(rocketName) (\(date))")
                                    item.append("\(details ?? "")")
                                    flightArray.append(item)
                                }
                            }
                        }
                        valuesCallback(flightArray)
                    }
                }
                
                task.resume()
            })
        }
        else {
            print("Collection view request page \(page)")
            let startIndex : Int = min((itemPerPage * page), testarray.count)
            let endIndex : Int = min(startIndex + itemPerPage - 1, testarray.count - 1)
            var array : [[String]] = []
            if startIndex < endIndex{
                for index in startIndex...endIndex-1 {
                    array.append(testarray[index])
                }
            }
            print("Collection view is getting  \(array.count > 0 ? array.count > 1 ? "\(array.count) elements" : "\(array.count) element " : "no elements")")
            valuesCallback(array)
        }
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


