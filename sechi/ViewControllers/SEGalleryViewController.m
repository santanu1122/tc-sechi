//
//  SEGalleryViewController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEGalleryViewController.h"
#import "SEPhotoViewController.h"

@interface SEGalleryViewController ()

@end

@implementation SEGalleryViewController

@synthesize mediaFiles = _mediaFiles;
@synthesize pageViewController = _pageViewController;
@synthesize startIndex = _startIndex;

- (id) initWithMediaFilesArray: (NSArray*) mediaFiles atIndex: (NSUInteger) index {
    
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        _mediaFiles = mediaFiles;
        _startIndex = index;
    }
    return self;
}

- (id) initWithMediaFilesArray: (NSArray*) mediaFiles {
    return [self initWithMediaFilesArray:mediaFiles atIndex:0];
}

/**
 *  Setup UIPageViewController, show it's view on the screen. Prepare NSLayoutConstraints.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    background.contentMode = UIViewContentModeScaleAspectFill;
    background.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:background];
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    [self addChildViewController:_pageViewController];
    
    [self.view addSubview:_pageViewController.view];
    
    _pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.title = @"SCHEDULE";
    
    UIImageView* lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_schedule"]];
    lineView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:lineView];
    
    NSDictionary* views = @{
                            @"pvc": _pageViewController.view,
                            @"line": lineView,
                            @"bg": background
                            };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bg]|"
                                                                      options:0
                                                                      metrics:0
                                                                        views:views]];

    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bg]|"
                                                                      options:0
                                                                      metrics:0
                                                                        views:views]];

    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pvc]|"
                                                                      options:0
                                                                      metrics:0
                                                                        views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[line]|"
                                                                      options:0
                                                                      metrics:0
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(64)-[line(==10)][pvc]|"
                                                                      options:0
                                                                      metrics:0
                                                                        views:views]];
    
    [self.pageViewController didMoveToParentViewController:self];
}

/**
 *  Show desired photo as a first item before view will appear
 *
 *  @param animated
 */
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self.navigationController isNavigationBarHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
    [self setupNavigationBarBackButton];
    
    if(_startIndex >= self.mediaFiles.count) {
        _startIndex = 0;
    }
    
    [_pageViewController setViewControllers:@[[self viewControllerAtIndex:_startIndex]]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
}

- (BOOL) shouldAutomaticallyForwardRotationMethods {
    return YES;
}

- (BOOL) shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}

/**
 *  Inform view controllers from UIPageViewController that the device will change orientation
 *
 *  @param toInterfaceOrientation
 *  @param duration
 */
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    for (UIViewController* vc in _pageViewController.viewControllers) {
        [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

/**
 *  Update UI after device change orientation
 *
 *  @param fromInterfaceOrientation
 */
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self.view setNeedsLayout];
    [_pageViewController.view setNeedsLayout];
    
    for (UIViewController* vc in _pageViewController.viewControllers) {
        [vc didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        
        [vc.view setNeedsUpdateConstraints];
        [vc.view setNeedsLayout];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSInteger index = [self.mediaFiles indexOfObject:((SEPhotoViewController*)_pageViewController.viewControllers.lastObject).jobPhotoInfo];
        
        [_pageViewController setViewControllers:@[[self viewControllerAtIndex:index]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    });
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger currentIndex = [_mediaFiles indexOfObject:((SEPhotoViewController*)viewController).jobPhotoInfo];
    NSInteger nextIndex = currentIndex+1;
    
    return [self viewControllerAtIndex:nextIndex];
}

- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger currentIndex = [_mediaFiles indexOfObject:((SEPhotoViewController*)viewController).jobPhotoInfo];
    NSInteger nextIndex = currentIndex-1;
    
    return [self viewControllerAtIndex:nextIndex];
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    
    NSArray *allPageControllers = pageViewController.viewControllers;
    
    if (allPageControllers != nil) {
        [self.pageViewController setViewControllers:allPageControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    else {
        UIViewController *defaultViewController = [[UIViewController alloc] init];
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:defaultViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    
    return UIPageViewControllerSpineLocationMin;
}

/**
 *  Method returns view controller with photo to display in UIPageViewController
 *
 *  @param index index of photo that should be used
 *
 *  @return initialized view controller or nil on failure
 */
- (UIViewController*) viewControllerAtIndex: (NSInteger) index {
    
    if(index >= 0 && index < _mediaFiles.count) {
        return [[SEPhotoViewController alloc] initWithJobPhotoInfo:[self.mediaFiles objectAtIndex:index]];
    }
    return nil;
}

@end
