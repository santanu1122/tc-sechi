//
//  SEJobAddressEditViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"

@class SEJob;

/**
 *  View controller used to display form for editing address info of the job object.
 */
@interface SEJobAddressEditViewController : SEViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

/**
 *  SEJob object that address info will be edited.
 */
@property (strong, nonatomic) SEJob* job;

@end
