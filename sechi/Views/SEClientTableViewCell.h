//
//  SEClientTableViewCell.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SESwipeableTableViewCell.h"

/**
 *  Custom table view cell for clients list screen
 */
@interface SEClientTableViewCell : SESwipeableTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *clientNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;

@property (strong, nonatomic) IBOutlet UIView *deleteButtonBg;
@property (strong, nonatomic) IBOutlet UIView *callButtonBg;


@end
