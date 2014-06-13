//
//  UIAlertView+CLErrorMessages.h
//  sechi
//
//  Created by karolszafranski on 13.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (CLErrorMessages)

/**
 *  Method is returning user friendly NSString communicates for specific errors.
 *
 *  @param error error for which i'm looking a message.
 *
 *  @return message that is user friendly with problem description for user.
 */
+ (NSString*) messageForCLError: (NSError*) error;

@end
