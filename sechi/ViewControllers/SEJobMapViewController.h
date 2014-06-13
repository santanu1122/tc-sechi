//
//  SEJobMapViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SEViewController.h"

@class SEJob;

/**
 *  View controller used for displaying a map with marked job address and option to show directions to it.
 */
@interface SEJobMapViewController : SEViewController<MKMapViewDelegate,UITextViewDelegate>

/**
 *  SEJob object, view controller will show an address from it to display.
 */
@property (strong, nonatomic) SEJob* job;

@end
