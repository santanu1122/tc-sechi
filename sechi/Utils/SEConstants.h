//
//  SEConstants.h
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define HAS_4_INCH_SCREEN  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

FOUNDATION_EXPORT NSString *const SEUserDefaultsUserStatusKey;

FOUNDATION_EXPORT NSString *const SEPushMainMenuViewControllerSegue;
FOUNDATION_EXPORT NSString *const SEPushJobsViewControllerSegue;
FOUNDATION_EXPORT NSString *const SEPushJobAddViewControllerSegue;
FOUNDATION_EXPORT NSString *const SEPushJobClientInfoEditViewControllerSegue;
FOUNDATION_EXPORT NSString *const SEPushPaymentAddViewControllerSegue;
FOUNDATION_EXPORT NSString *const SEPushModalProductCodeReaderViewControllerSegue;

FOUNDATION_EXPORT NSString *const SEJobTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const SEJobClientInfoTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const SEJobAddressTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const SEJobNotesTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const SEJobPhotosTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const SEJobHoursTableViewCellIdentifier;

FOUNDATION_EXPORT NSString *const SEClientTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const SEClientInfoTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const SEClientAddressTableViewCellIdentifier;

FOUNDATION_EXPORT NSString *const SEProductTableViewCellIdentifier;

FOUNDATION_EXPORT NSString *const SEPaymentTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const SEPaymentInfoTableViewCellIdentifier;

FOUNDATION_EXPORT NSString *const SETextFieldTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const SEJobPhotoCollectionViewCellIdentifier;



@interface SEConstants : NSObject

// consts
+ (UIFont*) helveticaLight8pt;
+ (UIFont*) helveticaLight11pt;

// ui
+ (UIFont*) textFieldFont;
+ (UIFont*) navigationBarFont;


@end
