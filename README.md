
# MGCollectionView
Customized Swift UICollectionView, it allows you to easily create a collection view and initialize it with a fixed height/width for cell or a more usefull number of cells for row that you can change based on the device type (iphone/ipad) and the orientation of the device (landscape/portrait)

### INSTALLATION:
Copy the MGCollectionView.swift in your project, and set it as class of an UICollectionView in storyboard (if you use it, or just instantiate in the code)

In the ViewController add the MGCollectionViewProtocol
#### The methods of the protocol are:
    func collectionViewSelected(cell: UICollectionViewCell, withItem: Any) // REQUIRED - called when a cell of the collection view is selected
    func collectionViewDisplayItem(_ item: Any, inCell cell: UICollectionViewCell) -> UICollectionViewCell // REQUIRED - called to customize the cells
    func collectionViewRequestDataForPage(page: Int, valuesCallback: @escaping ([Any]?)->()) // REQUIRED - request new item to append at the collection view data source
    func collectionViewPullToRefreshControlStatusIs(animating: Bool) // OPTIONAL - Used to get the notification that the refreshControl startAnimating or stopAnimating
    func collectionViewEndUpdating(totalElements: Int) // OPTIONAL - Used to get the notification that the CollectionView end the insert update and give you the total count of the items in the collection
   
And also in the ViewController set the paramters that you want
#### Parameters:
    collectionView.protocolDelegate = self // REQUIRED
    collectionView.pullToRefresh // Bool - if you want to add the pulltorefresh
    collectionView.useInfiniteScroll // Bool - if you want infiniteScroll at the bottom
    collectionView.cellIdentifier // String - identifier for the reusable cell REQUIRED
    collectionView.cellNib // UINib - Nib of your cell. REQUIRED if not setted cellClass
    collectionView.cellClass // String - name of your cell class. REQUIRED if not setted cellNib
    
#### Init the CollectionView:
    collectionView.initWithCellFixed(width: CGFloat, height: CGFloat) // Setup the CollectionView with fixed width and height for cells
    collectionView.initWithCellFixedNumberOf(cellForRow, cellProportions: (CGFloat, CGFloat), andSpacing: (CGFloat, CGFloat, CGFloat, CGFloat)) // Setup the CollectionView with fixed numbver of rows

#### Screenshots:
Same collection, same code, different orientation and device
##### iPhone (portrait - landscape)
<img src="https://raw.githubusercontent.com/MarkWarriors/MGCollectionView/master/iphone_port.png" width="200"> <img src="https://raw.githubusercontent.com/MarkWarriors/MGCollectionView/master/iphone_land.png" height="200"> 

##### iPad (portrait - landscape)
<img src="https://raw.githubusercontent.com/MarkWarriors/MGCollectionView/master/ipad_port.png" width="200"> <img src="https://raw.githubusercontent.com/MarkWarriors/MGCollectionView/master/ipad_land.png" height="200">
