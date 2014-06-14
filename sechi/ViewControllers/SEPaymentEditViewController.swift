/**
 *  View controller used for displaying form that's used for editing payment object.
 */
class SEPaymentEditViewController: SEViewController, UITableViewDataSource, UITableViewDelegate,UITextViewDelegate>

	/**
	 *  Pointer for object that will be edited.
	 */
	var payment: SEPayment

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
	var clientCell: SETextFieldTableViewCell!
	var amountCell: SETextFieldTableViewCell!
	var jobCell: SETextFieldTableViewCell!
	var noteCell: SETextFieldTableViewCell!

	/**
	 *  Setup table view properties and cells that will be displayed
	 */
	override func viewDidLoad() {
	    super.viewDidLoad()
	    // Do any additional setup after loading the view.
	    
	    setupCells()
	    
	    self.tableView.delegate = self
	    self.tableView.dataSource = self
	    self.tableView.contentInset = UIEdgeInsetsMake(68, 0, 0, 0)
	}

	/**
	 *  Prepare cell for each object field that's a need to be filled.
	 */
	func setupCells {
	    self.clientCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier)
	    self.clientCell.label = "Client:"
	    self.clientCell.key = "clientNameC"
	    self.clientCell.value = self.payment.clientNameC
	    
	    self.amountCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier)
	    self.amountCell.label = "Amount:"
	    self.amountCell.key = "paymentAmountC"
	    self.amountCell.value = self.payment.paymentAmountC.stringValue
	    
	    self.jobCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier)
	    self.jobCell.label = "Job:"
	    self.jobCell.key = "jobNameC"
	    self.jobCell.value = self.payment.jobNameC
	    
	    self.noteCell = self.tableView dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier)
	    self.noteCell.label = "Notes:"
	    self.noteCell.key = "paymentNotesC"
	    self.noteCell.value = self.payment.paymentNotesC
	    
	    self.datasource = [self.clientCell, self.amountCell, self.jobCell, self.noteCell]
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
	    if let backBtn = self.navigationItem.leftBarButtonItem.customView as? UIButton {
	        backBtn.removeTarget(self, action: "popViewControllerAnimated", forControlEvents: UIControlEvent.TouchUpInside)
	        backBtn.addTarget:self, action: "saveAndReturn", forControlEvents: UIControlEvent.TouchUpInside)
	    }
	}

	/**
	 *  Called after back button was pressed. Validates the data in form, and displays the validation error if any of them is empty.
	 *  If everything is ok, data is saved and view controller is dismissed.
	 */
	func saveAndReturn() {
	    for var cell in self.datasource {
	        if cell.changesWereMade && cell.valueTextView.text == nil || [cell.valueTextView.text isKindOfClass:[NSNull class]] || [cell.valueTextView.text isEqualToString:@""])) {
	            [[[UIAlertView alloc] initWithTitle:@"Validation error"
	                                        message:[NSString stringWithFormat:@"%@ field cannot be empty", [cell.label stringByReplacingOccurrencesOfString:@":"
	                                                                                                                                              withString:@""]]
	                                       delegate:nil
	                              cancelButtonTitle:@"OK"
	                              otherButtonTitles:nil] show];
	            return;
	        }
	        
	        if cell.key == "paymentAmountC" {
	            self.payment.setValue(cell.valueTextView.text.floatValue, forKey: cell.key)
	        } else {
	            self.payment.setValue(cell.valueTextView.text, forKey: cell.key)
	        }
	    }
	    
	    NSError* error = nil;
	    [self.payment.managedObjectContext save:&error];
	    
	    if(error != nil) {
	        NSLog(@"%@", error);
	    } else {
	        [self.payment.managedObjectContext saveToPersistentStore:&error];
	        if(error != nil) {
	            NSLog(@"%@", error);
	        }
	    }
	    
	    if(error != nil) {
	        [[[UIAlertView alloc] initWithTitle:@"Error"
	                                    message:[NSString stringWithFormat:@"Error occured while saving data: %@", error.localizedDescription]
	                                   delegate:nil
	                          cancelButtonTitle:@"OK"
	                          otherButtonTitles:nil] show];
	    }
	    
	    [self.navigationController popViewControllerAnimated:YES];
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
	    if text == "\n" {
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
	    var cell = textView.superviewOfClass(UITableViewCell class)
	    self.tableView.scrollToRowAtIndexPath(self.tableView.indexPathForCell(cell), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
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