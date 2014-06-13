//
//  SEJobsViewController.h
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"
#import "SESwipeableTableViewCell.h"

/**
 *  View controller used for displaying list of job objects. (Schedule list)
 */
@interface SEJobsViewController : SEViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UIAlertViewDelegate,SESwipeableTableViewCellDelegate,UIGestureRecognizerDelegate>

@end
