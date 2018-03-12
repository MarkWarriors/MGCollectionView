
# MGCollectionView
Well a collection view that give you to manage few things to get it work right (with adaptive layout for device type and orientation)

### INSTALLATION:
Copy the MGCollectionView.swift in your project, and set it as class of an UICollectionView in storyboard (if you use it, or just instantiate in the code)

In the ViewController add the MGCollectionViewProtocol
#### The methods of the protocol are:
    func itemSelected(item: Any)
    func displayItem(_ item: Any, inCell cell: UICollectionViewCell) -> UICollectionViewCell
    func requestDataForPage(page: Int) -> [Any]
    func refreshControlStatus(animating: Bool) // OPTIONAL!!
   
And also in the ViewController set the paramters that you want
#### Parameters:
    collectionView.protocolDelegate = self // NEEDED
    collectionView.pullToRefresh = true // if you want to add the pulltorefresh
    collectionView.useInfiniteScroll = true // if you want infiniteScroll at the bottom
    collectionView.cellIdentifier = identifier // identifier of your cell
    collectionView.cellNibName = nibName // nibName of your cell or use cellClass and pass the class of your cell
    collectionView.cellProportion = CGSize.init(width: 2, height: 1) // the proportion (height and with) of every cell
    collectionView.cellsSpacing = (left: 1, top: 1, right: 1, bottom: 1) // spacing of the cell @ left, top, right, bottom
    collectionView.cellsForRow = (iphonePortrait: 1, iphoneLandscape: 2, ipadPortrait: 3, ipadLandscape: 6) // number of cell for row for the different device type and orientation
    
