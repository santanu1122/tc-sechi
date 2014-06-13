//
//  UIView+Hierarchy.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Hierarchy)

/**
 *  Methods loops trough superviews of a view on which was invoked and returns a superview that's kind of class requiredClass.
 *
 *  @param requiredClass Class that has to represent needle object
 *
 *  @return UIView superview of requiredClass class or nil if not found
 */
- (UIView*) superviewOfClass: (Class) requiredClass;

@end
