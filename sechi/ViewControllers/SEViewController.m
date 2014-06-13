//
//  SEViewController.m
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"

@interface SEViewController ()

@end

@implementation SEViewController

/**
 *  Boolean indicating if keyboard is visible
 */
BOOL keyboardShown;

/**
 *  Setups keyborad show/hide notifications observer and application status bar style.
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addKeyboardNotificationsObserver];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

/**
 *  Remobes keyboard show/hide notifications observer.
 */
- (void) viewWillDisappear:(BOOL)animated {
    [self removeKeyboardNotificationsObserver];
}

/**
 *  Shows back button on navigation bar
 */
- (void) setupNavigationBarBackButton {
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 00.0, 11.0, 18.0);
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(popViewControllerAnimated) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

/**
 *  Shows add button on navigation bar
 *
 *  @return UIButton used as add button
 */
- (UIButton*) setupNavigationBarAddButton {
    UIButton* addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(0.0, 00.0, 17.0, 17.0);
    [addButton setBackgroundImage:[UIImage imageNamed:@"btn_add"] forState:UIControlStateNormal];
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    return addButton;
}

/**
 *  Shows save button on navigation bar
 *
 *  @return UIBarButtonItem used as save button
 */
- (UIBarButtonItem*) setupNavigationBarSaveButton {
    UIBarButtonItem* saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                   target:nil
                                                                                   action:nil];
    saveButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:saveButtonItem];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    return saveButtonItem;
}

/**
 *  Pops view controller animated
 */
- (void) popViewControllerAnimated {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Keyboard notifications
/**
 *  Adds self as a observer for keyboard notifications
 */
- (void) addKeyboardNotificationsObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

/**
 *  Removes self as a observer for keyboard notifications
 */
- (void) removeKeyboardNotificationsObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

/**
 *  Returns main scroll view for the current view controller - used for calculating keyboard overlapping
 *
 *  @return bottommost UIScrollView object
 */
- (UIScrollView*) getMainScrollView {
    
    if([self respondsToSelector:@selector(tableView)] && [[self valueForKeyPath:@"tableView.superview"] isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)[self valueForKeyPath:@"tableView.superview"];
    }
    
    if ([self respondsToSelector:@selector(tableView)] && [[self valueForKey:@"tableView"] isKindOfClass:[UIScrollView class]]) {
        return [self valueForKeyPath:@"tableView"];
    }
    
    if([self respondsToSelector:@selector(scrollView)] && [[self valueForKey:@"scrollView"] isKindOfClass:[UIScrollView class]]) {
        return [self valueForKey:@"scrollView"];
    }
    
    return nil;
}

/**
 *  Method called before keyboard is shown. Adds padding to main scroll view.
 *
 *  @param aNotification
 */
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    if(keyboardShown)
        return;
    
    UIScrollView *scrollView = [self getMainScrollView];
    
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [scrollView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    UIEdgeInsets newInsets = UIEdgeInsetsMake(74, 0, keyboardRect.size.height, 0);
    scrollView.contentInset = newInsets;
}

/**
 *  Method called before keyboard is hidden. Removes padding from main scroll view.
 *
 *  @param aNotification
 */
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    UIScrollView *scrollView = [self getMainScrollView];
    scrollView.contentInset = UIEdgeInsetsMake(74, 0, 0, 0);
}

@end
