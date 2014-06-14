/**
 *  View controller used for displaying list of client objects.
 */
class SEClientsViewController: SEViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, SESwipeableTableViewCellDelegate, UIGestureRecognizerDelegate {
	
	/**
	 *  Fetched results controller used to retrive content for table view.
	 */
	var fetchedResultsController: NSFetchedResultsController

	/**
	 *  Managed object context used by fetched results controller.
	 */
	var managedObjectContext: NSManagedObjectContext

	/**
	 *  Table view with list of objects
	 */
	@IBOutlet var tableView: UITableView

	/**
	 *  Temporary cell used for calculating height of the displayed cells.
	 */
	var var temporaryCell: SEClientTableViewCell

	/**
	 *  Index path of cell that began process of removing (swipe, press delete button etc).
	 */
	var indexPathToRemove: NSIndexPath

	/**
	 *  Gesture recognizer used to cancel the custom edit mode of the table view.
	 */
	var editModeGestureRecognizer: UIPanGestureRecognizer!

	/**
	 *  Setup views properties, gesture recognizer and initiates displayed objects sync.
	 */
	override func viewDidLoad()	{
	    super.viewDidLoad()
	    // Do any additional setup after loading the view.
	    
	    self.managedObjectContext = SERestClient.instance().managedObjectContext
	    
	    self.tableView.delegate = self
	    self.tableView.dataSource = self
	    self.tableView.contentInset = UIEdgeInsetsMake(68, 0, 0, 0)
	    
	    self.editModeGestureRecognizer = UIPanGestureRecognizer(target: self, action: "viewWasPanned:")
	    self.view.addGestureRecognizer(self.editModeGestureRecognizer)
	    self.editModeGestureRecognizer.delegate = self
	    
	    SERestClient.instance.refreshClientsList()
	}

	/**
	 *  Setup navigation bar visible, and it's buttons.
	 *
	 *  @param animated
	 */
	override func viewWillAppear(animated: Bool) {
	    super.viewWillAppear(animated)
	    self.navigationController.setNavigationBarHidden(false, animated: animated)
	    self.setupNavigationBarBackButton()
	    var addButton = self.setupNavigationBarAddButton()
	    addButton.addTarget(self, action: "addButtonTouchedUpInside:", forControlEvents: UIControlEvent.TouchUpInside)
	}

	#pragma mark - actions
	/**
	 *  Show view controller with form for adding new object to the list.
	 *
	 *  @param sender button that called the method
	 */
	func addButtonTouchedUpInside(sender: UIButton) {
	    self.performSegueWithIdentifier(SEPushJobAddViewControllerSegue, sender:self)
	}

	/**
	 *  Display confirm alert after pressing objects delete button.
	 *
	 *  @param sender object that sent the message
	 */
	@IBAction func deleteButtonTouchedUpInside(sender: UIButton) {
	    if let cell = sender.superviewOfClass(UITableViewCell.class) as? UITableViewCell {
	        self.indexPathToRemove = self.tableView.indexPathForCell(cell)
	        
	        UIAlertView(title: "Confirm", message: "Do you want to delete this client?", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: ["YES", nil]).show()
	    }
	}

	/**
	 *  Initiate phone dialer with number from selected objects property
	 *
	 *  @param sender object that called the method
	 */
	@IBAction func callButtonTouchedUpInside(sender: UIButton) {
	    if let cell = sender.superviewOfClass(UITableViewCell.class) as? UITableViewCell {
	    	var indexPath: IndexPath! = self.tableView.indexPathForCell(cell)

	    	var client = self.fetchedResultsController.objectAtIndexPath(indexPath)
	        
	        var phone = client.businessPhoneC.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet()).componentsJoinedByString("")
	        var callUrl = NSURL(string: "tel:" + phone)
	        
	        if UIApplication.sharedApplication().canOpenURL(callUrl) {
	            UIApplication.sharedApplication().openURL(callUrl)
	        }
	        else {
	            UIAlertView(title: "Error", message: "This function is only available on the iPhone", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil).show()
	        }
	    }
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
	    if let visibleCellsIndexPaths = self.tableView.indexPathsForVisibleRows? {
	    	for var indexPath in visibleCellsIndexPaths {
	    		if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SESwipeableTableViewCell {
		        	cell.swipeEnabled = false
		        }
	    	}
		}
	}

	/**
	 *  Allow swipe gesture on visible cells after scroll view (table view) did end decelerating.
	 *
	 *  @param scrollView scroll view (table view) that end decelerating.
	 */
	-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	    var visibleCellsIndexPaths = self.tableView.indexPathsForVisibleRows()
	    for var indexPath in visibleCellsIndexPaths {
	        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SESwipeableTableViewCell {
	        	cell.swipeEnabled = true
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
	    if let newIndexPathToRemove = self.tableView.indexPathForCell(cell) {
		    if self.indexPathToRemove == newIndexPathToRemove {
		        if let oldCell = self.tableView.cellForRowAtIndexPath(self.indexPathToRemove) as? SESwipeableTableViewCell {
		        	oldCell.closeCellAnimated(true)
		        }
		    }
		    self.indexPathToRemove = newIndexPathToRemove
		}
		self.tableView.scrollEnabled = false
	}

	/**
	 *  Enable table view scrolling after open cell was closed.
	 *
	 *  @param cell SESwipeableTableViewCell that was closed.
	 */
	func cellDidClose(cell: SESwipeableTableViewCell) {
	    self.tableView.scrollEnabled = true
	}


	#pragma mark - UIAlertViewDelegate
	/**
	 *  Remove object from database or close opened cell if user confirmed or denied deleting of object in alert view.
	 *
	 *  @param alertView
	 *  @param buttonIndex
	 */
	func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
	    if buttonIndex != alertView.cancelButtonIndex {
	        SEClient* client = [self.fetchedResultsController objectAtIndexPath:self.indexPathToRemove];
	        client.removed = @"true";
	        NSError* error = nil;
	        [client.managedObjectContext save:&error];
	        if(error != nil) {
	            NSLog(@"%@", error);
	        } else {
	            [client.managedObjectContext saveToPersistentStore:&error];
	            if(error != nil) {
	                NSLog(@"%@", error);
	            }
	        }
	        
	        self.indexPathToRemove = nil;
	    } else {
	        SESwipeableTableViewCell* cell = (SESwipeableTableViewCell*)[self.tableView cellForRowAtIndexPath:self.indexPathToRemove];
	        [cell closeCellAnimated:YES];
	        self.tableView.scrollEnabled = YES;
	    }
	}

	/**
	 *  Basic setup of UITableView with NSFetchedResultsViewController
	 */
	#pragma mark - UITableViewDatasource
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
	    return self.fetchedResultsController.sections.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	    let sectionInfo = self.fetchedResultsController.sections[section] as NSFetchedResultsSectionInfo
	    return sectionInfo.numberOfObjects()
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
	    var cell = tableView.dequeueReusableCellWithIdentifier(SEClientTableViewCellIdentifier)
	    cell.delegate = self
	    configureCell(cell, atIndexPath: indexPath)
	    return cell
	}

	#pragma mark - Fetched results controller
	/**
	 *  Setup NSFetchedResultsController for providing data to UITableView
	 */
	- (NSFetchedResultsController *)fetchedResultsController
	{
	    if (_fetchedResultsController != nil) {
	        return _fetchedResultsController;
	    }
	    
	    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SEClient" inManagedObjectContext:self.managedObjectContext];
	    [fetchRequest setEntity:entity];
	    [fetchRequest setFetchBatchSize:20];
	    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
	    NSArray *sortDescriptors = @[sortDescriptor];
	    NSPredicate *deletedPredicate = [NSPredicate predicateWithFormat:@"NOT (removed LIKE %@)", @"true"];
	    [fetchRequest setSortDescriptors:sortDescriptors];
	    [fetchRequest setPredicate:deletedPredicate];
	    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
	                                                                                                managedObjectContext:self.managedObjectContext
	                                                                                                  sectionNameKeyPath:nil
	                                                                                                           cacheName:nil];
	    aFetchedResultsController.delegate = self;
	    self.fetchedResultsController = aFetchedResultsController;
	    
		NSError *error = nil;
		if (![self.fetchedResultsController performFetch:&error]) {
		    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		    abort();
		}
	    
	    return _fetchedResultsController;
	}

	#pragma mark - NSFetchedResultsControllerDelegate
	/**
	 *  Begin table view updates when fetched results controller wants to change datasource.
	 */
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
	    self.tableView.beginUpdates()
	}

	/**
	 *  Change content of table view when fetched results controller is making changes to the datasource.
	 */
	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType {
	    switch type {
	        case .Insert:
	            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
	        case .Delete:
	            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
	        default:
	    }
	}

	/**
	 *  Change content of table view when fetched results controller is making changes to the datasource.
	 */
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath newIndexPath: NSIndexPath) {
	    var tableView = self.tableView
	    
	    switch type {
	        case .Insert:
	            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
	        case .Delete:
	            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
	        case .Update:
	            self.configureCell(tableView.cellForRowAtIndexPath(indexPath), atIndexPath: indexPath)
	        case .Move:
	            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
	            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
	    }
	}

	/**
	 *  End table view updates when fetched results controller finished changeing datasource.
	 */
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
	    self.tableView.endUpdates()
	}

	/**
	 *  Configure UITableViewCell content that will be displayed at specified index path.
	 *
	 *  @param cell      UITableViewCell that needs to be configured.
	 *  @param indexPath index path at which the cell will be displayed.
	 */
	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
	    if let clientCell = cell as? SEClientTableViewCell {
	        var client = self.fetchedResultsController.objectAtIndexPath(indexPath)
	        clientCell.clientNameLabel.text = client.name
	        clientCell.phoneLabel.text = client.businessPhoneC
	        clientCell.bottomCellView.backgroundColor = UIColor(red: 0.85, green: 0.109, blue: 0.36, alpha: 1)
	        
	        clientCell.deleteButtonBg.backgroundColor = UIColor(red: 0.85, green: 0.109, blue: 0.36, alpha: 1)
	        clientCell.callButtonBg.backgroundColor = UIColor(red: 0.137, green: 0.121, blue: 0.125, alpha: 1)
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
		if let vc = segue.destinationViewController as? SEClientViewController {
			if let cell = sender as? UITableViewCell {
				var indexPath = self.tableView.indexPathForCell(cell)
				var client = self.fetchedResultsController.objectAtIndexPath(indexPath)
				vc.client = client
			}
		}
	}
}
