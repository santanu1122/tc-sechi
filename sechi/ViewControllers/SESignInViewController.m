//
//  SESignInViewController.m
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SESignInViewController.h"


@interface SESignInViewController ()

/**
 *  Top logo image NSLayoutConstraint
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logoImageTopMarginConstraint;

/**
 *  Top NSLayoutConstraint of group of form items (text fields and signup button)
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *signInControlsGroupTopConstraint;

/**
 *  View that's grouping sign in controls (text fields and signup button)
 */
@property (strong, nonatomic) IBOutlet UIView *signInControlsGroup;

/**
 *  Text field for username
 */
@property (strong, nonatomic) IBOutlet SETextField *usernameTextField;

/**
 *  Text field for password
 */
@property (strong, nonatomic) IBOutlet SETextField *passwordTextField;

/**
 *  Top NSLayoutConstraint of activity indicator
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *activityIndicatorTopConstraint;

/**
 *  ActivityIndicator used to indicate loading / signing up phase
 */
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SESignInViewController

/**
 *  Set views visibility, updates UI for 4 inch screens, sets views properies
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setActivityIndicatorVisible:NO animated:NO];
    [self setSignInControlsGroupVisible:NO animated:NO];
    
    if(HAS_4_INCH_SCREEN) {
        self.logoImageTopMarginConstraint.constant = 90.0f;
    } else {
        self.logoImageTopMarginConstraint.constant = 30.0f;
    }
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

/**
 *  Setups navigation bar visibility
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

/**
 *  Sets sign in controls visible
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setSignInControlsGroupVisible:YES animated:YES];
}

/**
 *  Hides all controls of the view after it disappears.
 */
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setSignInControlsGroupVisible:NO animated:NO];
    [self setActivityIndicatorVisible:NO animated:NO];
}

/**
 *  Simulate signup process, displays activity indicator, and pushes main menu view controller after 1.5 sec
 */
- (IBAction)signInButtonTouchedUpInside:(id)sender {
    
    __weak SESignInViewController* weakSelf = self;
    
    [self setActivityIndicatorVisible:YES animated:YES];
    [self setSignInControlsGroupVisible:NO animated:YES completion:^(BOOL finished) {
        weakSelf.usernameTextField.text = @"";
        weakSelf.passwordTextField.text = @"";
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self setActivityIndicatorVisible:NO
                                 animated:YES
                               completion:^(BOOL finished) {
                                   [weakSelf performSegueWithIdentifier:SEPushMainMenuViewControllerSegue
                                                             sender:sender];
                               }];
    });
}

/**
 *  setSignInControlsGroupVisible:animated:completion: alias without completion handler
 *
 *  @param visible
 *  @param animated
 */
- (void) setSignInControlsGroupVisible: (BOOL) visible animated: (BOOL) animated {
    [self setSignInControlsGroupVisible:visible animated:animated completion:nil];
}

/**
 *  Sets the sign in controls visibility with completition handler
 *
 *  @param visible    should controls be shown or hidden
 *  @param animated   should the change be animated
 *  @param completion completion block, runned after changeing view attributes
 */
- (void) setSignInControlsGroupVisible: (BOOL) visible animated: (BOOL) animated completion: (void (^)(BOOL))completion {
    
    CGFloat topMarginDelta = 50.0f;
    CGFloat newSignInControlsGroupTopConstraintConstant = self.signInControlsGroupTopConstraint.constant;
    
    if(visible) {
        newSignInControlsGroupTopConstraintConstant -= topMarginDelta;
    } else {
        newSignInControlsGroupTopConstraintConstant += topMarginDelta;
    }
    
    void (^actionsBlock)(void) = ^() {
        self.signInControlsGroup.alpha = visible ? 1.0f : 0.0f;
        self.signInControlsGroupTopConstraint.constant = newSignInControlsGroupTopConstraintConstant;
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

/**
 *  setActivityIndicatorVisible:animated:completion: alias without completion handler
 *
 *  @param visible
 *  @param animated
 */
- (void) setActivityIndicatorVisible: (BOOL) visible animated: (BOOL) animated {
    [self setActivityIndicatorVisible:visible animated:animated completion:nil];
}

/**
 *  Sets the activity indicator visibility with completition handler
 *
 *  @param visible    should activity indicator be shown or hidden
 *  @param animated   should the change be animated
 *  @param completion completion block, runned after changeing view attributes
 */
- (void) setActivityIndicatorVisible: (BOOL) visible animated: (BOOL) animated completion: (void (^)(BOOL))completion {
    
    CGFloat topMarginDelta = 30.0f;
    CGFloat newActivityIndicatorTopConstraintConstant = self.activityIndicatorTopConstraint.constant;
    
    if(visible) {
        newActivityIndicatorTopConstraintConstant += topMarginDelta;
        [self.activityIndicator startAnimating];
    } else {
        newActivityIndicatorTopConstraintConstant -= topMarginDelta;
        [self.activityIndicator stopAnimating];
    }
    
    void (^actionsBlock)(void) = ^() {
        self.activityIndicator.alpha = visible ? 1.0f : 0.0f;
        self.activityIndicatorTopConstraint.constant = newActivityIndicatorTopConstraintConstant;
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

#pragma mark - UITextFieldDelegate
/**
 *  Hide keyboard on text field return
 *
 *  @param textField text field that wants to return
 *
 *  @return BOOL disallowing textfield return
 */
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
