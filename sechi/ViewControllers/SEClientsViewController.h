//
//  SEClientsViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"
#import "SESwipeableTableViewCell.h"

/**
 *  View controller used for displaying list of client objects.
 */
@interface SEClientsViewController : SEViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UIAlertViewDelegate,SESwipeableTableViewCellDelegate,UIGestureRecognizerDelegate>


@end
