//
//  SEConstants.m
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEConstants.h"

NSString *const SEUserDefaultsUserStatusKey = @"SEUserDefaultsUserStatusKey";

NSString *const SEPushMainMenuViewControllerSegue = @"SEPushMainMenuViewControllerSegue";
NSString *const SEPushJobAddViewControllerSegue = @"SEPushJobAddViewControllerSegue";
NSString *const SEPushJobsViewControllerSegue = @"SEPushJobsViewControllerSegue";
NSString *const SEPushJobClientInfoEditViewControllerSegue = @"SEPushJobClientInfoEditViewControllerSegue";
NSString *const SEPushPaymentAddViewControllerSegue = @"SEPushPaymentAddViewControllerSegue";
NSString *const SEPushModalProductCodeReaderViewControllerSegue = @"SEPushModalProductCodeReaderViewControllerSegue";

NSString *const SEJobTableViewCellIdentifier = @"SEJobTableViewCellIdentifier";
NSString *const SEJobClientInfoTableViewCellIdentifier = @"SEJobClientInfoTableViewCellIdentifier";
NSString *const SEJobAddressTableViewCellIdentifier = @"SEJobAddressTableViewCellIdentifier";
NSString *const SEJobNotesTableViewCellIdentifier = @"SEJobNotesTableViewCellIdentifier";
NSString *const SEJobPhotosTableViewCellIdentifier = @"SEJobPhotosTableViewCellIdentifier";
NSString *const SEJobHoursTableViewCellIdentifier = @"SEJobHoursTableViewCellIdentifier";

NSString *const SEClientTableViewCellIdentifier = @"SEClientTableViewCellIdentifier";
NSString *const SEClientInfoTableViewCellIdentifier = @"SEClientInfoTableViewCellIdentifier";
NSString *const SEClientAddressTableViewCellIdentifier = @"SEClientAddressTableViewCellIdentifier";

NSString *const SEProductTableViewCellIdentifier = @"SEProductTableViewCellIdentifier";

NSString *const SEPaymentTableViewCellIdentifier = @"SEPaymentTableViewCellIdentifier";
NSString *const SEPaymentInfoTableViewCellIdentifier = @"SEPaymentInfoTableViewCellIdentifier";

NSString *const SETextFieldTableViewCellIdentifier = @"SETextFieldTableViewCellIdentifier";
NSString *const SEJobPhotoCollectionViewCellIdentifier = @"SEJobPhotoCollectionViewCellIdentifier";



@implementation SEConstants


// consts
+ (UIFont*) helveticaLight8pt {
    return [UIFont fontWithName:@"Helvetica-Light" size:16.0f];
}

+ (UIFont*) helveticaLight11pt {
    return [UIFont fontWithName:@"Helvetica-Light" size:22.0f];
}


// ui
+ (UIFont*) textFieldFont {
    return [self helveticaLight8pt];
}

+ (UIFont*) navigationBarFont {
    return [self helveticaLight11pt];
}


@end
