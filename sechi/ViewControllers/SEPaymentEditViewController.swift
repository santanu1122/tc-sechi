//
//  SEPaymentEditViewController.swift
//  sechi
//
//  Created by TCSASSEMBLER on 2014-06-13.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

/**
 *  View controller used for displaying form that's used for editing payment object.
 */
@objc
class SEPaymentEditViewController: SEViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    /**
     *  Pointer for object that will be edited.
     */
    var payment: SEPayment!

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
    func setupCells() {
        self.clientCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier) as SETextFieldTableViewCell
        self.clientCell.label = "Client:"
        self.clientCell.key = "clientNameC"
        self.clientCell.value = self.payment.clientNameC
        
        self.amountCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier) as SETextFieldTableViewCell
        self.amountCell.label = "Amount:"
        self.amountCell.key = "paymentAmountC"
        self.amountCell.value = "\(self.payment.paymentAmountC)"
        
        self.jobCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier) as SETextFieldTableViewCell
        self.jobCell.label = "Job:"
        self.jobCell.key = "jobNameC"
        self.jobCell.value = self.payment.jobNameC
        
        self.noteCell = self.tableView.dequeueReusableCellWithIdentifier(SETextFieldTableViewCellIdentifier) as SETextFieldTableViewCell
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
            backBtn.removeTarget(self, action: "popViewControllerAnimated", forControlEvents: .TouchUpInside)
            backBtn.addTarget(self, action: "saveAndReturn", forControlEvents: .TouchUpInside)
        }
    }

    /**
     *  Called after back button was pressed. Validates the data in form, and displays the validation error if any of them is empty.
     *  If everything is ok, data is saved and view controller is dismissed.
     */
    func saveAndReturn() {
        for cell in self.datasource {
            if cell.changesWereMade && cell.valueTextView?.text == "" {
                var fieldName = cell.label!.stringByReplacingOccurrencesOfString(":", withString: "")
                let alertController = UIAlertController(title: "Validation error", message: "\(fieldName) field cannot be empty", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
        }
        self.payment.clientNameC = self.clientCell.valueTextView.text
        self.payment.jobNameC = self.jobCell.valueTextView.text
        self.payment.paymentNotesC = self.noteCell.valueTextView.text
        var nf = NSNumberFormatter()
        nf.numberStyle = .DecimalStyle
        self.payment.paymentAmountC = nf.numberFromString(self.amountCell.valueTextView.text)
        
        var error: NSError? = nil
        self.payment.managedObjectContext.save(&error)
        
        if error {
            NSLog("%@", error!)
        } else {
            self.payment.managedObjectContext.saveToPersistentStore(&error)
            if error {
                NSLog("%@", error!)
            }
        }
        
        if error {
            let alertController = UIAlertController(title: "Error", message: "Error occured while saving data: " + error!.localizedDescription, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        self.navigationController.popViewControllerAnimated(true)
    }

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
        var cell = textView.superviewOfClass(UITableViewCell) as UITableViewCell
        self.tableView.scrollToRowAtIndexPath(self.tableView.indexPathForCell(cell), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }

    /**
     *  Recalculate height of the cell based on the text view content after it changes.
     *
     *  @param textView UITextView that changed the content.
     */
    func textViewDidChange(textView: UITextView) {
        var cell = textView.superviewOfClass(SETextFieldTableViewCell) as SETextFieldTableViewCell
        var heightNeeded = cell.cellHeightForText(cell.valueTextView.text)
        if cell.frame.size.height != heightNeeded {
            cell.height = heightNeeded
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

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
