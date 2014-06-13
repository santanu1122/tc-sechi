//
//  SEJobViewController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEJobViewController.h"

#import "SEJOB.h"
#import "SEJobPhotoInfo.h"
#import "SERestClient.h"

#import "SEJobClientInfoTableViewCell.h"
#import "SEJobAddressTableViewCell.h"
#import "SEJobNotesTableViewCell.h"
#import "SEJobPhotosTableViewCell.h"
#import "SEJobHoursTableViewCell.h"

#import "SENoStatusBarImagePickerController.h"
#import "UIImage+FixOrientation.h"
#import "SEGalleryViewController.h"

@interface SEJobViewController ()

/**
 *  UITableView used to display object info.
 */
@property (strong, nonatomic) IBOutlet UITableView *tableView;

/**
 *  Datasource with UITableViewCell identifiers used to display info.
 */
@property (strong, nonatomic) NSArray* datasource;

/**
 *  Temporary cell objects used to calculate cell height.
 */
@property (strong, nonatomic) SEJobClientInfoTableViewCell* tempClientInfoCell;
@property (strong, nonatomic) SEJobAddressTableViewCell* tempAddressInfoCell;
@property (strong, nonatomic) SEJobNotesTableViewCell* tempNotesInfoCell;

/**
 *  Index path of cell that began process of removing (swipe, press delete button etc).
 */
@property (strong, nonatomic) NSIndexPath* indexPathToRemove;

/**
 *  Gesture recognizer used to cancel the custom edit mode of the table view.
 */
@property (strong, nonatomic) UIPanGestureRecognizer* editModeGestureRecognizer;

@end

@implementation SEJobViewController

/**
 *  Setup table view properties and cells that will be displayed. Prepare temporary cells for use.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.datasource = @[SEJobClientInfoTableViewCellIdentifier, SEJobAddressTableViewCellIdentifier, SEJobNotesTableViewCellIdentifier, SEJobPhotosTableViewCellIdentifier, SEJobHoursTableViewCellIdentifier];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(74, 0, 0, 0);

    self.tempClientInfoCell = [self.tableView dequeueReusableCellWithIdentifier:SEJobClientInfoTableViewCellIdentifier];
    self.tempAddressInfoCell = [self.tableView dequeueReusableCellWithIdentifier:SEJobAddressTableViewCellIdentifier];
    self.tempNotesInfoCell = [self.tableView dequeueReusableCellWithIdentifier:SEJobNotesTableViewCellIdentifier];
    
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

/**
 *  Basic setup of UITableView with NSFetchedResultsViewController
 */
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
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[self.datasource objectAtIndex:indexPath.row]];
    
    if([cell isKindOfClass:[SESwipeableTableViewCell class]]) {
        [((SESwipeableTableViewCell*)cell) setDelegate:self];
    }
    
    if([cell isKindOfClass:[SEJobClientInfoTableViewCell class]]) {
        SEJobClientInfoTableViewCell *clientInfoCell = (SEJobClientInfoTableViewCell*)cell;
        clientInfoCell.clientLabel.text = self.job.clientNameC;
        clientInfoCell.contactLabel.text = self.job.contactNameC;
        clientInfoCell.phoneLabel.text = self.job.phoneC;
        clientInfoCell.infoTextView.text = self.job.infoTextC;
        clientInfoCell.infoTextView.font = [SEConstants textFieldFont];
        clientInfoCell.infoTextView.contentInset = UIEdgeInsetsMake(-8,-4,0,0);
        clientInfoCell.infoTextView.userInteractionEnabled = NO;
        
        clientInfoCell.bottomCellView.backgroundColor = [UIColor colorWithRed:0.137 green:0.121 blue:0.125 alpha:1];        
        [clientInfoCell.callButton addTarget:self
                                      action:@selector(callButtonTouchedUpInside:)
                            forControlEvents:UIControlEventTouchUpInside];
    }
    else if([cell isKindOfClass:[SEJobAddressTableViewCell class]]) {
        SEJobAddressTableViewCell *addressCell = (SEJobAddressTableViewCell*)cell;
        addressCell.addressLabel.text = self.job.jobAddressC;
        addressCell.addressLabel.font = [SEConstants textFieldFont];
        addressCell.addressLabel.contentInset = UIEdgeInsetsMake(-8,-4,0,0);
        addressCell.addressLabel.userInteractionEnabled = NO;
        addressCell.bottomCellView.backgroundColor = [UIColor colorWithRed:0.137 green:0.121 blue:0.125 alpha:1];
    }
    else if([cell isKindOfClass:[SEJobNotesTableViewCell class]]) {
        SEJobNotesTableViewCell *notesCell = (SEJobNotesTableViewCell*)cell;
        notesCell.notesLabel.text = self.job.notesC;
        notesCell.notesLabel.font = [SEConstants textFieldFont];
        notesCell.notesLabel.contentInset = UIEdgeInsetsMake(-8,-4,0,0);
        notesCell.notesLabel.userInteractionEnabled = NO;
    }
    else if([cell isKindOfClass:[SEJobPhotosTableViewCell class]]) {
        SEJobPhotosTableViewCell *photosCell = (SEJobPhotosTableViewCell*)cell;
        photosCell.datasource = self.job.photos.array;
        photosCell.collectionView.delegate = self;
        [photosCell.collectionView reloadData];
    }
    else if([cell isKindOfClass:[SEJobHoursTableViewCell class]]) {
        SEJobHoursTableViewCell *hoursCell = (SEJobHoursTableViewCell*)cell;
        
        hoursCell.hoursLabel.text = @"00:00:00";
        hoursCell.startButton.hidden = NO;
        hoursCell.completeButton.hidden = NO;
        
        NSDateComponents* dc = [[NSDateComponents alloc] init];
        dc.hour = 0;
        dc.minute = 0;
        dc.second = 0;
        
        if([self.job.statusC isEqualToString:@"In Progress"]) {
            hoursCell.startButton.hidden = YES;
            NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            dc = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                 fromDate:self.job.jobStartTimeC
                                                   toDate:[NSDate date]
                                                  options:0];
        }
        else if([self.job.statusC isEqualToString:@"Complete"]) {
            hoursCell.startButton.hidden = YES;
            hoursCell.completeButton.hidden = YES;
            NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            dc = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                 fromDate:self.job.jobStartTimeC
                                                   toDate:self.job.jobEndTimeC
                                                  options:0];
        }
        
        NSString* hours = dc.hour < 10 ? [NSString stringWithFormat:@"0%i", dc.hour] : [NSString stringWithFormat:@"%i", dc.hour];
        NSString* minutes = dc.minute < 10 ? [NSString stringWithFormat:@"0%i", dc.minute] : [NSString stringWithFormat:@"%i", dc.minute];
        NSString* seconds = dc.second < 10 ? [NSString stringWithFormat:@"0%i", dc.second] : [NSString stringWithFormat:@"%i", dc.second];
        
        hoursCell.hoursLabel.text = [NSString stringWithFormat:@"%@:%@:%@", hours, minutes, seconds];
        
        [hoursCell.startButton addTarget:self
                                  action:@selector(startButtonTouchedUpInside:)
                        forControlEvents:UIControlEventTouchUpInside];
        [hoursCell.completeButton addTarget:self
                                     action:@selector(completeButtonTouchedUpInside:)
                           forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

#pragma mark - actions
/**
 *  Initiate phone dialer with number from object property
 *
 *  @param sender object that called the method
 */
- (void) callButtonTouchedUpInside: (id) sender {
    NSString* phone = [[self.job.phoneC componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",phone]];
    
    if([[UIApplication sharedApplication] canOpenURL:callUrl]) {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else {
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

/**
 *  Updates objects status, its start date and dismisses view controller
 *
 *  @param sender object that called the method
 */
- (void) startButtonTouchedUpInside: (id) sender {
    
    NSError* error = nil;
    self.job.jobStartTimeC = [NSDate date];
    self.job.statusC = @"In Progress";
    [self.job.managedObjectContext save:&error];
    if(error != nil) {
        NSLog(@"%@", error);
    } else {
        [self.job.managedObjectContext saveToPersistentStore:&error];
        if(error) {
            NSLog(@"%@", error);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  Updates objects status, its end date and dismisses view controller.
 *
 *  @param sender object that called the method
 */
- (void) completeButtonTouchedUpInside: (id) sender {
    
    self.job.statusC = @"Complete";
    self.job.jobEndTimeC = [NSDate date];
    
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDelegate
/**
 *  Display gallery view controller or image picker when photo from collection view was selected, or add button was pressed
 *
 *  @param collectionView collection view where event occured
 *  @param indexPath      index path of view that was selected
 */
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0 && indexPath.section == 0) {
        [self selectPhoto];
    } else {
        SEGalleryViewController* gallery = [[SEGalleryViewController alloc] initWithMediaFilesArray:self.job.photos.array
                                                                                            atIndex:indexPath.row-1];
        [self.navigationController pushViewController:gallery
                                             animated:YES];
    }
    
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
    
    CGFloat heightNeeded = 0;
    
    switch (indexPath.row) {
        case 0:
            self.tempClientInfoCell.clientLabel.text = self.job.clientNameC;
            self.tempClientInfoCell.contactLabel.text = self.job.contactNameC;
            self.tempClientInfoCell.phoneLabel.text = self.job.phoneC;
            self.tempClientInfoCell.infoTextView.text = self.job.infoTextC;
            heightNeeded = self.tempClientInfoCell.cellHeightNeeded;
            return heightNeeded;
            break;
        case 1:
            self.tempAddressInfoCell.addressLabel.text = self.job.jobAddressC;
            heightNeeded = self.tempAddressInfoCell.cellHeightNeeded;
            return heightNeeded;
            break;
        case 2:
            self.tempNotesInfoCell.notesLabel.text = self.job.notesC;
            heightNeeded = self.tempNotesInfoCell.cellHeightNeeded;
            return heightNeeded;
            break;
        case 3:
            return 63.0f;
            break;
        case 4:
            return 100.0f;
            break;
        default:
            break;
    }
    
    return 44.0f;
}

#pragma mark - Photos
/**
 *  Method decides to show image picker, camera view controller or if both are available ask a user what do he want to do.
 */
- (void) selectPhoto {
    
    BOOL a = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL b = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if(a && b) {
        [[[UIAlertView alloc] initWithTitle:@"Add Photo"
                                   message:@"Select source:"
                                  delegate:self
                         cancelButtonTitle:nil
                          otherButtonTitles:@"Photo library", @"Camera", nil] show];
    } else if (a && !b) {
        [self startCameraControllerFromViewController:self
                                withCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto
                                        usingDelegate:self];
    } else if (!a && b) {
        [self startMediaBrowserFromViewController:self
                                           photos:YES
                                           videos:NO
                                    usingDelegate:self];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"No sources available"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

/**
 *  Pushes selected by user view controller (image picker or camera controller)
 *
 *  @param alertView   alert view with question
 *  @param buttonIndex button index that was pressed
 */
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex != alertView.cancelButtonIndex) {
        
        if(buttonIndex == 0) {
            [self startMediaBrowserFromViewController:self
                                               photos:YES
                                               videos:NO
                                        usingDelegate:self];
        }
        else if(buttonIndex == 1) {
            [self startCameraControllerFromViewController:self
                                    withCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto
                                            usingDelegate:self];
        }
        
    }
}

/**
 *  Displays UIImagePicker
 *
 *  @param controller        controller which initiated the image picker
 *  @param cameraCaptureMode cameraCaputreModes that are allowed
 *
 *  @return YES if image picker was displayed successfully
 */
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                           withCameraCaptureMode: (UIImagePickerControllerCameraCaptureMode) cameraCaptureMode
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    // check args
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    // init picker
    UIImagePickerController *cameraUI = [[SENoStatusBarImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    
    // filter media types
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                           UIImagePickerControllerSourceTypeCamera];
    
    if(cameraCaptureMode == UIImagePickerControllerCameraCaptureModePhoto)
        mediaTypes = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"image"]];
    else
        mediaTypes = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"movie"]];
    
    // error if not movie/photo is not avaliable
    if([mediaTypes count] < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error occured" message:@"Cannot get access to camera." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    // finishing setup
    cameraUI.mediaTypes = mediaTypes;
    [cameraUI setCameraCaptureMode: cameraCaptureMode];
    
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    
    // show picker
    [controller presentViewController:cameraUI
                             animated:YES
                           completion:nil];
    return YES;
}

/**
 *  Displays media browser view controller
 *
 *  @param controller controller which initiated the action
 *  @param showPhotos BOOL, should photos be visible
 *  @param showVideos BOOl, should videos be visible
 *
 *  @return YES if controller was shown, NO otherwise
 */
- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                                      photos: (BOOL) showPhotos
                                      videos: (BOOL) showVideos
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[SENoStatusBarImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    
    if(showPhotos && showVideos) {
        mediaUI.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    } else if(showPhotos) {
        mediaUI.mediaTypes = [NSArray arrayWithObjects:
                              (NSString *) kUTTypeImage, nil];
    } else if(showVideos) {
        mediaUI.mediaTypes = [NSArray arrayWithObjects:
                              (NSString *) kUTTypeMovie, nil];
    }
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI
                             animated:YES
                           completion:nil];
    
    return YES;
}

/**
 *  Method called by UIImagePickerController when user finish picking media
 *
 *  @param picker UIImagePickerController that called the method
 *  @param info   NSDictionary with picked media info
 */
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                                 UIImage* image = nil;
                                 if([info objectForKey:UIImagePickerControllerOriginalImage] != nil) {
                                     image = [info objectForKey:UIImagePickerControllerOriginalImage];
                                 }
                                 
                                 image = [image fixOrientation];
                                 
                                 NSData* imageData = UIImageJPEGRepresentation(image, 0.8f);
                                 
                                 NSString* fileName = [NSString stringWithFormat:@"%@.jpg", [self uuid]];
                                 NSString* filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
                                 
                                 [imageData writeToFile:filePath
                                             atomically:YES];
                                 
                                 SEJobPhotoInfo* photoInfo = (SEJobPhotoInfo*)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SEJobPhotoInfo class])
                                                                                                            inManagedObjectContext:[[SERestClient instance] managedObjectContext]];
                                 photoInfo.filePath = filePath;
                                 photoInfo.job = self.job;
                                 
                                 NSError* error = nil;
                                 
                                 [[[SERestClient instance] managedObjectContext] save:&error];
                                 
                                 if(error != nil) {
                                     [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"Error occured while saving to database."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil] show];
                                 } else {
                                     [[[SERestClient instance] managedObjectContext] saveToPersistentStore:&error];
                                     
                                     if(error != nil) {
                                         [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:@"Error occured while saving to database."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil] show];
                                     }
                                 }
                                 
                                 [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:3 inSection:0]]
                                                       withRowAnimation:UITableViewRowAnimationNone];
                             }];
}

/**
 *  Generates unique id string used for naming a file
 *
 *  @return unique id string
 */
- (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge NSString *)uuidStringRef;
}

/**
 *  Returns a path to application documents directiory
 *
 *  @return path to application documents directiory
 */
- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

/**
 *  Returns a path to application caches directiory
 *
 *  @return path to application caches directiory
 */
- (NSString *) applicationCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
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
    if([[segue destinationViewController] respondsToSelector:@selector(setJob:)]) {
        [[segue destinationViewController] setValue:self.job forKey:@"job"];
    }
}
@end
