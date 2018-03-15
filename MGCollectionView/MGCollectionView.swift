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
    func requestDataForPage(page: Int, valuesCallback: @escaping ([Any]?)->())
    @objc optional func refreshControlStatus(animating: Bool)
    
}


@IBDesignable class MGCollectionView : UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public typealias IntForDeviceAndOrientation = (iphonePortrait: Int, iphoneLandscape: Int, ipadPortrait: Int, ipadLandscape: Int)

    var cellsForRow : IntForDeviceAndOrientation = (1, 1, 1, 1)
    var cellsSpacing : (left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) = (0, 0, 0, 0)
    var cellProportion : CGSize = CGSize.init(width: 1, height: 1)
    var pullToRefresh : Bool = false
    var useInfiniteScroll : Bool = false
    var cellNib : UINib? = nil
    var cellIdentifier : String? = nil
    var cellClass : AnyClass? = nil
    var useLoaderAtBottom : Bool = true
    
    public private(set) var items : [Any] = []
    
    private var currentPage : Int = 0
    private var isLoading : Bool = false
    private var endInifiniteScroll = false
    private var footerHeight : CGFloat = 0.0
    
    var cvRefreshControl : UIRefreshControl = UIRefreshControl()
    
    var protocolDelegate : MGCollectionViewProtocol? = nil
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        initCollectionView()
    }

    
    private func initCollectionView() {
        self.delegate = self
        self.dataSource = self
        
        if self.cellProportion.width == 0 || self.cellProportion.height == 0 {
            assertionFailure("#MGCollectionView: cell proportion have one size equal to 0")
        }
        
        if cellIdentifier == nil {
            assertionFailure("#MGCollectionView: cellNibName or cellClass required")
        }
        
        if cellNib != nil {
            self.register(cellNib, forCellWithReuseIdentifier: cellIdentifier!)
        }
        else if cellClass != nil {
            self.register(cellClass, forCellWithReuseIdentifier: cellIdentifier!)
        }
        else {
            assertionFailure("#MGCollectionView: cellNibName or cellClass required")
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
        if protocolDelegate?.refreshControlStatus != nil {
            protocolDelegate?.refreshControlStatus!(animating: true)
        }
        askItemsForPage(currentPage)
    }
    
    func askItemsForPage(_ page: Int) {
        protocolDelegate?.requestDataForPage(page: currentPage, valuesCallback: { (newValues) in
            if newValues != nil && newValues!.count > 0 {
                self.items.append(contentsOf: newValues!)
                DispatchQueue.main.async {
                    self.reloadData()
                    self.performBatchUpdates({
                    }, completion: { (completed) in
                        if self.cvRefreshControl.isRefreshing {
                            self.cvRefreshControl.endRefreshing()
                            if self.protocolDelegate?.refreshControlStatus != nil {
                                self.protocolDelegate?.refreshControlStatus!(animating: false)
                            }
                        }
                        self.isLoading = false
                        self.checkIfNeedMoreItems()
                    })
                }
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

