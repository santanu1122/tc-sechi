//
//  SESwipeableTableViewCell.m
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SESwipeableTableViewCell.h"
#import "UIView+Hierarchy.h"

@interface SESwipeableTableViewCell()

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;

@end

@implementation SESwipeableTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self setupView];
}

/**
 *  Setup cell apperance, pan gesture recognizer, and rewrite width of bottom view to rightBottomCellViewWidth property
 */
- (void) setupView {
    self.swipeEnabled = YES;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.editingAccessoryType = UITableViewCellEditingStyleNone;
    
    self.rightBottomCellViewWidth = self.bottomCellViewWidthConstraint.constant;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(panThisCell:)];
    self.panGestureRecognizer.delegate = self;
    [self.topCellView addGestureRecognizer:self.panGestureRecognizer];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - actions
/**
 *  Move topCellView (content) depending on gesture direction and current position of the view.
 *  This method is fired by panGestureRecognizer attached to topCellView
 *
 *  @param panGestureRecognizer UIPanGestureRecognizer object that send a message
 */
- (void) panThisCell: (UIPanGestureRecognizer*) panGestureRecognizer {
    
    if(!self.swipeEnabled) {
        return;
    }
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [panGestureRecognizer translationInView:self.topCellView];
            self.startingRightLayoutConstraintConstant = self.topCellViewRightConstraint.constant;
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [panGestureRecognizer translationInView:self.topCellView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {
                panningLeft = YES;
            }
            
            if (self.startingRightLayoutConstraintConstant == 0) {
                //The cell was closed and is now opening
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, 0);
                    if (constant == 0) {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else {
                        self.topCellViewRightConstraint.constant = constant;
                    }
                } else {

                    if([self.delegate respondsToSelector:@selector(swipeableCellWillStartMovingContent:)]) {
                        [self.delegate swipeableCellWillStartMovingContent:self];
                    }
                    
                    CGFloat constant = MIN(-deltaX, self.rightBottomCellViewWidth);
                    if (constant == self.rightBottomCellViewWidth) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else {
                        self.topCellViewRightConstraint.constant = constant;
                    }
                }
            }
            else {
                //The cell was at least partially open.
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX;
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0);
                    if (constant == 0) {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else {
                        self.topCellViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(adjustment, self.rightBottomCellViewWidth);
                    if (constant == self.rightBottomCellViewWidth) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else {
                        self.topCellViewRightConstraint.constant = constant;
                    }
                }
            }
            
            self.topCellViewLeftConstraint.constant = -self.topCellViewRightConstraint.constant;
        }
            break;
        case UIGestureRecognizerStateEnded:
            if (self.startingRightLayoutConstraintConstant == 0) { //1
                //Cell was opening
                CGFloat halfOfButtonOne = self.rightBottomCellViewWidth / 2; //2
                if (self.topCellViewRightConstraint.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            } else {
                //Cell was closing
                CGFloat buttonOnePlusHalfOfButton2 = self.rightBottomCellViewWidth * 0.75; //4
                if (self.topCellViewRightConstraint.constant >= buttonOnePlusHalfOfButton2) { //5
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
            if (self.startingRightLayoutConstraintConstant == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            break;
        default:
            break;
    }
}

#pragma mark - public tasks
- (void) openCellAnimated: (BOOL) animated {
    [self setConstraintsToShowAllButtons:animated notifyDelegateDidOpen:NO];
}

- (void) closeCellAnimated: (BOOL) animated {
    [self resetConstraintContstantsToZero:animated notifyDelegateDidClose:NO];
}

#pragma mark - tasks
/**
 *  Performs constraint transformation needed to "close the cell" and hide bottomCellView
 *
 *  @param animated       should the transfrom be animated
 *  @param notifyDelegate should delegate be notified about this transformation
 */
- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate
{
    if(notifyDelegate) {
        [self.delegate cellDidClose:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == 0 &&
        self.topCellViewRightConstraint.constant == 0) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.topCellViewRightConstraint.constant = 0;
        self.topCellViewLeftConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.topCellViewRightConstraint.constant;
        }];
    }];
}

/**
 *  Performs constraint transformation needed to "open the cell" and show bottomCellView
 *
 *  @param animated       should the transfrom be animated
 *  @param notifyDelegate should delegate be notified about this transformation
 */
- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
	if(notifyDelegate) {
        [self.delegate cellDidOpen:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == self.rightBottomCellViewWidth &&
        self.topCellViewRightConstraint.constant == self.rightBottomCellViewWidth) {
        return;
    }
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.topCellViewLeftConstraint.constant = -self.rightBottomCellViewWidth;
        self.topCellViewRightConstraint.constant = self.rightBottomCellViewWidth;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.topCellViewRightConstraint.constant;
        }];
    }];
}

/**
 *  Commits the change of the constraint values
 *
 *  @param animated   should the change be animated
 *  @param completion completion handler
 */
- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}

/**
 *  Reset constraints value on cell reuse (close the cell)
 */
- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
}

@end