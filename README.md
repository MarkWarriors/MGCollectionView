
# MGCollectionView
A customized UICollectionView that give you the possibility to manage some things to get it work right (with adaptive layout for device type and orientation)

[[https://github.com/username/repository/blob/master/img/octocat.png|alt=octocat]]
### INSTALLATION:
Copy the MGCollectionView.swift in your project, and set it as class of an UICollectionView in storyboard (if you use it, or just instantiate in the code)

In the ViewController add the MGCollectionViewProtocol
#### The methods of the protocol are:
    func itemSelected(item: Any) // REQUIRED - called when an item of the collection is selected
    func displayItem(_ item: Any, inCell cell: UICollectionViewCell) -> UICollectionViewCell // REQUIRED - called to customize the cells
    func requestDataForPage(page: Int, valuesCallback: @escaping ([Any]?)->()) // REQUIRED - request new item to append at the collection view data source
    func refreshControlStatus(animating: Bool) // OPTIONAL - Used to get the notification that the refreshControl startAnimating or stopAnimating
   
And also in the ViewController set the paramters that you want
#### Parameters:
    collectionView.protocolDelegate = self // REQUIRED
    collectionView.pullToRefresh // Bool - if you want to add the pulltorefresh
    collectionView.useInfiniteScroll // Bool - if you want infiniteScroll at the bottom
    collectionView.cellIdentifier // String - identifier for the reusable cell REQUIRED
    collectionView.cellNib // UINib - Nib of your cell. REQUIRED if not setted cellClass
    collectionView.cellClass // String - name of your cell class. REQUIRED if not setted cellNib
    collectionView.cellProportion // CGSize - the proportion (height and with) of every cell
    collectionView.cellsSpacing // (left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) - spacing of the cell @ left, top, right, bottom
    collectionView.cellsForRow // (iphonePortrait: Int, iphoneLandscape: Int, ipadPortrait: Int, ipadLandscape: Int) - number of cell for row for the different device type and orientation
