//
//  SEJobNotesEditViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"

@class SEJob;

/**
 *  View controller used to display form for editing notes of the job object.
 */
@interface SEJobNotesEditViewController : SEViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

/**
 *  SEJob object that it's notes will be edited.
 */
@property (strong, nonatomic) SEJob* job;


@end
