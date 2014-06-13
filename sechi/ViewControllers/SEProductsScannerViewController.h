//
//  SEProductsScannerViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "SEViewController.h"

@class SEProductsScannerViewController;
/**
 *  Protocol used by SEProductsScannerViewController to inform it's delegate about code that was read or canceling reading process.
 */
@protocol SEProductsScannerViewControllerDelegate <NSObject>

/**
 *  Method called after reading a bar code
 *
 *  @param productsScannerViewController SEProductsScannerViewController that read the code
 *  @param string                        string with decoded text of the barcode
 */
- (void) productsScannerViewController: (SEProductsScannerViewController*) productsScannerViewController didReadString: (NSString*) string;

/**
 *  Method called if SEProducstsScannerViewController want to be dismissed
 *
 *  @param productsScannerViewController SEProductsScannerViewController object that want's to be dismissed.
 */
- (void) productsScannerViewControllerDidCancelReading: (SEProductsScannerViewController*) productsScannerViewController;

@end

/**
 *  View controller used for displaying a code scanner used in SEProductsListViewController
 */
@interface SEProductsScannerViewController : SEViewController<AVCaptureMetadataOutputObjectsDelegate>

/**
 *  Delegate of the view controller
 */
@property (weak, nonatomic) id<SEProductsScannerViewControllerDelegate> delegate;

@end
