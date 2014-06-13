//
//  SEJobsViewController.m
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEJobsViewController.h"
#import "SEJobViewController.h"
#import "SEJobTableViewCell.h"
#import "SEJob.h"
#import "UIView+Hierarchy.h"

@interface SEJobsViewController ()

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
@property (strong, nonatomic) SEJobTableViewCell* temporaryCell;

/**
 *  Index path of cell that began process of removing (swipe, press delete button etc).
 */
@property (strong, nonatomic) NSIndexPath* indexPathToRemove;

/**
 *  Gesture recognizer used to cancel the custom edit mode of the table view.
 */
@property (strong, nonatomic) UIPanGestureRecognizer* editModeGestureRecognizer;

@end

@implementation SEJobsViewController

/**
 *  Setup delegates and gesture recognizer for swipeable cells
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.managedObjectContext = [[SERestClient instance] managedObjectContext];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(74, 0, 0, 0);
    
    self.editModeGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(viewWasPanned:)];
    [self.view addGestureRecognizer:self.editModeGestureRecognizer];
    self.editModeGestureRecognizer.delegate = self;
    
    [[SERestClient instance] refreshJobsList];
}

/**
 *  Setup navigation bar buttons
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
 *  Pushing SEJobAddViewController after add button was pressed
 *
 *  @param sender
 */
- (void) addButtonTouchedUpInside: (id) sender {
    [self performSegueWithIdentifier:SEPushJobAddViewControllerSegue
                              sender:self];
}

/**
 *  Asks for confirmation before deleting row
 *
 *  @param sender
 */
- (IBAction)deleteButtonTouchedUpInside:(id)sender {
    
    UITableViewCell* cell = (UITableViewCell*)[sender superviewOfClass:([UITableViewCell class])];
    
    if(cell) {
        self.indexPathToRemove = [self.tableView indexPathForCell:cell];
        
        [[[UIAlertView alloc] initWithTitle:@"Confirm"
                                    message:@"Do you want to delete this job?"
                                   delegate:self
                          cancelButtonTitle:@"NO"
                          otherButtonTitles:@"YES", nil] show];
    }
}

#pragma mark - editModeGestureRecognizer
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

/**
 *  If table is in edit mode, and user starts touching other place than the current cell, edit mode will be canceled.
 *
 *  @param panGestureRecognizer
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
 *  Lock swipe gesture on cells when table is being scrolled
 *
 *  @param scrollView
 */
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSArray* visibleCellsIndexPaths = [self.tableView indexPathsForVisibleRows];
    [visibleCellsIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SESwipeableTableViewCell* cell = (SESwipeableTableViewCell*)[self.tableView cellForRowAtIndexPath:obj];
        cell.swipeEnabled = NO;
    }];
}

/**
 *  Enable swipeability on cells when table view stops scrolling
 *
 *  @param scrollView
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
 *  Lock table view scroll when cell sipe gesture started
 *
 *  @param cell swipeable cell that started moving content
 */
- (void)swipeableCellWillStartMovingContent:(SESwipeableTableViewCell *)cell {
    self.tableView.scrollEnabled = NO;
}

/**
 *  called after swipeable cell opens its contents
 *
 *  @param cell
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
 *  called after swipeable cell will close its content
 *
 *  @param cell
 */
- (void) cellDidClose:(SESwipeableTableViewCell *)cell {
    self.tableView.scrollEnabled = YES;
}

#pragma mark - UIAlertViewDelegate
/**
 *  If user confirmed delete action, row is deleted. Otherwise delete button will be hidden
 *
 *  @param alertView
 *  @param buttonIndex
 */
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex != alertView.cancelButtonIndex) {
        SEJob* job = [self.fetchedResultsController objectAtIndexPath:self.indexPathToRemove];
        job.removed = @"true";
        NSError* error = nil;
        [job.managedObjectContext save:&error];
        if(error != nil) {
            NSLog(@"%@", error);
        } else {
            [job.managedObjectContext saveToPersistentStore:&error];
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
    SEJobTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SEJobTableViewCellIdentifier];
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Fetched results controller
/**
 *  Setting up NSFetchedResultsController for presenting rows from database
 *
 *  @return fetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SEJob" inManagedObjectContext:self.managedObjectContext];
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
 *  Set cell's content
 *
 *  @param cell      current cel
 *  @param indexPath current index path
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[SEJobTableViewCell class]]) {
        SEJob *job = [self.fetchedResultsController objectAtIndexPath:indexPath];
        SEJobTableViewCell* jobCell = (SEJobTableViewCell*) cell;
        jobCell.clientNameLabel.text = job.clientNameC;
        jobCell.contactNameLabel.text = job.contactNameC;
        jobCell.jobAddressLabel.text = job.jobAddressC;
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        
        NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.timeStyle = NSDateFormatterShortStyle;
        timeFormatter.dateStyle = NSDateFormatterNoStyle;
        
        jobCell.dateLabel.text = [[dateFormatter stringFromDate:job.jobStartTimeC] uppercaseString];
        jobCell.timeLabel.text = [[[timeFormatter stringFromDate:job.jobStartTimeC] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        jobCell.statusImageView.image = [UIImage imageNamed:[job.statusC isEqualToString:@"Complete"] ? @"icon_status_small_active" : @"icon_status_small"];
        
        jobCell.bottomCellView.backgroundColor = [UIColor colorWithRed:0.85 green:0.109 blue:0.36 alpha:1];
    }
}

#pragma mark - Navigation
/**
 *  Prepare for moving to next view controller
 *
 *  @param segue
 *  @param sender
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue destinationViewController] isKindOfClass:[SEJobViewController class]] && [sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        SEJob* job = [self.fetchedResultsController objectAtIndexPath:indexPath];
        SEJobViewController* vc = (SEJobViewController*)[segue destinationViewController];
        vc.job = job;
    }
}

@end
