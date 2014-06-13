//
//  SEClientAddressTableViewCell.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SESwipeableTableViewCell.h"

@interface SEClientAddressTableViewCell : SESwipeableTableViewCell

@property (strong, nonatomic) IBOutlet UITextView *addressLabel;
@property (strong, nonatomic) IBOutlet UIButton *mapButton;

/**
 *  Calculates height needed to properly display cell based on current content
 *
 *  @return height of the cell
 */
- (CGFloat) cellHeightNeeded;

@end
