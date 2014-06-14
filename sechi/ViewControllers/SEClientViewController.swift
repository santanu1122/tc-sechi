/**
 *  View controller used for displaying single client view.
 */
class SEClientViewController: SEViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SESwipeableTableViewCellDelegate, UIGestureRecognizerDelegate {

	/**
	 *  SEClient object that will be displayed.
	 */
	var client: SEClient

	/**
	 *  UITableView used to display object info.
	 */
	@IBOutlet var tableView: UITableView

	/**
	 *  Datasource with UITableViewCell identifiers used to display info.
	 */
	var datasource = String[]()

	/**
	 *  Temporary cell object used to calculate cell height.
	 */
	var tempAddressCell: SEClientAddressTableViewCell

	/**
	 *  Index path of cell that began process of removing (swipe, press delete button etc).
	 */
	var indexPathToRemove: NSIndexPath

	/**
	 *  Gesture recognizer used to cancel the custom edit mode of the table view.
	 */
	var editModeGestureRecognizer: UIPanGestureRecognizer

	/**
	 *  Setup table view properties and cells that will be displayed. Prepare temporary cells for use.
	 */
	override func viewDidLoad()	{
	    super.viewDidLoad()
	    // Do any additional setup after loading the view.
	    
	    self.datasource = [SEClientInfoTableViewCellIdentifier, SEClientAddressTableViewCellIdentifier]
	    
	    self.tableView.delegate = self
	    self.tableView.dataSource = self
	    self.tableView.contentInset = UIEdgeInsetsMake(68, 0, 0, 0)
	    
	    self.tempAddressCell = self.tableView.dequeueReusableCellWithIdentifier(SEClientAddressTableViewCellIdentifier)
	    
	    self.editModeGestureRecognizer = UIPanGestureRecognizer(target:self, action:"viewWasPanned:")
	    self.view.addGestureRecognizer(self.editModeGestureRecognizer)
	    self.editModeGestureRecognizer.delegate = self
	}

	/**
	 *  Setup navigation bar visible, and it's buttons.
	 *
	 *  @param animated
	 */
	func viewWillAppear(animated: Bool) {
	    super.viewWillAppear(animated)
	    self.navigationController.setNavigationBarHidden(false, animated: animated)
	    self.setupNavigationBarBackButton()
	    self.tableView.reloadData()
	}

	#pragma mark - editModeGestureRecognizer
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
	    return true
	}

	/**
	 *  If any swipeable cell is open at the moment of panning the screen, and the pan started not inside this open cell view. This cell will be closed.
	 *
	 *  @param panGestureRecognizer UIPanGestureRecognizer that recognized the pan gesture.
	 */
	func viewWasPanned(panGestureRecognizer: UIPanGestureRecognizer) {
	    if panGestureRecognizer.state == .Began {
	    	if let cell = self.tableView.cellForRowAtIndexPath(self.indexPathToRemove) as? SESwipeableTableViewCell {
	    		var beginingTouchPoint = panGestureRecognizer.locationInView(cell)
		        var xContains = beginingTouchPoint.x > 0 && beginingTouchPoint.x < cell.frame.size.width
		        var yContains = beginingTouchPoint.y > 0 && beginingTouchPoint.y < cell.frame.size.height
		        if !(xContains && yContains) {
		            cell.closeCellAnimated(true)
		            self.tableView.scrollEnabled = true
		        }
	    	}
	    }
	}

	#pragma mark - UIScrollViewDelegate (tableView)
	/**
	 *  Disallow swipe gesture on visible cells when table view did start scrolling.
	 *
	 *  @param scrollView scrollView (table view) that begin scrolling.
	 */
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
	    var visibleCellsIndexPaths = self.tableView.indexPathsForVisibleRows()
	    for var indexPath in visibleCellsIndexPaths {
	    	if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SESwipeableTableViewCell {
	        	cell.swipeEnabled = false
	        }
	    }
	}

	/**
	 *  Allow swipe gesture on visible cells after scroll view (table view) did end decelerating.
	 *
	 *  @param scrollView scroll view (table view) that end decelerating.
	 */
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
	    var visibleCellsIndexPaths = self.tableView.indexPathsForVisibleRows()
	    for var indexPath in visibleCellsIndexPaths {
	    	if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SESwipeableTableViewCell {
	        	cell.swipeEnabled = true
	        }
	    }
	}

	#pragma mark - SESwipeableTableViewCellDelegate
	/**
	 *  Disable table view scrolling when swipe gesture was recognized on any swipeable cells.
	 *
	 *  @param cell SESwipeableTableViewCell that begin swipe gesture.
	 */
	func swipeableCellWillStartMovingContent(cell: SESwipeableTableViewCell) {
	    self.tableView.scrollEnabled = false
	}

	/**
	 *  After opening a new cell, every other that was already opened will be closed.
	 *
	 *  @param cell SESwipeableCell that was opened.
	 */
	func cellDidOpen(cell: SESwipeableTableViewCell) {
	    if let newIndexPathToRemove = self.tableView.indexPathForCell(cell)? {
	    	if self.indexPathToRemove != newIndexPathToRemove {
	    		if let oldCell = self.tableView.cellForRowAtIndexPath(self.indexPathToRemove) as? SESwipeableTableViewCell {
	    			oldCell.closeCellAnimated(true)
	    		}
	    	}
	    	self.indexPathToRemove = newIndexPathToRemove;
	    }
	    self.tableView.scrollEnabled = false
	}

	/**
	 *  Enable table view scrolling after open cell was closed.
	 *
	 *  @param cell SESwipeableTableViewCell that was closed.
	 */
	func cellDidClose(cell: SESwipeableTableViewCell) {
	    self.tableView.scrollEnabled = false
	}

	#pragma mark - UITableViewDatasource
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
	    return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	    return self.datasource.count
	}

	/**
	 *  Setup cell content
	 *
	 *  @param tableView UITableView that the cell will be displayed in
	 *  @param indexPath NSIndexPath at which the cell will be displayed
	 *
	 *  @return UITableViewCell to display
	 */
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
	    var row = indexPath.row
	    var identifier = self.datasource.objectAtIndex(row)
	    var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
	    
	    if let swipableCell = cell as? SESwipeableTableViewCell {
	        swipableCell.setDelegate:self
	    }
	    
	    if let clientInfoCell = cell as? SEClientInfoTableViewCell {
	        clientInfoCell.clientLabel.text = self.client.companyNameC
	        clientInfoCell.contactLabel.text = self.client.name
	        clientInfoCell.phoneLabel.text = self.client.businessPhoneC
	        clientInfoCell.emailLabel.text = self.client.email
	        clientInfoCell.bottomCellView.backgroundColor = UIColor(red: 0.137, green: 0.121, blue: 0.125, alpha: 1)
	        
	        clientInfoCell.callButton.addTarget(self, action: "callButtonTouchedUpInside:", forControlEvents: UIControlEvent.TouchUpInside)
	    }
	    if let addressCell = cell as? SEClientAddressTableViewCell {
	        addressCell.addressLabel.text = self.client.companyAddressC
	        addressCell.addressLabel.font = [SEConstants textFieldFont]
	        addressCell.addressLabel.contentInset = UIEdgeInsetsMake(-8,-4,0,0)
	        addressCell.addressLabel.userInteractionEnabled = false
	        addressCell.bottomCellView.backgroundColor = UIColor(red: 0.137, green: 0.121, blue: 0.125, alpha: 1)
	    }
	    
	    return cell;
	}

	#pragma mark - actions
	/**
	 *  Initiate phone dialer with number from objects property
	 *
	 *  @param sender object that called the method
	 */
	func callButtonTouchedUpInside(sender: UIButton) {
	    var phone = self.client.businessPhoneC.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet()).componentsJoinedByString("");
	    var callUrl = NSURL(string: "tel:" + phone)
	    
	    if UIApplication.sharedApplication().canOpenURL(callUrl) {
	        UIApplication.sharedApplication().openURL(callUrl)
	    } else {
	        UIAlertView(title: "Error", message: "This function is only available on the iPhone", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil).show()
	    }}

	#pragma mark - UITableViewDelegate
	/**
	 *  Calculate height needed for cell based on it's content.
	 *
	 *  @param tableView
	 *  @param indexPath
	 *
	 *  @return height needed by a cell ti display properly all content.
	 */
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> Float {
	    switch indexPath.row {
	        case 0:
	            return 105.0
	        case 1:
	            self.tempAddressCell.addressLabel.text = self.client.companyAddressC
	            return self.tempAddressCell.cellHeightNeeded()
	        default:
	        	return 44.0
	    }
	}

	#pragma mark - Navigation
	/**
	 *  Pass selected object to next view controller if it needs it.
	 *
	 *  @param segue  segue that will occur
	 *  @param sender object that begin the segue
	 */
	func prepareForSegue(segue: UIStoryboardSegue, #sender: AnyObject) {
	    if segue.destinationViewController.respondsToSelector: "setClient:" {
	        segue.destinationViewController.setValue(self.client, forKey: "client")
	    }
	}

}
