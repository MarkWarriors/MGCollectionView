//
//  MGCollectionView.swift
//  MGCollectionView
//
//  Created by Marco Guerrieri on 11/03/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

@objc protocol MGCollectionViewProtocol {
    func itemSelected(item: Any)
    func displayItem(_ item: Any, inCell cell: UICollectionViewCell) -> UICollectionViewCell
    func requestDataForPage(page: Int) -> [Any]
    @objc optional func refreshControlStatus(animating: Bool)
}

@IBDesignable class MGCollectionView : UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    typealias IntForDeviceAndOrientation = (iphonePortrait: Int, iphoneLandscape: Int, ipadPortrait: Int, ipadLandscape: Int)

    
    //    var emptyCollectionText : String? = nil
    //    var emptyCollectionView : UIView? = nil
    var cellsForRow : IntForDeviceAndOrientation = (1, 1, 1, 1)
    var cellsSpacing : (left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) = (0, 0, 0, 0)
    var cellProportion : CGSize = CGSize.init(width: 1, height: 1)
    var pullToRefresh : Bool = false
    var useInfiniteScroll : Bool = false
    
    var items : [Any] = []
    private var currentPage : Int = 0
    var cellNibName : String? = nil
    var cellIdentifier : String? = nil
    var cellClass : AnyClass? = nil
    private var isLoading : Bool = false
    private var endInifiniteScroll = false
    
    var mgRefreshControl : UIRefreshControl = UIRefreshControl()
    
    var protocolDelegate : MGCollectionViewProtocol? = nil
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        initCollectionView()
    }
    
    private func initCollectionView() {
        self.delegate = self
        self.dataSource = self
        
        if self.cellProportion.width == 0 || self.cellProportion.height == 0 {
            print("#MGCollectionView: cell have one size equal to 0. Revert to 1:1")
            self.cellProportion = CGSize.init(width: 1, height: 1)
        }
        
        if cellIdentifier == nil {
            print("#MGCollectionView: cellIdentifier required")
            return
        }
        
        if cellNibName != nil && cellIdentifier != nil{
            let cellNib = UINib.init(nibName: self.cellNibName!, bundle: nil)
            self.register(cellNib, forCellWithReuseIdentifier: cellIdentifier!)
        }
        else if cellClass != nil {
            self.register(cellClass, forCellWithReuseIdentifier: cellIdentifier!)
        }
        else {
            print("#MGCollectionView: cellNibName or cellClass required")
        }
        
        if pullToRefresh {
            mgRefreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
            self.addSubview(mgRefreshControl)
        }
        
        askItemsForPage(page: currentPage)
    }
    
    @objc
    private func refreshTriggered(){
        endInifiniteScroll = false
        isLoading = true
        currentPage = 0
        if protocolDelegate?.refreshControlStatus != nil {
            protocolDelegate?.refreshControlStatus!(animating: true)
        }
        askItemsForPage(page: currentPage)
    }
    
    func askItemsForPage(page: Int){
        let newValues = protocolDelegate?.requestDataForPage(page: currentPage)
        if newValues != nil && self.items.count < newValues!.count {
            self.items = newValues!
            reloadData()
            performBatchUpdates({
            }, completion: { (completed) in
                if self.mgRefreshControl.isRefreshing {
                    self.mgRefreshControl.endRefreshing()
                    if self.protocolDelegate?.refreshControlStatus != nil {
                        self.protocolDelegate?.refreshControlStatus!(animating: false)
                    }
                }
                self.isLoading = false
            })
        }
        else {
            endInifiniteScroll = true
            self.isLoading = false
        }
    }
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if useInfiniteScroll && !isLoading && self.items.count > 0 && !endInifiniteScroll {
            let actualPosition : CGFloat = contentOffset.y + frame.size.height
            let contentHeight = contentSize.height - (50)
            if actualPosition >= contentHeight {
                isLoading = true
                currentPage = currentPage + 1
                askItemsForPage(page: currentPage)
            }
        }
    }

    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier!, for: indexPath)
        if items.count > indexPath.row  && protocolDelegate != nil {
            return (protocolDelegate?.displayItem(items[indexPath.row], inCell: cell))!
        }
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.deselectItem(at: indexPath, animated: true)
        if items.count > indexPath.row {
            protocolDelegate?.itemSelected(item: items[indexPath.row])
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cfr : Int = 1
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait || UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portraitUpsideDown {
                cfr = cellsForRow.ipadPortrait
            }
            else {
                cfr = cellsForRow.ipadLandscape
            }
        }
        else {
            if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait || UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portraitUpsideDown {
                cfr = cellsForRow.iphonePortrait
            }
            else {
                cfr = cellsForRow.iphoneLandscape
            }
        }
        
        let width = (UIScreen.main.bounds.width / CGFloat(cfr)) - CGFloat(cellsSpacing.left + cellsSpacing.right)
        let height = CGFloat(width * cellProportion.height / cellProportion.width) - CGFloat(cellsSpacing.top + cellsSpacing.bottom)
        return CGSize.init(width: width, height: height)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(cellsSpacing.top, cellsSpacing.left, cellsSpacing.bottom, cellsSpacing.right)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
    

