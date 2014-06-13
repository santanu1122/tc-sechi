//
//  SEGalleryViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"

/**
 *  View controller used for displaying a gallery of photos
 */
@interface SEGalleryViewController : SEViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

/**
 *  Index of a first photo that should be shown.
 */
@property (nonatomic) NSInteger startIndex;

/**
 *  Array of photos that will be presented.
 */
@property (strong, nonatomic) NSArray* mediaFiles;

/**
 *  UIPageViewController used for displaying gallery
 */
@property (strong, nonatomic) UIPageViewController* pageViewController;

/**
 *  Initializer that setups the view controller for displaying the first item.
 *
 *  @param mediaFiles array of photos to display
 *
 *  @return initialized view controller on success, nil on failure
 */
- (id) initWithMediaFilesArray: (NSArray*) mediaFiles;

/**
 *  Initializer that setups the view controller for displaying the item at index param as first.
 *
 *  @param mediaFiles mediaFiles array of photos to display
 *  @param index      index of photo that will be displayed as a first
 *
 *  @return initialized view controller on success, nil on failure
 */
- (id) initWithMediaFilesArray: (NSArray*) mediaFiles atIndex: (NSUInteger) index;

@end
