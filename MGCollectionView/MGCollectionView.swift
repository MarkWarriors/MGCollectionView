//
//  MGCollectionView.swift
//  MGCollectionView
//
//  Created by Marco Guerrieri on 11/03/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit



@objc protocol MGCollectionViewProtocol {
    @objc func collectionViewSelected(cell: UICollectionViewCell, withItem: Any)
    @objc func collectionViewDisplayItem(_ item: Any, inCell cell: UICollectionViewCell) -> UICollectionViewCell
    @objc func collectionViewRequestDataForPage(page: Int, valuesCallback: @escaping ([Any]?)->())
    @objc optional func collectionViewPullToRefreshControlStatusIs(animating: Bool)
    @objc optional func collectionViewEndUpdating(totalElements: Int)
}


@IBDesignable class MGCollectionView : UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public typealias CellInARowForDeviceAndOrientation = (iphonePortrait: Int, iphoneLandscape: Int, ipadPortrait: Int, ipadLandscape: Int)
    public typealias CellProportions = (width: CGFloat, height: CGFloat)
    public typealias CellSpacing = (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)
    
    public enum CellLayoutTypeEnum {
        case fixedWidthAndHeight
        case fixedNumberForRow
    }
    public typealias CellLayoutType = CellLayoutTypeEnum
    
    var pullToRefresh : Bool = false
    var useInfiniteScroll : Bool = false
    var cellNib : UINib? = nil
    var cellIdentifier : String? = nil
    var cellClass : AnyClass? = nil
    var useLoaderAtBottom : Bool = true
    var autoDeselectItem : Bool = true
    
    public var items : [Any] = []
    
    private var cellProportions : CellProportions = (width: 0, height: 0)
    private var cellSpacing : CellSpacing  = (top: 0, left: 0, bottom: 0, right: 0)
    private var cellLayoutType : CellLayoutType?
    private var cellsWidth : CGFloat = 0
    private var cellsHeight : CGFloat = 0
    private var cellsForRow : CellInARowForDeviceAndOrientation = (1, 1, 1, 1)
    private var currentPage : Int = 0
    private var isLoading : Bool = false
    private var endInifiniteScroll = false
    private var footerHeight : CGFloat = 0.0
    
    public private(set)var cvRefreshControl : UIRefreshControl = UIRefreshControl()
    
    var protocolDelegate : MGCollectionViewProtocol? = nil
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func initWithCellFixed(width: CGFloat, height: CGFloat){
        cellLayoutType = .fixedWidthAndHeight
        self.cellsWidth = width
        self.cellsHeight = height
        self.cellProportions = (width: width, height: height)
        initCollectionView()
    }
    
    func initWithCellFixedNumberOf(_ cellsForRow: CellInARowForDeviceAndOrientation, cellProportions proportions: CellProportions, andSpacing spacing: CellSpacing){
        self.cellLayoutType = .fixedNumberForRow
        self.cellsForRow = cellsForRow
        self.cellProportions = proportions
        self.cellSpacing = spacing
        initCollectionView()
    }
    
    private func initCollectionView() {
        self.delegate = self
        self.dataSource = self
        
        if cellLayoutType == nil {
            print("#MGCollectionView: No layout type provided")
            return
        }
        
        if cellLayoutType == .fixedWidthAndHeight {
            if cellsWidth == 0 {
                assertionFailure("#MGCollectionView: The cell width is 0.")
            }
            if cellsWidth > self.frame.size.width {
                print("#MGCollectionView: The cell width is greater then the Collection view. Change it to the width of the Collection View.")
            }
        }
        
        
        if self.cellProportions.width == 0 || self.cellProportions.height == 0 {
            assertionFailure("#MGCollectionView: cell proportion with a dimension equal to 0.")
        }
        
        if cellIdentifier == nil {
            assertionFailure("#MGCollectionView: cellIdentifier required")
        }
        
        if cellNib != nil {
            self.register(cellNib, forCellWithReuseIdentifier: cellIdentifier!)
        }
        else if cellClass != nil {
            self.register(cellClass, forCellWithReuseIdentifier: cellIdentifier!)
        }
        
        if pullToRefresh {
            cvRefreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
            self.addSubview(cvRefreshControl)
        }
        
        if useLoaderAtBottom {
            self.register(MGCollectionViewFooter.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")
        }
        
        askItemsForPage(currentPage)
    }
    
    @objc
    private func refreshTriggered() {
        endInifiniteScroll = false
        isLoading = true
        items.removeAll()
        currentPage = 0
        if protocolDelegate?.collectionViewPullToRefreshControlStatusIs != nil {
            protocolDelegate?.collectionViewPullToRefreshControlStatusIs!(animating: true)
        }
        askItemsForPage(currentPage)
    }
    
    func clearItems(){
        self.currentPage = 0
        self.items.removeAll()
        reloadCollectionView()
    }
    
    func addItems(_ newItems: [Any]){
        self.items.append(contentsOf: newItems)
        reloadCollectionView()
    }
    
    func reloadCollectionView(){
        DispatchQueue.main.async {
            self.reloadData()
            self.performBatchUpdates({
            }, completion: { (completed) in
                if self.cvRefreshControl.isRefreshing {
                    self.cvRefreshControl.endRefreshing()
                    if self.protocolDelegate?.collectionViewPullToRefreshControlStatusIs != nil {
                        self.protocolDelegate?.collectionViewPullToRefreshControlStatusIs!(animating: false)
                    }
                    if self.protocolDelegate?.collectionViewEndUpdating != nil {
                        self.protocolDelegate?.collectionViewEndUpdating!(totalElements: self.items.count)
                    }
                }
                if self.useInfiniteScroll {
                    self.checkIfNeedMoreItems()
                }
                self.isLoading = false
            })
        }
    }
    
    func askItemsForPage(_ page: Int) {
        protocolDelegate?.collectionViewRequestDataForPage(page: currentPage, valuesCallback: { (newValues) in
            if newValues != nil && newValues!.count > 0 {
                self.addItems(newValues!)
            }
            else {
                self.endInifiniteScroll = true
                self.isLoading = false
                DispatchQueue.main.async {
                    self.collectionViewLayout.invalidateLayout()
                }
            }
        })
    }
    
    private func checkIfNeedMoreItems(){
        if contentSize.height < frame.size.height {
            currentPage += 1
            self.askItemsForPage(currentPage)
        }
    }
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if useInfiniteScroll && !isLoading && self.items.count > 0 && !endInifiniteScroll {
            let actualPosition : CGFloat = contentOffset.y + frame.size.height
            let contentHeight = contentSize.height - (50)
            if actualPosition >= contentHeight {
                isLoading = true
                currentPage = currentPage + 1
                askItemsForPage(currentPage)
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
            let item = items[indexPath.row]
            return (protocolDelegate?.collectionViewDisplayItem(item, inCell: cell))!
        }
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if autoDeselectItem {
            self.deselectItem(at: indexPath, animated: true)
        }
        if items.count > indexPath.row {
            let item = items[indexPath.row]
            protocolDelegate?.collectionViewSelected(cell: cell, withItem: item)
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width : CGFloat = 0
        var height : CGFloat = 0
        if cellLayoutType == .fixedWidthAndHeight {
            if cellsWidth > self.frame.size.width{
                cellsWidth = self.frame.size.width
            }
            width = cellsWidth
            height = cellsHeight
        }
        else if cellLayoutType == .fixedNumberForRow {
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
            
            width = (self.frame.size.width / CGFloat(cfr)) - CGFloat(cellSpacing.left + cellSpacing.right)
            height = CGFloat(width * cellProportions.height / cellProportions.width) - CGFloat(cellSpacing.top + cellSpacing.bottom)
        }
        return CGSize.init(width: width, height: height)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if cellLayoutType == .fixedWidthAndHeight {
            let width = cellsWidth
            let estimatedCellsForRow : Int = Int(floor(self.frame.size.width / width))
            let estimatedSpacing : CGFloat = (self.frame.size.width - (CGFloat(estimatedCellsForRow) * width)) / CGFloat(estimatedCellsForRow * 2)
            return UIEdgeInsetsMake(estimatedSpacing, estimatedSpacing, estimatedSpacing, estimatedSpacing)
        }
        else if cellLayoutType == .fixedNumberForRow {
            return UIEdgeInsetsMake(cellSpacing.top, cellSpacing.left, cellSpacing.bottom, cellSpacing.right)
        }
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if useInfiniteScroll && !endInifiniteScroll && useLoaderAtBottom{
            footerHeight = 70
        }
        else {
            footerHeight = 0
        }
        return CGSize.init(width: self.bounds.size.width, height: footerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter && useLoaderAtBottom {
            return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath) as! MGCollectionViewFooter
        }
        return UICollectionReusableView.init(frame: CGRect.zero)
    }
    
    
}

class MGCollectionViewFooter : UICollectionReusableView {
    let ref = UIActivityIndicatorView.init(frame: CGRect.init(x: 0, y: 0, width: 35, height: 35))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        ref.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(ref)
        addConstraint(NSLayoutConstraint.init(item: ref, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: ref, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        ref.center = self.center
        ref.startAnimating()
        ref.isHidden = false
        ref.hidesWhenStopped = false
        ref.color = UIColor.black
        self.bringSubview(toFront: ref)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

