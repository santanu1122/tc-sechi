//
//  SEClientsViewController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEClientsViewController.h"
#import "SEClientViewController.h"
#import "SEClientTableViewCell.h"
#import "SEClient.h"
#import "UIView+Hierarchy.h"

@interface SEClientsViewController ()

/**
 *  Fetched results controller used to retrive content for table view.
 */
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

/**
 *  Managed object context used by fetched results controller.
 */
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/**
 *  Table view with list of objects
 */
@property (strong, nonatomic) IBOutlet UITableView *tableView;

/**
 *  Temporary cell used for calculating height of the displayed cells.
 */
@property (strong, nonatomic) SEClientTableViewCell* temporaryCell;

/**
 *  Index path of cell that began process of removing (swipe, press delete button etc).
 */
@property (strong, nonatomic) NSIndexPath* indexPathToRemove;

/**
 *  Gesture recognizer used to cancel the custom edit mode of the table view.
 */
@property (strong, nonatomic) UIPanGestureRecognizer* editModeGestureRecognizer;

@end

@implementation SEClientsViewController

/**
 *  Setup views properties, gesture recognizer and initiates displayed objects sync.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.managedObjectContext = [[SERestClient instance] managedObjectContext];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(68, 0, 0, 0);
    
    self.editModeGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(viewWasPanned:)];
    [self.view addGestureRecognizer:self.editModeGestureRecognizer];
    self.editModeGestureRecognizer.delegate = self;
    
    [[SERestClient instance] refreshClientsList];
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
    UIButton* addButton = [self setupNavigationBarAddButton];
    [addButton addTarget:self action:@selector(addButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - actions
/**
 *  Show view controller with form for adding new object to the list.
 *
 *  @param sender button that called the method
 */
- (void) addButtonTouchedUpInside: (id) sender {
    [self performSegueWithIdentifier:SEPushJobAddViewControllerSegue
                              sender:self];
}

/**
 *  Display confirm alert after pressing objects delete button.
 *
 *  @param sender object that sent the message
 */
- (IBAction)deleteButtonTouchedUpInside:(id)sender {
    
    UITableViewCell* cell = (UITableViewCell*)[sender superviewOfClass:([UITableViewCell class])];
    
    if(cell) {
        self.indexPathToRemove = [self.tableView indexPathForCell:cell];
        
        [[[UIAlertView alloc] initWithTitle:@"Confirm"
                                    message:@"Do you want to delete this client?"
                                   delegate:self
                          cancelButtonTitle:@"NO"
                          otherButtonTitles:@"YES", nil] show];
    }
}

/**
 *  Initiate phone dialer with number from selected objects property
 *
 *  @param sender object that called the method
 */
- (IBAction)callButtonTouchedUpInside:(id)sender {
    
    UITableViewCell* cell = (UITableViewCell*)[sender superviewOfClass:[UITableViewCell class]];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    if(indexPath) {
        SEClient* client = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSString* phone = [[client.businessPhoneC componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",phone]];
        
        if([[UIApplication sharedApplication] canOpenURL:callUrl]) {
            [[UIApplication sharedApplication] openURL:callUrl];
        }
        else {
            [[[UIAlertView alloc]initWithTitle:@"Error" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }

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
 */
- (void)swipeableCellWillStartMovingContent:(SESwipeableTableViewCell *)cell {
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


#pragma mark - UIAlertViewDelegate
/**
 *  Remove object from database or close opened cell if user confirmed or denied deleting of object in alert view.
 *
 *  @param alertView
 *  @param buttonIndex
 */
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex != alertView.cancelButtonIndex) {
        SEClient* client = [self.fetchedResultsController objectAtIndexPath:self.indexPathToRemove];
        client.removed = @"true";
        NSError* error = nil;
        [client.managedObjectContext save:&error];
        if(error != nil) {
            NSLog(@"%@", error);
        } else {
            [client.managedObjectContext saveToPersistentStore:&error];
            if(error != nil) {
                NSLog(@"%@", error);
            }
        }
        
        self.indexPathToRemove = nil;
    } else {
        SESwipeableTableViewCell* cell = (SESwipeableTableViewCell*)[self.tableView cellForRowAtIndexPath:self.indexPathToRemove];
        [cell closeCellAnimated:YES];
        self.tableView.scrollEnabled = YES;
    }
}

/**
 *  Basic setup of UITableView with NSFetchedResultsViewController
 */
#pragma mark - UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SEClientTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SEClientTableViewCellIdentifier];
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Fetched results controller
/**
 *  Setup NSFetchedResultsController for providing data to UITableView
 */
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SEClient" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSPredicate *deletedPredicate = [NSPredicate predicateWithFormat:@"NOT (removed LIKE %@)", @"true"];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:deletedPredicate];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate
/**
 *  Begin table view updates when fetched results controller wants to change datasource.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

/**
 *  Change content of table view when fetched results controller is making changes to the datasource.
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

/**
 *  Change content of table view when fetched results controller is making changes to the datasource.
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

/**
 *  End table view updates when fetched results controller finished changeing datasource.
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/**
 *  Configure UITableViewCell content that will be displayed at specified index path.
 *
 *  @param cell      UITableViewCell that needs to be configured.
 *  @param indexPath index path at which the cell will be displayed.
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[SEClientTableViewCell class]]) {
        SEClient *client = [self.fetchedResultsController objectAtIndexPath:indexPath];
        SEClientTableViewCell* clientCell = (SEClientTableViewCell*) cell;
        clientCell.clientNameLabel.text = client.name;
        clientCell.phoneLabel.text = client.businessPhoneC;
        clientCell.bottomCellView.backgroundColor = [UIColor colorWithRed:0.85 green:0.109 blue:0.36 alpha:1];
        
        clientCell.deleteButtonBg.backgroundColor = [UIColor colorWithRed:0.85 green:0.109 blue:0.36 alpha:1];
        clientCell.callButtonBg.backgroundColor = [UIColor colorWithRed:0.137 green:0.121 blue:0.125 alpha:1];
    }
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
    if([[segue destinationViewController] isKindOfClass:[SEClientViewController class]] && [sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        SEClient* client = [self.fetchedResultsController objectAtIndexPath:indexPath];
        SEClientViewController* vc = (SEClientViewController*)[segue destinationViewController];
        vc.client = client;
    }
}

@end
