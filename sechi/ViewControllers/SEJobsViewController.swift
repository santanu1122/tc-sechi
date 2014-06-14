/**
 *  View controller used for displaying list of job objects. (Schedule list)
 */
class SEJobsViewController: SEViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, SESwipeableTableViewCellDelegate,UIGestureRecognizerDelegate {

	/**
	 *  Fetched results controller used to retrive content for table view.
	 */
	var fetchedResultsController: NSFetchedResultsController {
		get {
	    
	    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SEJob" inManagedObjectContext:self.managedObjectContext];
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
	}

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
	var temporaryCell: SEJobTableViewCell

	/**
	 *  Index path of cell that began process of removing (swipe, press delete button etc).
	 */
	var indexPathToRemove: NSIndexPath

	/**
	 *  Gesture recognizer used to cancel the custom edit mode of the table view.
	 */
	var editModeGestureRecognizer: UIPanGestureRecognizer

	/**
	 *  Setup delegates and gesture recognizer for swipeable cells
	 */
	override func viewDidLoad() {
	    super.viewDidLoad()
	    // Do any additional setup after loading the view.
	    
	    self.managedObjectContext = [[SERestClient instance] managedObjectContext];
	    
	    self.tableView.delegate = self
	    self.tableView.dataSource = self
	    self.tableView.contentInset = UIEdgeInsetsMake(74, 0, 0, 0)
	    
	    self.editModeGestureRecognizer = UIPanGestureRecognizer(target: self, action: "viewWasPanned:");
	    self.view.addGestureRecognizer(self.editModeGestureRecognizer)
	    self.editModeGestureRecognizer.delegate = self
	    
	    [[SERestClient instance] refreshJobsList()
	}

	/**
	 *  Setup navigation bar buttons
	 *
	 *  @param animated
	 */
	override func viewWillAppear(animated: Bool) {
	    super.viewWillAppear(animated)
	    self.navigationController.setNavigationBarHidden(false, animated: animated)
	    self.setupNavigationBarBackButton()
	    if let addButton = self.setupNavigationBarAddButton() {
	    	addButton.addTarget(self, action: "addButtonTouchedUpInside:", forControlEvents: .TouchUpInside)
		}
	}

	#pragma mark - actions
	/**
	 *  Pushing SEJobAddViewController after add button was pressed
	 *
	 *  @param sender
	 */
	func addButtonTouchedUpInside(sender: UIButton) {
	    self.performSegueWithIdentifier(SEPushJobAddViewControllerSegue, sender:self)
	}

	/**
	 *  Asks for confirmation before deleting row
	 *
	 *  @param sender
	 */
	@IBAction func deleteButtonTouchedUpInside(sender: UIButton) {
	    var cell = (UITableViewCell*)[sender superviewOfClass:([UITableViewCell class])];
	    
	    if let cell = ... {
	        self.indexPathToRemove = self.tableView.indexPathForCell(cell)
	        
	        UIAlertView(title: "Confirm", message: "Do you want to delete this job?", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: ["YES", nil]).show()
	    }
	}

	#pragma mark - editModeGestureRecognizer
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
	    return true
	}

	/**
	 *  If table is in edit mode, and user starts touching other place than the current cell, edit mode will be canceled.
	 *
	 *  @param panGestureRecognizer
	 */
	func viewWasPanned(panGestureRecognizer: UIPanGestureRecognizer) {
	    if panGestureRecognizer.state == .Began {
	        var cell = self.tableView.cellForRowAtIndexPath(self.indexPathToRemove) as SESwipeableTableViewCell
	        var beginingTouchPoint = panGestureRecognizer.locationInView(cell)
	        var xContains = beginingTouchPoint.x > 0 && beginingTouchPoint.x < cell.frame.size.width
	        var yContains = beginingTouchPoint.y > 0 && beginingTouchPoint.y < cell.frame.size.height
	        if !(xContains && yContains) {
	            cell.closeCellAnimated(true)
	            self.tableView.scrollEnabled = true
	        }
	    }
	}

	#pragma mark - UIScrollViewDelegate (tableView)
	/**
	 *  Lock swipe gesture on cells when table is being scrolled
	 *
	 *  @param scrollView
	 */
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
	    var visibleCellsIndexPaths = self.tableView.indexPathsForVisibleRows()
	    for var indexPath in visibleCellsIndexPaths {
	        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as SESwipeableTableViewCell
	        cell.swipeEnabled = false
	    }
	}

	/**
	 *  Enable swipeability on cells when table view stops scrolling
	 *
	 *  @param scrollView
	 */
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
	    var visibleCellsIndexPaths = self.tableView.indexPathsForVisibleRows()
	    for indexPath in visibleCellsIndexPaths {
	        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as SESwipeableTableViewCell
	        cell.swipeEnabled = true
	    }
	}

	#pragma mark - SESwipeableTableViewCellDelegate
	/**
	 *  Lock table view scroll when cell sipe gesture started
	 *
	 *  @param cell swipeable cell that started moving content
	 */
	func swipeableCellWillStartMovingContent(cell: SESwipeableTableViewCell) {
	    self.tableView.scrollEnabled = false
	}

	/**
	 *  called after swipeable cell opens its contents
	 *
	 *  @param cell
	 */
	func cellDidOpen(cell: SESwipeableTableViewCell) {
	    var newIndexPathToRemove = self.tableView.indexPathForCell(cell)
	    
	    if self.indexPathToRemove != newIndexPathToRemove {
	        var oldCell = self.tableView.cellForRowAtIndexPath(self.indexPathToRemove) as SESwipeableTableViewCell
	        oldCell.closeCellAnimated(true)
	    }
	    
	    self.indexPathToRemove = newIndexPathToRemove
	    self.tableView.scrollEnabled = false
	}

	/**
	 *  called after swipeable cell will close its content
	 *
	 *  @param cell
	 */
	func cellDidClose(cell: SESwipeableTableViewCell) {
	    self.tableView.scrollEnabled = true
	}

	#pragma mark - UIAlertViewDelegate
	/**
	 *  If user confirmed delete action, row is deleted. Otherwise delete button will be hidden
	 *
	 *  @param alertView
	 *  @param buttonIndex
	 */
	func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
	    if buttonIndex != alertView.cancelButtonIndex {
	        var job = self.fetchedResultsController.objectAtIndexPath(self.indexPathToRemove)
	        job.removed = "true"
	        var error: NSError
	        job.managedObjectContext.save(&error)
	        if error {
	            NSLog("%@", error!)
	        } else {
	            job.managedObjectContext.saveToPersistentStore(&error)
	            if error {
	                NSLog("%@", error!)
	            }
	        }
	        
	        self.indexPathToRemove = nil
	    } else {
	        var cell = self.tableView.cellForRowAtIndexPath(self.indexPathToRemove) as SESwipeableTableViewCell
	        cell.closeCellAnimated(true)
	        self.tableView.scrollEnabled = true
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
	    var sectionInfo = self.fetchedResultsController.sections[section]
	    return sectionInfo.numberOfObjects()
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
	    var cell = tableView.dequeueReusableCellWithIdentifier(SEJobTableViewCellIdentifier)
	    cell.delegate = self
	    self.configureCell(cell, atIndexPath: indexPath)
	    return cell
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
	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
	    switch type {
	        case .Insert:
	            self.tableView.insertSections(NSIndexSet.indexSetWithIndex(sectionIndex), withRowAnimation: .Fade)
	        case .Delete:
	            self.tableView.deleteSections(NSIndexSet.indexSetWithIndex(sectionIndex), withRowAnimation: .Fade)
	    }
	}

	/**
	 *  Change content of table view when fetched results controller is making changes to the datasource.
	 */
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath newIndexPath: NSIndexPath) {
	    var tableView = self.tableView;
	    
	    switch type {
	        case .Insert:
	            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
	        case .Delete:
	            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
	        case .Update:
	            self.configureCell(tableView.cellForRowAtIndexPath(indexPath), atIndexPath: indexPath)
	        case .Move:
	            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
	            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
	    }
	}

	/**
	 *  End table view updates when fetched results controller finished changeing datasource.
	 */
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
	    self.tableView.endUpdates()
	}

	/**
	 *  Set cell's content
	 *
	 *  @param cell      current cel
	 *  @param indexPath current index path
	 */
	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
	    if let jobCell as? SEJobTableViewCell {
	        var job = self.fetchedResultsController.objectAtIndexPath(indexPath)
	        jobCell.clientNameLabel.text = job.clientNameC
	        jobCell.contactNameLabel.text = job.contactNameC
	        jobCell.jobAddressLabel.text = job.jobAddressC
	        
	        var dateFormatter = NSDateFormatter()
	        dateFormatter.timeStyle = NSDateFormatter.NoStyle
	        dateFormatter.dateStyle = NSDateFormatter.MediumStyle
	        
	        var timeFormatter = NSDateFormatter()
	        timeFormatter.timeStyle = NSDateFormatter.ShortStyle
	        timeFormatter.dateStyle = NSDateFormatter.NoStyle
	        
	        jobCell.dateLabel.text = dateFormatter.stringFromDate(job.jobStartTimeC).uppercaseString()
	        jobCell.timeLabel.text = timeFormatter.stringFromDate(job.jobStartTimeC).lowercaseString().stringByReplacingOccurrencesOfString(" ", withString:"")
	        
	        jobCell.statusImageView.image = UIImage.imageNamed(job.statusC == "Complete" ? "icon_status_small_active" : "icon_status_small")
	        
	        jobCell.bottomCellView.backgroundColor = UIColor(red: 0.85, green: 0.109, blue: 0.36, alpha: 1)
	    }
	}

	#pragma mark - Navigation
	/**
	 *  Prepare for moving to next view controller
	 *
	 *  @param segue
	 *  @param sender
	 */
	func prepareForSegue(segue: UIStoryboardSegue, sender sender: UIView) {
	    if segue.destinationViewController is SEJobViewController && sender is UITableViewCell {
	        var indexPath = self.tableView.indexPathForCell(sender)
	        var job = self.fetchedResultsController.objectAtIndexPath(indexPath)
	        var vc = segue.destinationViewController as SEJobViewController
	        vc.job = job
	    }
	}

}