//
//  UIView+Hierarchy.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "UIView+Hierarchy.h"

@implementation UIView (Hierarchy)

- (UIView*) superviewOfClass: (Class) requiredClass {
    
    if([self.superview isKindOfClass:requiredClass]) {
        return self.superview;
    }
    
    return [self.superview superviewOfClass:requiredClass];
}

@end
