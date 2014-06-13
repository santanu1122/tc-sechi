//
//  SEJobHoursTableViewCell.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SESwipeableTableViewCell.h"

/**
 *  Custom table view cell for single schedule view (specifically hours part)
 */
@interface SEJobHoursTableViewCell : SESwipeableTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *completeButton;

@end
