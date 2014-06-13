//
//  SEClientInfoTableViewCell.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SESwipeableTableViewCell.h"

/**
 *  Custom table view cell for single client view screen
 */
@interface SEClientInfoTableViewCell : SESwipeableTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *clientLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;

@property (strong, nonatomic) IBOutlet UIButton *callButton;

/**
 *  Calculates height needed to properly display cell based on current content
 *
 *  @return height of the cell
 */
- (CGFloat) cellHeightNeeded;

@end
