//
//  SEViewController.h
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Base view controller with methods shared for inheriting view controllers.
 */
@interface SEViewController : UIViewController

/**
 *  Shows back button on navigation bar.
 */
- (void) setupNavigationBarBackButton;

/**
 *  Shows add button on navigation bar
 *
 *  @return UIButton object displayed in navigation bar.
 */
- (UIButton*) setupNavigationBarAddButton;

/**
 *  Shows save button on navigation bar.
 *
 *  @return UIBarButtonItem displayed in navigation bar.
 */
- (UIBarButtonItem*) setupNavigationBarSaveButton;

@end
