//
//  SEJobViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"
#import "SESwipeableTableViewCell.h"

@class SEJob;

/**
 *  View controller used to display single job object.
 */
@interface SEJobViewController : SEViewController<UITableViewDataSource,UITableViewDelegate, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate,SESwipeableTableViewCellDelegate,UIGestureRecognizerDelegate>


/**
 *  SEJob object to display.
 */
@property (strong, nonatomic) SEJob* job;

@end
