//
//  SERestClient.h
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Singleton for performing REST requests
 */
@interface SERestClient : NSObject<UIAlertViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/**
 *  Returning singleton object
 *
 *  @return singleton object
 */
+ (SERestClient*) instance;

/**
 *  update local jobs table with data from server
 */
- (void) refreshJobsList;

/**
 *  update local clients table with data from server
 */
- (void) refreshClientsList;

/**
 *  update local payments table with data from server
 */
- (void) refreshPaymentsList;

/**
 *  update local parts table with data from server
 */
- (void) refreshPartsList;

/**
 *  update all local tables with data from server
 */
- (void) performDataSync;

@end
