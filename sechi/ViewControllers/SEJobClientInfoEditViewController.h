//
//  SEJobEditViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"

@class SEJob;

/**
 *  View controller used to display client info from the job object.
 */
@interface SEJobClientInfoEditViewController : SEViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

/**
 *  SEJob object that has client info.
 */
@property (strong, nonatomic) SEJob* job;

@end
