//
//  SEPaymentInfoTableViewCell.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SESwipeableTableViewCell.h"

/**
 *  Custom table view cell for single payment view screen
 */
@interface SEPaymentInfoTableViewCell : SESwipeableTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *amountLabel;
@property (strong, nonatomic) IBOutlet UILabel *clientLabel;
@property (strong, nonatomic) IBOutlet UILabel *jobLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *notesLabel;
@property (strong, nonatomic) IBOutlet UIButton *completeButton;

/**
 *  Calculates height needed to properly display cell based on current content
 *
 *  @return height of the cell
 */
- (CGFloat) cellHeightNeeded;

@end
