/**
 *  View controller used to display client info from the job object.
 */
class SEJobClientInfoEditViewController: SEViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

	/**
	 *  SEJob object that has client info.
	 */
	var job: SEJob!

	/**
	 *  Table view that will display the form
	 */
	@IBOutlet var tableView: UITableView

	/**
	 *  Datasource array with UITableViewCell objects that needs to be displayed.
	 */
	var datasource: SETextFieldTableViewCell[]!

	/**
	 *  UITableViewCell objects that are displayed in table view.
	 */
	var clientCell: SETextFieldTableViewCell
	var contactCell: SETextFieldTableViewCell
	var phoneCell: SETextFieldTableViewCell
	var infoCell: SETextFieldTableViewCell

	/**
	 *  Setup table view properties and cells that will be displayed
	 */
	func viewDidLoad() {
	    super.viewDidLoad()
	    // Do any additional setup after loading the view.
	    
	    self.setupCells()
	    
	    self.tableView.delegate = self
	    self.tableView.dataSource = self
	    self.tableView.contentInset = UIEdgeInsetsMake(68, 0, 0, 0)
	}

	/**
	 *  Prepare cell for each object field that's a need to be filled.
	 */
	func setupCells() {
	    self.clientCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier)
	    self.clientCell.label = "Client:"
	    self.clientCell.key = "clientNameC"
	    self.clientCell.value = self.job.clientNameC
	    
	    self.contactCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier)
	    self.contactCell.label = "Contact:"
	    self.contactCell.key = "contactNameC"
	    self.contactCell.value = self.job.contactNameC
	    
	    self.phoneCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier)
	    self.phoneCell.label = "Phone:"
	    self.phoneCell.key = "phoneC"
	    self.phoneCell.value = self.job.phoneC
	    
	    self.infoCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier)
	    self.infoCell.label = "Info:"
	    self.infoCell.key = "infoTextC"
	    self.infoCell.value = self.job.infoTextC
	    
	    self.datasource = [self.clientCell, self.contactCell, self.phoneCell, self.infoCell]
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
	    if let backBtn = self.navigationItem.leftBarButtonItem.customView as? UIButton {
	        backBtn.removeTarget(self, action: "popViewControllerAnimated", forControlEvents: .TouchUpInside)
	        backBtn.addTarget(self, action: "saveAndReturn", forControlEvents: .TouchUpInside)
	    }
	}

	/**
	 *  Called after back button was pressed. Validates the data in form, and displays the validation error if any of them is empty.
	 *  If everything is ok, data is saved and view controller is dismissed.
	 */
	func saveAndReturn() {
	    for var cell in self.datasource {
	        if(cell.changesWereMade && (cell.valueTextView.text == nil || [cell.valueTextView.text isKindOfClass:[NSNull class]] || [cell.valueTextView.text isEqualToString:@""])) {
	            UIAlertView(title: "Validation error", message: String(format: "%@ field cannot be empty", cell.label.stringByReplacingOccurrencesOfString(":", withString: "")), delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil).show()
	            return
	        }
	        
	        self.job.setValue(cell.valueTextView.text, forKey: cell.key)
	    }
	    
	    var error: NSError?
	    self.job.managedObjectContext.save(&error)
	    
	    if error {
	        NSLog("%@", error!)
	    } else {
	        self.job.managedObjectContext.saveToPersistentStore(&error)
	        if error {
	            NSLog("%@", error!)
	        }
	    }
	    
	    if error {
	        UIAlertView(title: "Error", message: "Error occured while saving data: " + error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil).show()
	    }
	    
	    self.navigationController.popViewControllerAnimated(true)
	}

	#pragma mark - UITextViewDelegate
	/**
	 *  Hide keyboard on return when text view is a first responder
	 *
	 *  @param textView
	 *  @param range
	 *  @param text
	 *
	 *  @return BOOL should change the content of the text view
	 */
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
	    if text = "\n" {
	        textView.resignFirstResponder()
	        return false
	    }
	    return true
	}

	/**
	 *  Scroll table view to cell that began editing.
	 *
	 *  @param textView text view that began editing.
	 */
	func textViewDidBeginEditing(textView: UITextView) {
	    var cell = (UITableViewCell*)[textView superviewOfClass:[UITableViewCell class]];
	    self.tableView.scrollToRowAtIndexPath(self.tableView.indexPathForCell(cell), atScrollPosition: .Top, animated: true)
	}

	/**
	 *  Recalculate height of the cell based on the text view content after it changes.
	 *
	 *  @param textView UITextView that changed the content.
	 */
	func textViewDidChange(textView: UITextView) {
	    var cell = (SETextFieldTableViewCell*)[textView superviewOfClass:[SETextFieldTableViewCell class]];
	    var heightNeeded = cell.cellHeightForText(cell.valueTextView.text)
	    if cell.frame.size.height != heightNeeded {
	        cell.height = heightNeeded
	        self.tableView.beginUpdates()
	        self.tableView.endUpdates()
	    }
	}

	#pragma mark - UITableViewDatasource
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
	    return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	    return self.datasource.count
	}

	/**
	 *  Return table view cell from datasource and set it's text view delegate to self.
	 *
	 *  @param tableView
	 *  @param indexPath
	 *
	 *  @return UITableViewCell to display in tableView at indexPath
	 */
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
	    var cell = self.datasource[indexPath.row]
	    cell.valueTextView.delegate = self
	    return cell
	}

	/**
	 *  Return height for the table view cell for displaying in tableView at indexPath
	 *
	 *  @param tableView
	 *  @param indexPath
	 *
	 *  @return height for the table view cell for displaying in tableView at indexPath
	 */
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> Float {
	    var cell = self.datasource[indexPath.row]
	    return cell.height
	}

}
