//
//  SEPaymentTableViewCell.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SESwipeableTableViewCell.h"

/**
 *  Custom table view cell for payments list screen
 */
@interface SEPaymentTableViewCell : SESwipeableTableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *paymentStatusImage;
@property (strong, nonatomic) IBOutlet UILabel *amountLabel;
@property (strong, nonatomic) IBOutlet UILabel *clientLabel;
@property (strong, nonatomic) IBOutlet UILabel *jobLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
