//
//  SEClientMapViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SEViewController.h"

@class SEClient;

/**
 *  View controller used for displaying a map with marked client address and option to show directions to it.
 */
@interface SEClientMapViewController : SEViewController<MKMapViewDelegate,UITextViewDelegate>

/**
 *  SEClient object, view controller will show an address from it to display.
 */
@property (strong, nonatomic) SEClient* client;

@end
