//
//  SESwipeableTableViewCell.h
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SESwipeableTableViewCell;
@protocol SESwipeableTableViewCellDelegate <NSObject>

/**
 *  Called when UIPanGestureRecognizer used for swipe gesture emits UIGestureRecognizerStateBegin to it's delegate.
 *
 *  @param cell cell which started moving content
 */
- (void) swipeableCellWillStartMovingContent: (SESwipeableTableViewCell*) cell;

/**
 *  Called after topmost cell view is moved to the left to display bottom view (ie. delete button);
 *
 *  @param cell cell which did move it's top view
 */
- (void) cellDidOpen: (SESwipeableTableViewCell*) cell;

/**
 *  Called after topmost cell view is moved to the right to hide bottom view (ie. delete button);
 *
 *  @param cell cell which did move it's top view
 */
- (void) cellDidClose: (SESwipeableTableViewCell*) cell;

@end

@interface SESwipeableTableViewCell : UITableViewCell

/**
 *  Delegate, this object will be notified about cell swipe actions.
 */
@property (weak, nonatomic) id<SESwipeableTableViewCellDelegate> delegate;

/**
 *  Propert that enables or disables swipe gesture
 */
@property (nonatomic) BOOL swipeEnabled;

/**
 *  Width of the cell bottom view (ie. delete button), top view (content) will be moved left on swipe gesture for this value.
 */
@property (nonatomic) CGFloat rightBottomCellViewWidth;

/**
 *  Bottom view of the cell (ie. delete button).
 */
@property (strong, nonatomic) IBOutlet UIView* bottomCellView;

/**
 *  Top view of the cell (content that will be swiped).
 */
@property (strong, nonatomic) IBOutlet UIView* topCellView;

/**
 *  Left constraint of the topCellView
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topCellViewLeftConstraint;

/**
 *  Right constraint of the topCellView
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topCellViewRightConstraint;

/**
 *  Width constraint of the bottomCellView
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomCellViewWidthConstraint;

/**
 *  Move topCellView left (open)
 *
 *  @param animated BOOL should it be animated
 */
- (void) openCellAnimated: (BOOL) animated;

/**
 *  Move topCellView right (close)
 *
 *  @param animated BOOL should it be animated
 */
- (void) closeCellAnimated: (BOOL) animated;

@end
