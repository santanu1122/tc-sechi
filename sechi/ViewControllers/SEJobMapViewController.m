//
//  SEJobMapViewController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEJobMapViewController.h"
#import "SEJob.h"
#import "UIAlertView+CLErrorMessages.h"

@interface SEJobMapViewController ()

/**
 *  Text view with address of the job
 */
@property (strong, nonatomic) IBOutlet SETextView *addressTextView;

/**
 *  Map view that will display pin on job address, and route to it if needed
 */
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

/**
 *  MKPointAnnotation object of the job address
 */
@property (strong, nonatomic) MKPointAnnotation* jobAnnotation;

/**
 *  MKAnnotationView shown at jobAnnotation
 */
@property (strong, nonatomic) MKAnnotationView* jobAnnotationView;

@end

@implementation SEJobMapViewController

/**
 *  Setup views properties
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addressTextView.delegate = self;
    self.addressTextView.text = self.job.jobAddressC.copy;
    self.mapView.delegate = self;
}

/**
 *  Setup navigation bar visible, and it's buttons. Update map view with current address.
 *
 *  @param animated
 */
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self setupNavigationBarBackButton];
    [self updateMap];
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

#pragma mark - Actions
/**
 *  Update map pin location when map button was pressed
 *
 *  @param sender object that called the method
 */
- (IBAction)mapButtonTouchedUpInside:(id)sender {
    [self updateMap];
}

/**
 *  Show or update the route to pin when directions button was pressed
 *
 *  @param sender object that called the method
 */
- (IBAction)directionsButtonTouchedUpInside:(id)sender {
    [self updateMapCompletion:^{
        [self showDirections];
    }];
}

#pragma mark - Direction actions

/**
 *  Creates MKDirections request and displays directions on map if response is successfull.
 */
- (void)showDirections {

    MKPlacemark* jobPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.jobAnnotation.coordinate
                                                      addressDictionary:nil];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = [[MKMapItem alloc] initWithPlacemark:jobPlacemark];
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSString* errorMessage = [UIAlertView messageForCLError:error];
            if(!errorMessage) {
                NSLog(@"WARNING: Error message for error %@ not found in CL errors list.", error);
                errorMessage = [NSString stringWithFormat:@"Error occured: %@", error.localizedDescription];
            }
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:errorMessage
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        else {
            [self showDirections:response];
        }
    }];
}

/**
 *  Display routes overlays on map.
 *
 *  @param response MKDirectionsResponse object with routes to selected address
 */
- (void)showDirections:(MKDirectionsResponse *)response
{
    [self.mapView removeOverlays:self.mapView.overlays];
    
    for (MKRoute *route in response.routes) {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

/**
 *  Return MKOverlayRenderer for overlay to display
 *
 *  @param mapView map view where overlay will be displayed
 *  @param overlay overlay for which renderer will be returned
 *
 *  @return MKOverlayRenderer object for overlay or nil
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor blueColor];
        return routeRenderer;
    }
    else return nil;
}

#pragma mark - Map actions
/**
 *  Update location of pin on map to show current address.
 */
- (void) updateMap {
    [self updateMapCompletion:nil];
}

/**
 *  Update location of pin on map to show current address, with completition handler.
 */
- (void) updateMapCompletion: (void (^)(void))completion {
    
    NSMutableDictionary* placeDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSArray* addressComponents = [self.addressTextView.text componentsSeparatedByString:@","];
    if(addressComponents.count > 1) {
        [placeDictionary setObject:[addressComponents objectAtIndex:0]
                            forKey:@"Street"];
        [placeDictionary setObject:[addressComponents objectAtIndex:0]
                            forKey:@"City"];
    } else {
        [placeDictionary setObject:self.addressTextView.text.copy
                            forKey:@"Street"];
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressDictionary:placeDictionary
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         if([placemarks count]) {
                             CLPlacemark *placemark = [placemarks objectAtIndex:0];
                             CLLocation *location = placemark.location;
                             CLLocationCoordinate2D coordinate = location.coordinate;
                             [self.jobAnnotation setCoordinate:coordinate];
                             [self.mapView setCenterCoordinate:coordinate animated:YES];
                             if(self.mapView.annotations.count == 0) {
                                 [self.mapView addAnnotation:self.jobAnnotation];
                             }
                             if(completion) {
                                 completion();
                             }
                         } else {
                             NSString* errorMessage = [UIAlertView messageForCLError:error];
                             if(!errorMessage) {
                                 NSLog(@"WARNING: Error message for error %@ not found in CL errors list.", error);
                                 errorMessage = [NSString stringWithFormat:@"Error occured: %@", error.localizedDescription];
                             }
                             [[[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorMessage
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] show];
                         }
                     }];
}

/**
 *  Returns MKAnnotationView for annotation
 *
 *  @param mapView    map view where annotation will be displayed
 *  @param annotation annotation for which view was requested
 *
 *  @return MKAnnotationView for annotation
 */
- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    return self.jobAnnotationView;
}

#pragma mark - Properties
/**
 *  Return empty MKPointAnnotation for jobAnnotation property if it's not set.
 *
 *  @return MKPointAnnotation
 */
-(MKPointAnnotation *)jobAnnotation {
    if(!_jobAnnotation) {
        _jobAnnotation = [[MKPointAnnotation alloc] init];
    }
    return _jobAnnotation;
}

/**
 *  Returns MKPinAnnotationView for jobAnnotation property
 *
 *  @return MKAnnotationView for jobAnnotation
 */
-(MKAnnotationView *)jobAnnotationView {
    if(!_jobAnnotationView) {
        _jobAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:self.jobAnnotation
                                                          reuseIdentifier:@"nil"]; // ;)
    }
    return _jobAnnotationView;
}

@end
