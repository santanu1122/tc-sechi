//
//  SEPaymentViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"

@class SEPayment;

/**
 *  View controller used for displaying single payment view.
 */
@interface SEPaymentViewController : SEViewController<UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) SEPayment* payment;

@end
