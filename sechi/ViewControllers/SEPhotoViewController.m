//
//  SEPhotoViewController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEPhotoViewController.h"

@interface SEPhotoViewController ()

@end

@implementation SEPhotoViewController

@synthesize jobPhotoInfo = _jobPhotoInfo;
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;

- (id)initWithJobPhotoInfo:(SEJobPhotoInfo *)jobPhotoInfo {
    
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        _jobPhotoInfo = jobPhotoInfo;
    }
    return self;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.view setNeedsUpdateConstraints];
}

/**
 *  Setup all view controller subviews.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1.0f;
    _scrollView.maximumZoomScale = 4.0f;
    _scrollView.bounces = NO;
    _scrollView.scrollEnabled = YES;
    [self.view addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    _imageView.multipleTouchEnabled = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_scrollView setContentOffset:CGPointZero];
    
    self.imageView.image = [UIImage imageWithContentsOfFile:self.jobPhotoInfo.filePath];
    
    [self.view setNeedsLayout];
}

/**
 *  Update constraints of views inside view controller.
 */
- (void) updateViewConstraints {
    [super updateViewConstraints];
    
    [self.view removeConstraints:self.view.constraints];
    
    if(_scrollView && _imageView) {
        NSDictionary *viewsDictionary = @{ @"scrollView": _scrollView, @"imageView": _imageView };
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|[scrollView]|"
                                   options:0
                                   metrics:0
                                   views:viewsDictionary]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|[scrollView]|"
                                   options:0
                                   metrics:0
                                   views:viewsDictionary]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|[imageView(width)]"
                                   options:0
                                   metrics:@{@"width": @(self.view.frame.size.width)}
                                   views:viewsDictionary]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|[imageView(height)]"
                                   options:0
                                   metrics:@{@"height": @(self.view.frame.size.height)}
                                   views:viewsDictionary]];
    }
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    
}

@end
