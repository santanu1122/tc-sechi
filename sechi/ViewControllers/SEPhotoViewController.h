//
//  SEPhotoViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"
#import "SEJobPhotoInfo.h"

/**
 *  View controller used for displaying single photo in gallery's UIPageViewcontroller
 */
@interface SEPhotoViewController : SEViewController<UIScrollViewDelegate>

/**
 *  NSManagedObject with information about the photo to show.
 */
@property (strong, nonatomic) SEJobPhotoInfo* jobPhotoInfo;

/**
 *  Scroll view that's used for displaying the photo
 */
@property (strong, nonatomic) UIScrollView* scrollView;

/**
 *  Image view that will display a photo
 */
@property (strong, nonatomic) UIImageView* imageView;

/**
 *  Initialize ViewController with information about photo to display.
 *
 *  @param jobPhotoInfo
 *
 *  @return initialized view controller or nil if failure
 */
- (id) initWithJobPhotoInfo: (SEJobPhotoInfo*) jobPhotoInfo;

@end

