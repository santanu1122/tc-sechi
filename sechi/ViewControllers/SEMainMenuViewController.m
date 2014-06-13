//
//  SEMainMenuViewController.m
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEMainMenuViewController.h"
#import "SEProductsScannerViewController.h"

/**
 *  Custom enum type for indicating user status.
 */
typedef enum {
    SEUserStatusAvailable = 0,
    SEUserStatusTransit = 1,
    SEUserStatusWorking = 2,
    SEUserStatusDND = 3,
} SEUserStatus;

@interface SEMainMenuViewController ()

/**
 *  Top NSLayoutConstraint of the logo image
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logoImageTopMarginConstraint;

/**
 *  Bottom NSLayoutConstraint of the logo image
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logoImageBottomMarginConstraint;

/**
 *  Top NSLayoutConstraint of the main menu
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mainMenuTopMarginConstraint;

/**
 *  Group of buttons used as app main menu
 */
@property (strong, nonatomic) IBOutlet UIView *mainMenu;

/**
 *  Gesture recognizer that selectes current user status
 */
@property (strong, nonatomic) UITapGestureRecognizer* selectStatusGestureRecognizer;
/**
 *  View grouping status indicators
 */
@property (strong, nonatomic) IBOutlet UIView *selectStatusView;
/**
 *  Status available indicator view
 */
@property (strong, nonatomic) IBOutlet UIView *statusAvailableView;
/**
 *  Status trainsit indicator view
 */
@property (strong, nonatomic) IBOutlet UIView *statusTransitView;
/**
 *  Status working indicator view
 */
@property (strong, nonatomic) IBOutlet UIView *statusWorkingView;
/**
 *  Status DND indicator view
 */
@property (strong, nonatomic) IBOutlet UIView *statusDNDView;

/**
 *  Status Available indicator image view
 */
@property (strong, nonatomic) IBOutlet UIImageView* statusAvailableImageView;
/**
 *  Status Transit indicator image view
 */
@property (strong, nonatomic) IBOutlet UIImageView* statusTransitImageView;
/**
 *  Status working indicator image view
 */
@property (strong, nonatomic) IBOutlet UIImageView* statusWorkingImageView;
/**
 *  Status DND indicator image view
 */
@property (strong, nonatomic) IBOutlet UIImageView* statusDNDImageView;

@end

@implementation SEMainMenuViewController

/**
 *  Setup gesture recognizer on status indicator views, fix ui for four inch screens. Sets last used status as active.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(HAS_4_INCH_SCREEN) {
        self.logoImageTopMarginConstraint.constant = 90.0f;
        self.logoImageBottomMarginConstraint.constant = 30.0f;
    } else {
        self.logoImageTopMarginConstraint.constant = 30.0f;
        self.logoImageBottomMarginConstraint.constant = 10.0f;
    }
    
    [self setMainMenuVisible:NO animated:NO];
    self.selectStatusGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(selectStatusAreaTouched:)];
    
    [self.selectStatusView addGestureRecognizer:self.selectStatusGestureRecognizer];
    
    NSNumber *userStatusNumber = [[NSUserDefaults standardUserDefaults] objectForKey:SEUserDefaultsUserStatusKey];
    SEUserStatus userStatus = (SEUserStatus)[userStatusNumber intValue];
    [self setActiveStatus:userStatus];
}

/**
 *  Sets navigation bar visibility
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

/**
 *  Displays main menu if it's hidden.
 */
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.mainMenu.alpha == 0.0f) {
        [self setMainMenuVisible:YES animated:YES];
    }
}

/**
 *  Decides which status was tapped by a user by touch location, then sets this status as active.
 *
 *  @param gestureRecognizer gesture recognizer that recognized a tap
 */
- (void) selectStatusAreaTouched: (UITapGestureRecognizer*) gestureRecognizer {
    if(CGRectContainsPoint(self.statusAvailableView.frame, [gestureRecognizer locationInView: self.selectStatusView])) {
        [self setActiveStatus: SEUserStatusAvailable];
    }
    else if(CGRectContainsPoint(self.statusTransitView.frame, [gestureRecognizer locationInView: self.selectStatusView])) {
        [self setActiveStatus: SEUserStatusTransit];
    }
    else if(CGRectContainsPoint(self.statusWorkingView.frame, [gestureRecognizer locationInView: self.selectStatusView])) {
        [self setActiveStatus: SEUserStatusWorking];
    }
    else if(CGRectContainsPoint(self.statusDNDView.frame, [gestureRecognizer locationInView: self.selectStatusView])) {
        [self setActiveStatus: SEUserStatusDND];
    }
}

/**
 *  Sets active status indicator for specified status
 *
 *  @param userStatus SEUserStatus that should be marked as active.
 */
- (void) setActiveStatus: (SEUserStatus) userStatus {
    
    UIImageView* activeImageView;
    switch (userStatus) {
        case SEUserStatusAvailable:
            activeImageView = self.statusAvailableImageView;
            break;
        case SEUserStatusTransit:
            activeImageView = self.statusTransitImageView;
            break;
        case SEUserStatusWorking:
            activeImageView = self.statusWorkingImageView;
            break;
        case SEUserStatusDND:
            activeImageView = self.statusDNDImageView;
            break;
    }
    
    if(activeImageView) {
        // reset all images to non active
        [@[self.statusAvailableImageView, self.statusTransitImageView, self.statusWorkingImageView, self.statusDNDImageView] makeObjectsPerformSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"icon_status.png"]];
        
        [activeImageView setImage:[UIImage imageNamed:@"icon_status_active.png"]];
        
        [[NSUserDefaults standardUserDefaults]setObject:@(userStatus)
                                                 forKey:SEUserDefaultsUserStatusKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 *  setMainMenuVisible:animated:completion: alias without completion handler
 *
 *  @param visible
 *  @param animated
 */
- (void) setMainMenuVisible: (BOOL) visible animated: (BOOL) animated {
    [self setMainMenuVisible:visible animated:animated completion:nil];
}

/**
 *  Sets Main menu buttons visibility with completion handler
 *
 *  @param visible    should views be shown or hidden
 *  @param animated   should the change be animated or not
 *  @param completion completion handler to run after view properies change
 */
- (void) setMainMenuVisible: (BOOL) visible animated: (BOOL) animated completion: (void (^)(BOOL))completion {
    
    CGFloat topMarginDelta = 50.0f;
    CGFloat newMainMenuTopConstraintConstant = self.mainMenuTopMarginConstraint.constant;
    
    if(visible) {
        newMainMenuTopConstraintConstant += topMarginDelta;
    } else {
        newMainMenuTopConstraintConstant -= topMarginDelta;
    }
    
    void (^actionsBlock)(void) = ^() {
        self.mainMenu.alpha = visible ? 1.0f : 0.0f;
        self.mainMenuTopMarginConstraint.constant = newMainMenuTopConstraintConstant;
        [self.view layoutIfNeeded];
    };
    
    if(animated) {
        [UIView animateWithDuration:visible ? 0.3f : 0.2f
                         animations:actionsBlock
                         completion:completion];
    } else {
        actionsBlock();
        if(completion) {
            completion(YES);
        }
    }
    
}

@end

