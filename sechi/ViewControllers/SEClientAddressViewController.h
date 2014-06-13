//
//  SEClientAddressViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"

@class SEClient;

/**
 *  View controller used for displaying form for editing value of the client address.
 */
@interface SEClientAddressViewController : SEViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

/**
 *  SEClient object that will be edited.
 */
@property (strong, nonatomic) SEClient* client;

@end
