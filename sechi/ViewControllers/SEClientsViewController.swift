//
//  SEClientsViewController.swift
//  sechi
//
//  Created by TCSASSEMBLER on 2014-06-13.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

/**
 *  View controller used for displaying list of client objects.
 */
class SEClientsViewController: SEViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, SESwipeableTableViewCellDelegate, UIGestureRecognizerDelegate {

    /**
     *  Managed object context used by fetched results controller.
     */
    var managedObjectContext: NSManagedObjectContext!

    /**
     *  Table view with list of objects
     */
    @IBOutlet var tableView: UITableView

    /**
     *  Index path of cell that began process of removing (swipe, press delete button etc).
     */
    var indexPathToRemove: NSIndexPath?

    /**
     *  Gesture recognizer used to cancel the custom edit mode of the table view.
     */
    var editModeGestureRecognizer: UIPanGestureRecognizer!

    /**
     *  Setup views properties, gesture recognizer and initiates displayed objects sync.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.managedObjectContext = SERestClient.instance().managedObjectContext
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsetsMake(68, 0, 0, 0)
        
        self.editModeGestureRecognizer = UIPanGestureRecognizer(target: self, action: "viewWasPanned:")
        self.view.addGestureRecognizer(self.editModeGestureRecognizer)
        self.editModeGestureRecognizer.delegate = self
        
        SERestClient.instance().refreshClientsList()
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
        addButton.addTarget(self, action: "addButtonTouchedUpInside:", forControlEvents: .TouchUpInside)
    }

    /**
     *  Show view controller with form for adding new object to the list.
     *
     *  @param sender button that called the method
     */
    func addButtonTouchedUpInside(sender: UIButton) {
        self.performSegueWithIdentifier(SEPushJobAddViewControllerSegue, sender: self)
    }

    /**
     *  Display confirm alert after pressing objects delete button.
     *
     *  @param sender object that sent the message
     */
    @IBAction func deleteButtonTouchedUpInside(sender: UIButton) {
        if let cell = sender.superviewOfClass(UITableViewCell) as? UITableViewCell {
            self.indexPathToRemove = self.tableView.indexPathForCell(cell)
            
            UIAlertView(title: "Confirm", message: "Do you want to delete this client?", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES", nil).show()
        }
    }

    /**
     *  Initiate phone dialer with number from selected objects property
     *
     *  @param sender object that called the method
     */
    @IBAction func callButtonTouchedUpInside(sender: UIButton) {
        if let cell = sender.superviewOfClass(UITableViewCell) as? UITableViewCell {
            var indexPath = self.tableView.indexPathForCell(cell)

            var client = self.fetchedResultsController.objectAtIndexPath(indexPath)
            
            var phone = client.businessPhoneC.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet()).componentsJoinedByString("")
            var callUrl = NSURL(string: "tel:" + phone)
            
            if UIApplication.sharedApplication().canOpenURL(callUrl) {
                UIApplication.sharedApplication().openURL(callUrl)
            } else {
                UIAlertView(title: "Error", message: "This function is only available on the iPhone", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil).show()
            }
        }
    }

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

    /**
     *  Disallow swipe gesture on visible cells when table view did start scrolling.
     *
     *  @param scrollView scrollView (table view) that begin scrolling.
     */
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if let visibleCellsIndexPaths = self.tableView.indexPathsForVisibleRows() {
            for indexPath in visibleCellsIndexPaths {
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
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var visibleCellsIndexPaths = self.tableView.indexPathsForVisibleRows()
        for indexPath in visibleCellsIndexPaths {
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SESwipeableTableViewCell {
                cell.swipeEnabled = true
            }
        }
    }

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

    /**
     *  Remove object from database or close opened cell if user confirmed or denied deleting of object in alert view.
     *
     *  @param alertView
     *  @param buttonIndex
     */
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            var client = self.fetchedResultsController.objectAtIndexPath(self.indexPathToRemove)
            client.removed = "true"
            var error: NSError? = nil
            client.managedObjectContext.save(&error)
            if error {
                NSLog("%@", error!)
            } else {
                client.managedObjectContext.saveToPersistentStore(&error)
                if error {
                    NSLog("%@", error!)
                }
            }
            
            self.indexPathToRemove = nil
        } else {
            var cell = self.tableView.cellForRowAtIndexPath(self.indexPathToRemove)
            cell.closeCellAnimated(true)
            self.tableView.scrollEnabled = true
        }
    }

    /**
     *  Basic setup of UITableView with NSFetchedResultsViewController
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections[section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(SEClientTableViewCellIdentifier) as SEClientTableViewCellIdentifier
        cell.delegate = self
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    /**
     *  Fetched results controller used to retrive content for table view.
     */
    var fetchedResultsController: NSFetchedResultsController {
        get {
            if _fetchedResultsController {
                return _fetchedResultsController
            }
        
            var fetchRequest = NSFetchRequest()
            var entity = NSEntityDescription.entityForName("SEClient", inManagedObjectContext: self.managedObjectContext)
            fetchRequest.entity = entity
            fetchRequest.fetchBatchSize = 20
            var sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
            var deletedPredicate = NSPredicate(format: "NOT (removed LIKE %@)", "true")
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = deletedPredicate
            _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            _fetchedResultsController.delegate = self
        
            var error: NSError? = nil
            if !_fetchedResultsController.performFetch(&error) {
                NSLog("Unresolved error %@, %@", error, error.userInfo)
                abort()
            }
        
            return _fetchedResultsController
        }
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil

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
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                break
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

    /**
     *  Pass selected object to next view controller if it needs it.
     *
     *  @param segue  segue that will occur
     *  @param sender object that begin the segue
     */
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        if let vc = segue.destinationViewController as? SEClientViewController {
            if let cell = sender as? UITableViewCell {
                var indexPath = self.tableView.indexPathForCell(cell)
                var client = self.fetchedResultsController.objectAtIndexPath(indexPath)
                vc.client = client
            }
        }
    }
}
