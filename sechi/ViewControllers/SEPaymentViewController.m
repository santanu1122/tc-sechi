//
//  SEPaymentViewController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEPaymentViewController.h"

#import "SEPayment.h"
#import "SERestClient.h"

#import "SEPaymentInfoTableViewCell.h"


@interface SEPaymentViewController ()

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
@property (strong, nonatomic) SEPaymentInfoTableViewCell* tempPaymentInfoCell;

@end

@implementation SEPaymentViewController

/**
 *  Setup table view properties and cells that will be displayed. Prepare temporary cells for use.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.datasource = @[SEPaymentInfoTableViewCellIdentifier];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(68, 0, 0, 0);
    
    self.tempPaymentInfoCell = [self.tableView dequeueReusableCellWithIdentifier:SEPaymentInfoTableViewCellIdentifier];
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
    
    if([cell isKindOfClass:[SEPaymentInfoTableViewCell class]]) {
        SEPaymentInfoTableViewCell *clientInfoCell = (SEPaymentInfoTableViewCell*)cell;
        
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        df.timeStyle = NSDateFormatterNoStyle;
        df.dateStyle = NSDateFormatterMediumStyle;
        
        clientInfoCell.amountLabel.text = self.payment.paymentAmountC.stringValue;
        clientInfoCell.clientLabel.text = self.payment.clientNameC;
        clientInfoCell.jobLabel.text = self.payment.jobNameC;
        clientInfoCell.dateLabel.text = [df stringFromDate:self.payment.paymentDateC];
        clientInfoCell.notesLabel.text = self.payment.paymentNotesC;
        clientInfoCell.notesLabel.font = [SEConstants textFieldFont];
        clientInfoCell.notesLabel.contentInset = UIEdgeInsetsMake(-8,-4,0,0);
        clientInfoCell.notesLabel.userInteractionEnabled = NO;
        clientInfoCell.completeButton.hidden = [self.payment.statusC isEqualToString:@"Complete"];
    }
    
    return cell;
}

/**
 *  Update object status, and hide view controller.
 *
 *  @param sender object that called the method
 */
- (IBAction)completeButtonTouchedUpInside:(id)sender {
    self.payment.statusC = @"Complete";
    
    NSError* error = nil;
    [self.payment.managedObjectContext save:&error];
    if(error != nil) {
        NSLog(@"%@", error);
    } else {
        [self.payment.managedObjectContext saveToPersistentStore:&error];
        if(error != nil) {
            NSLog(@"%@", error);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

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
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateStyle = NSDateFormatterMediumStyle;
    switch (indexPath.row) {
        case 0:
            self.tempPaymentInfoCell.amountLabel.text = self.payment.paymentAmountC.stringValue;
            self.tempPaymentInfoCell.clientLabel.text = self.payment.clientNameC;
            self.tempPaymentInfoCell.jobLabel.text = self.payment.jobNameC;
            self.tempPaymentInfoCell.dateLabel.text = [df stringFromDate:self.payment.paymentDateC];
            self.tempPaymentInfoCell.notesLabel.text = self.payment.paymentNotesC;
            return self.tempPaymentInfoCell.cellHeightNeeded;
            break;
        default:
            break;
    }
    
    return 44.0f;
}

#pragma mark - Navigation
/**
 *  Forward current object to next view controller if it's able to save it.
 *
 *  @param segue  segue that's going to be performed
 *  @param sender object that initiated the segue
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue destinationViewController] respondsToSelector:@selector(setPayment:)]) {
        [[segue destinationViewController] setValue:self.payment forKey:@"payment"];
    }
}

@end
