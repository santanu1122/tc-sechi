//
//  SEJobAddViewController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEJobAddViewController.h"

#import "SEJob.h"
#import "SETextFieldTableViewCell.h"
#import "UIView+Hierarchy.h"

@interface SEJobAddViewController ()

/**
 *  Pointer for object that will be created.
 */
@property (strong, nonatomic) SEJob* job;

/**
 *  Table view that will display the form
 */
@property (strong, nonatomic) IBOutlet UITableView *tableView;

/**
 *  Datasource array with UITableViewCell objects that needs to be displayed.
 */
@property (strong, nonatomic) NSArray* datasource;

/**
 *  UITableViewCell objects that are displayed in table view.
 */
@property (strong, nonatomic) SETextFieldTableViewCell* clientCell;
@property (strong, nonatomic) SETextFieldTableViewCell* contactCell;
@property (strong, nonatomic) SETextFieldTableViewCell* phoneCell;
@property (strong, nonatomic) SETextFieldTableViewCell* infoCell;
@property (strong, nonatomic) SETextFieldTableViewCell* addressCell;
@property (strong, nonatomic) SETextFieldTableViewCell* notesCell;

@end

@implementation SEJobAddViewController

/**
 *  Setup table view properties and cells that will be displayed
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupCells];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(74, 0, 0, 0);
}

/**
 *  Prepare cell for each object field that's a need to be filled.
 */
- (void) setupCells {
    self.clientCell = [self.tableView dequeueReusableCellWithIdentifier:SETextFieldTableViewCellIdentifier];
    self.clientCell.label = @"Client:";
    self.clientCell.key = @"clientNameC";
    self.clientCell.value = self.job.clientNameC;
    
    self.contactCell = [self.tableView dequeueReusableCellWithIdentifier:SETextFieldTableViewCellIdentifier];
    self.contactCell.label = @"Contact:";
    self.contactCell.key = @"contactNameC";
    self.contactCell.value = self.job.contactNameC;
    
    self.phoneCell = [self.tableView dequeueReusableCellWithIdentifier:SETextFieldTableViewCellIdentifier];
    self.phoneCell.label = @"Phone:";
    self.phoneCell.key = @"phoneC";
    self.phoneCell.value = self.job.phoneC;
    
    self.infoCell = [self.tableView dequeueReusableCellWithIdentifier:SETextFieldTableViewCellIdentifier];
    self.infoCell.label = @"Info:";
    self.infoCell.key = @"infoTextC";
    self.infoCell.value = self.job.infoTextC;
    
    self.addressCell = [self.tableView dequeueReusableCellWithIdentifier:SETextFieldTableViewCellIdentifier];
    self.addressCell.label = @"Address:";
    self.addressCell.key = @"jobAddressC";
    self.addressCell.value = self.job.jobAddressC;
    
    self.notesCell = [self.tableView dequeueReusableCellWithIdentifier:SETextFieldTableViewCellIdentifier];
    self.notesCell.label = @"Notes:";
    self.notesCell.key = @"notesC";
    self.notesCell.value = self.job.notesC;
    
    self.datasource = @[self.clientCell, self.contactCell, self.phoneCell, self.infoCell, self.addressCell, self.notesCell];
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
    UIBarButtonItem* saveButton = [self setupNavigationBarSaveButton];
    saveButton.target = self;
    saveButton.action = @selector(saveButtonTouchedUpInside:);
}

#pragma mark - actions
/**
 *  After save button was pressed, values filled by the user are validated and if any of them is empty validation alert will be shown.
 *  If everything is ok, data will be saved and the view controller will be dismissed.
 *
 *  @param sender object that called the method
 */
- (void) saveButtonTouchedUpInside: (id) sender {
    
    self.job = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SEJob class])
                                             inManagedObjectContext:[[SERestClient instance] managedObjectContext]];
    
    for (SETextFieldTableViewCell* cell in self.datasource) {
        
        if(cell.valueTextView.text == nil || [cell.valueTextView.text isKindOfClass:[NSNull class]] || [cell.valueTextView.text isEqualToString:@""]) {
            [self.job.managedObjectContext deleteObject:self.job];
            [[[UIAlertView alloc] initWithTitle:@"Validation error"
                                        message:[NSString stringWithFormat:@"%@ field cannot be empty", [cell.label stringByReplacingOccurrencesOfString:@":"
                                                                                                                                              withString:@""]]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return;
        }
        
        [self.job setValue:cell.valueTextView.text forKey:cell.key];
    }
    
    self.job.removed = @"false";
    self.job.createdDate = [NSDate date];
    self.job.lastModifiedDate = [NSDate date];
    
    NSError* error = nil;
    [self.job.managedObjectContext save:&error];
    
    if(error != nil) {
        NSLog(@"%@", error);
    } else {
        [self.job.managedObjectContext saveToPersistentStore:&error];
        if(error != nil) {
            NSLog(@"%@", error);
        }
    }
    
    if(error != nil) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[NSString stringWithFormat:@"Error occured while saving data: %@", error.localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate
/**
 *  Hide keyboard on return when text view is a first responder
 *
 *  @param textView
 *  @param range
 *  @param text
 *
 *  @return BOOL should change the content of the text view
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

/**
 *  Scroll table view to cell that began editing.
 *
 *  @param textView text view that began editing.
 */
- (void) textViewDidBeginEditing:(UITextView *)textView {
    UITableViewCell *cell = (UITableViewCell*)[textView superviewOfClass:[UITableViewCell class]];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

/**
 *  Recalculate height of the cell based on the text view content after it changes.
 *
 *  @param textView UITextView that changed the content.
 */
-(void) textViewDidChange:(UITextView *)textView {
    SETextFieldTableViewCell* cell = (SETextFieldTableViewCell*)[textView superviewOfClass:[SETextFieldTableViewCell class]];
    CGFloat heightNeeded = [cell cellHeightForText:cell.valueTextView.text];
    if(cell.frame.size.height != heightNeeded) {
        cell.height = heightNeeded;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

#pragma mark - UITableViewDatasource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

/**
 *  Return table view cell from datasource and set it's text view delegate to self.
 *
 *  @param tableView
 *  @param indexPath
 *
 *  @return UITableViewCell to display in tableView at indexPath
 */
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SETextFieldTableViewCell* cell = [self.datasource objectAtIndex:indexPath.row];
    cell.valueTextView.delegate = self;
    return cell;
}

/**
 *  Return height for the table view cell for displaying in tableView at indexPath
 *
 *  @param tableView
 *  @param indexPath
 *
 *  @return height for the table view cell for displaying in tableView at indexPath
 */
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SETextFieldTableViewCell *cell = [self.datasource objectAtIndex:indexPath.row];
    if(cell && [cell isKindOfClass:[SETextFieldTableViewCell class]]) {
        return cell.height;
    }
    return 44.0f;
}

@end
