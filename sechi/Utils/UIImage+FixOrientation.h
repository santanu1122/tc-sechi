//
//  UIImage+FixOrientation.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FixOrientation)

/**
 *  Method called on image tooked from camera fixes orientation issues that occures on photos taken with iDevice.
 *
 *  @return UIImage with fixed orientation.
 */
- (UIImage *)fixOrientation;
    
@end
