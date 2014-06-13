//
//  SEClientViewController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEClientViewController.h"

#import "SEClient.h"
#import "SERestClient.h"

#import "SEClientInfoTableViewCell.h"
#import "SEClientAddressTableViewCell.h"

@interface SEClientViewController ()

/**
 *  UITableView used to display object info.
 */
@property (strong, nonatomic) IBOutlet UITableView *tableView;

/**
 *  Datasource with UITableViewCell identifiers used to display info.
 */
@property (strong, nonatomic) NSArray* datasource;

/**
 *  Temporary cell object used to calculate cell height.
 */
@property (strong, nonatomic) SEClientAddressTableViewCell* tempAddressCell;

/**
 *  Index path of cell that began process of removing (swipe, press delete button etc).
 */
@property (strong, nonatomic) NSIndexPath* indexPathToRemove;

/**
 *  Gesture recognizer used to cancel the custom edit mode of the table view.
 */
@property (strong, nonatomic) UIPanGestureRecognizer* editModeGestureRecognizer;

@end

@implementation SEClientViewController


/**
 *  Setup table view properties and cells that will be displayed. Prepare temporary cells for use.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.datasource = @[SEClientInfoTableViewCellIdentifier, SEClientAddressTableViewCellIdentifier];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(68, 0, 0, 0);
    
    self.tempAddressCell = [self.tableView dequeueReusableCellWithIdentifier:SEClientAddressTableViewCellIdentifier];
    
    self.editModeGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(viewWasPanned:)];
    [self.view addGestureRecognizer:self.editModeGestureRecognizer];
    self.editModeGestureRecognizer.delegate = self;
}

/**
 *  Setup navigation bar visible, and it's buttons.
 *
 *  @param animated
 */
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self setupNavigationBarBackButton];
    [self.tableView reloadData];
}

#pragma mark - editModeGestureRecognizer
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

/**
 *  If any swipeable cell is open at the moment of panning the screen, and the pan started not inside this open cell view. This cell will be closed.
 *
 *  @param panGestureRecognizer UIPanGestureRecognizer that recognized the pan gesture.
 */
- (void) viewWasPanned: (UIPanGestureRecognizer*) panGestureRecognizer {
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        SESwipeableTableViewCell* cell = (SESwipeableTableViewCell*)[self.tableView cellForRowAtIndexPath:self.indexPathToRemove];
        CGPoint beginingTouchPoint = [panGestureRecognizer locationInView:cell];
        BOOL xContains = beginingTouchPoint.x > 0 && beginingTouchPoint.x < cell.frame.size.width;
        BOOL yContains = beginingTouchPoint.y > 0 && beginingTouchPoint.y < cell.frame.size.height;
        if(!(xContains && yContains)) {
            [cell closeCellAnimated:YES];
            self.tableView.scrollEnabled = YES;
        }
    }
}

#pragma mark - UIScrollViewDelegate (tableView)
/**
 *  Disallow swipe gesture on visible cells when table view did start scrolling.
 *
 *  @param scrollView scrollView (table view) that begin scrolling.
 */
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSArray* visibleCellsIndexPaths = [self.tableView indexPathsForVisibleRows];
    [visibleCellsIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SESwipeableTableViewCell* cell = (SESwipeableTableViewCell*)[self.tableView cellForRowAtIndexPath:obj];
        cell.swipeEnabled = NO;
    }];
}

/**
 *  Allow swipe gesture on visible cells after scroll view (table view) did end decelerating.
 *
 *  @param scrollView scroll view (table view) that end decelerating.
 */
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSArray* visibleCellsIndexPaths = [self.tableView indexPathsForVisibleRows];
    [visibleCellsIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SESwipeableTableViewCell* cell = (SESwipeableTableViewCell*)[self.tableView cellForRowAtIndexPath:obj];
        cell.swipeEnabled = YES;
    }];
}

#pragma mark - SESwipeableTableViewCellDelegate
/**
 *  Disable table view scrolling when swipe gesture was recognized on any swipeable cells.
 *
 *  @param cell SESwipeableTableViewCell that begin swipe gesture.
 */- (void)swipeableCellWillStartMovingContent:(SESwipeableTableViewCell *)cell {
    self.tableView.scrollEnabled = NO;
}

/**
 *  After opening a new cell, every other that was already opened will be closed.
 *
 *  @param cell SESwipeableCell that was opened.
 */
- (void) cellDidOpen: (SESwipeableTableViewCell*) cell {
    
    NSIndexPath* newIndexPathToRemove = [self.tableView indexPathForCell:cell];
    
    if(self.indexPathToRemove && ![self.indexPathToRemove isEqual:newIndexPathToRemove]) {
        SESwipeableTableViewCell* oldCell = (SESwipeableTableViewCell*)[self.tableView cellForRowAtIndexPath:self.indexPathToRemove];
        [oldCell closeCellAnimated:YES];
    }
    
    self.indexPathToRemove = newIndexPathToRemove;
    self.tableView.scrollEnabled = NO;
}

/**
 *  Enable table view scrolling after open cell was closed.
 *
 *  @param cell SESwipeableTableViewCell that was closed.
 */
- (void) cellDidClose:(SESwipeableTableViewCell *)cell {
    self.tableView.scrollEnabled = YES;
}

#pragma mark - UITableViewDatasource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

/**
 *  Setup cell content
 *
 *  @param tableView UITableView that the cell will be displayed in
 *  @param indexPath NSIndexPath at which the cell will be displayed
 *
 *  @return UITableViewCell to display
 */
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    NSString* identifier = [self.datasource objectAtIndex:row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if([cell isKindOfClass:[SESwipeableTableViewCell class]]) {
        [((SESwipeableTableViewCell*)cell) setDelegate:self];
    }
    
    if([cell isKindOfClass:[SEClientInfoTableViewCell class]]) {
        SEClientInfoTableViewCell *clientInfoCell = (SEClientInfoTableViewCell*)cell;
        clientInfoCell.clientLabel.text = self.client.companyNameC;
        clientInfoCell.contactLabel.text = self.client.name;
        clientInfoCell.phoneLabel.text = self.client.businessPhoneC;
        clientInfoCell.emailLabel.text = self.client.email;
        clientInfoCell.bottomCellView.backgroundColor = [UIColor colorWithRed:0.137 green:0.121 blue:0.125 alpha:1];
        
        [clientInfoCell.callButton addTarget:self
                                      action:@selector(callButtonTouchedUpInside:)
                            forControlEvents:UIControlEventTouchUpInside];
    }
    else if([cell isKindOfClass:[SEClientAddressTableViewCell class]]) {
        SEClientAddressTableViewCell *addressCell = (SEClientAddressTableViewCell*)cell;
        addressCell.addressLabel.text = self.client.companyAddressC;
        addressCell.addressLabel.font = [SEConstants textFieldFont];
        addressCell.addressLabel.contentInset = UIEdgeInsetsMake(-8,-4,0,0);
        addressCell.addressLabel.userInteractionEnabled = NO;
        addressCell.bottomCellView.backgroundColor = [UIColor colorWithRed:0.137 green:0.121 blue:0.125 alpha:1];
    }
    
    return cell;
}

#pragma mark - actions
/**
 *  Initiate phone dialer with number from objects property
 *
 *  @param sender object that called the method
 */
- (void) callButtonTouchedUpInside: (id) sender {
    NSString* phone = [[self.client.businessPhoneC componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",phone]];
    
    if([[UIApplication sharedApplication] canOpenURL:callUrl]) {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else {
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }}

#pragma mark - UITableViewDelegate
/**
 *  Calculate height needed for cell based on it's content.
 *
 *  @param tableView
 *  @param indexPath
 *
 *  @return height needed by a cell ti display properly all content.
 */
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            return 105.0f;
            break;
        case 1:
            self.tempAddressCell.addressLabel.text = self.client.companyAddressC;
            CGFloat heightNeeded = self.tempAddressCell.cellHeightNeeded;
            return heightNeeded;
            break;
        default:
            break;
    }
    
    return 44.0f;
}

#pragma mark - Navigation
/**
 *  Pass selected object to next view controller if it needs it.
 *
 *  @param segue  segue that will occur
 *  @param sender object that begin the segue
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue destinationViewController] respondsToSelector:@selector(setClient:)]) {
        [[segue destinationViewController] setValue:self.client forKey:@"client"];
    }
}

@end
