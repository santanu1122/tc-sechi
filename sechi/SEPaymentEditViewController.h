//
//  SEPaymentEditViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"

@class SEPayment;

/**
 *  View controller used for displaying form that's used for editing payment object.
 */
@interface SEPaymentEditViewController : SEViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

/**
 *  Pointer for object that will be edited.
 */
@property (strong, nonatomic) SEPayment* payment;

@end
