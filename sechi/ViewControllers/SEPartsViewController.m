//
//  SEPartsViewController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEPartsViewController.h"

#import "SEProductTableViewCell.h"
#import "SEProduct.h"
#import "UIView+Hierarchy.h"

@interface SEPartsViewController ()

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
@property (strong, nonatomic) SEProductTableViewCell* temporaryCell;

/**
 *  Index path of cell that began process of removing (swipe, press delete button etc).
 */
@property (strong, nonatomic) NSIndexPath* indexPathToRemove;

/**
 *  Gesture recognizer used to cancel the custom edit mode of the table view.
 */
@property (strong, nonatomic) UIPanGestureRecognizer* editModeGestureRecognizer;

/**
 *  UISearchBar object that's used to search objects in table view.
 */
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SEPartsViewController

/**
 *  Setup views properties and initiates displayed objects sync.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.managedObjectContext = [[SERestClient instance] managedObjectContext];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(68, 0, 0, 0);
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor whiteColor];
    
    [[SERestClient instance] refreshPartsList];
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
    [self performSegueWithIdentifier:SEPushModalProductCodeReaderViewControllerSegue
                              sender:self];
}

/**
 *  Display product code scanner view controller.
 */
- (void) showProductCodeScannerController {
    [self performSegueWithIdentifier:SEPushModalProductCodeReaderViewControllerSegue
                              sender:nil];
}

/**
 *  Update data from API if search button was clicked.
 */
#pragma mark - UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [[SERestClient instance] refreshPartsList];
    [searchBar resignFirstResponder];
}

/**
 *  Update data from API if cancel button was clicked.
 */
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [[SERestClient instance] refreshPartsList];
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
    SEProductTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SEProductTableViewCellIdentifier];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SEProduct" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (removed LIKE %@)", @"true"];

    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:predicate];
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
    if([cell isKindOfClass:[SEProductTableViewCell class]]) {
        SEProduct *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
        SEProductTableViewCell* productCell = (SEProductTableViewCell*) cell;
        productCell.productName.text = product.name;
        productCell.productCode.text = product.productcode;
    }
}

#pragma mark - Navigation
/**
 *  Set self as SEProductsScannerViewController if it's going to be displayed.
 *
 *  @param segue  segue that will occur
 *  @param sender object that begin the segue
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEPushModalProductCodeReaderViewControllerSegue]) {
        SEProductsScannerViewController* psvc = segue.destinationViewController;
        psvc.delegate = self;
    }

}

#pragma mark - SEProductsScannerViewControllerDelegate
/**
 *  Dismiss SEProductsScannerViewController if it canceled reading the codes.
 *
 *  @param productsScannerViewController that wants to be dismissed
 */
-(void)productsScannerViewControllerDidCancelReading:(SEProductsScannerViewController *)productsScannerViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  Dismiss SEProductsScannerViewController and set the content that it read as the value of the search bar.
 *
 *  @param productsScannerViewController SEProductsScannerViewController that read the metadata
 *  @param string                        metadata decoded to string
 */
-(void)productsScannerViewController:(SEProductsScannerViewController *)productsScannerViewController didReadString:(NSString *)string {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 self.searchBar.text = string;
                                 [self.tableView reloadData];
                             }];
}

@end
