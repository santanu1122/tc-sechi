//
//  SEClientViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"
#import "SESwipeableTableViewCell.h"

@class SEClient;

/**
 *  View controller used for displaying single client view.
 */
@interface SEClientViewController : SEViewController<UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate,SESwipeableTableViewCellDelegate,UIGestureRecognizerDelegate>

/**
 *  SEClient object that will be displayed.
 */
@property (strong, nonatomic) SEClient* client;

@end
