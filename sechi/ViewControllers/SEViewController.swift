//
//  SEViewController.swift
//  sechi
//
//  Created by TCSASSEMBLER on 2014-06-13.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

/**
 *  Base view controller with methods shared for inheriting view controllers.
 */
class SEViewController : UIViewController {

    /**
     *  Boolean indicating if keyboard is visible
     */
    var keyboardShown: Bool

    /**
     *  Setups keyborad show/hide notifications observer and application status bar style.
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotificationsObserver()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    /**
     *  Remobes keyboard show/hide notifications observer.
     */
    override func viewWillDisappear(animated: Bool) {
        self.removeKeyboardNotificationsObserver()
    }

    /**
    *  Shows back button on navigation bar
    */
    func setupNavigationBarBackButton() {
        var backButton = UIButton(type: UI.Custom)
        backButton.frame = CGRectMake(0.0, 00.0, 11.0, 18.0)
        backButton.setBackgroundImage(UIImage.imageNamed("btn_back"), forState: .Normal)
        backButton.addTarget(self, action: "popViewControllerAnimated", forControlEvents: .TouchUpInside)
        var backButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backButtonItem
    }

    /**
     *  Shows add button on navigation bar
     *
     *  @return UIButton used as add button
     */
    func setupNavigationBarAddButton() -> UIButton {
        var addButton = UIButton(type: .Custom)
        addButton.frame = CGRectMake(0.0, 00.0, 17.0, 17.0)
        addButton.setBackgroundImage(UIImage.imageNamed("btn_add"), forState: .Normal)
        var addButtonItem = UIBarButtonItem(customView: addButton)
        self.navigationItem.rightBarButtonItem = addButtonItem
        return addButton
    }

    /**
     *  Shows save button on navigation bar
     *
     *  @return UIBarButtonItem used as save button
     */
    func setupNavigationBarSaveButton() -> UIBarButtonItem {
        var saveButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: nil, action: nil)
        saveButtonItem.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = saveButtonItem
        UINavigationBar.appearance.setTintColor(UIColor.whiteColor)
        return saveButtonItem
    }

    /**
    *  Pops view controller animated
    */
    func popViewControllerAnimated() {
        self.navigationController.popViewControllerAnimated(true)
    }

    //#pragma mark - Keyboard notifications
    /**
     *  Adds self as a observer for keyboard notifications
     */
    func addKeyboardNotificationsObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    /**
     *  Removes self as a observer for keyboard notifications
     */
    func removeKeyboardNotificationsObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    /**
     *  Returns main scroll view for the current view controller - used for calculating keyboard overlapping
     *
     *  @return bottommost UIScrollView object
     */
    func getMainScrollView() -> UIScrollView? {
        if self.respondsToSelector("tableView") && self.valueForKeyPath("tableView.superview") is UIScrollView {
            return self.valueForKeyPath("tableView.superview") as UIScrollView
        }
    
        if self.respondsToSelector("tableView") && self.valueForKey("tableView") is UIScrollView {
            return self.valueForKeyPath("tableView") as? UIScrollView
        }

        if self.respondsToSelector("scrollView") && self.valueForKey("scrollView") is UIScrollView {
            return self.valueForKey("scrollView") as? UIScrollView
        }

        return nil
}

    /**
     *  Method called before keyboard is shown. Adds padding to main scroll view.
     *
     *  @param aNotification
     */
    func keyboardWillShow(aNotification: NSNotification) {
        if keyboardShown {
            return
        }
    
        var scrollView = self.getMainScrollView()
    
        var userInfo = aNotification.userInfo()
        var aValue = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey)
        var keyboardRect = scrollView.superview.convertRect(aValue.CGRectValue, fromView: nil)
    
        var newInsets = UIEdgeInsetsMake(74, 0, keyboardRect.size.height, 0)
        scrollView.contentInset = newInsets
    }

    /**
     *  Method called before keyboard is hidden. Removes padding from main scroll view.
     *
     *  @param aNotification
     */
    func keyboardWillHide(aNotification: NSNotification) {
        var scrollView = self.getMainScrollView()
        scrollView.contentInset = UIEdgeInsetsMake(74, 0, 0, 0)
    }

}
