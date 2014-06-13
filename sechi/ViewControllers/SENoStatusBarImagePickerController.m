//
//  SENoStatusBarImagePickerController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SENoStatusBarImagePickerController.h"

@interface SENoStatusBarImagePickerController ()

@end

@implementation SENoStatusBarImagePickerController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self prefersStatusBarHidden];
    
    if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

@end
