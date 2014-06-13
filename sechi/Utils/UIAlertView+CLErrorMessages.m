//
//  UIAlertView+CLErrorMessages.m
//  sechi
//
//  Created by karolszafranski on 13.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "UIAlertView+CLErrorMessages.h"
#import <MapKit/MapKit.h>

@implementation UIAlertView (CLErrorMessages)

/**
 *  Route trought domains
 *
 *  @param error error for which description is needed
 *
 *  @return error description or nil.
 */
+ (NSString*) messageForError: (NSError*) error {
    
    if([error.domain isEqualToString:kCLErrorDomain]) {
        return [self messageForCLError:error];
    }
    else if([error.domain isEqualToString:MKErrorDomain]) {
        return [self messageForMKError: error];
    }
    
    return nil;
}


/**
 *  User friendly message for MapKit errors
 *
 *  @param error error for which description is needed
 *
 *  @return error description or nil
 */
+ (NSString*) messageForMKError: (NSError*) error {
    switch (error.code) {
        case MKErrorUnknown:
            return @"An unknown error occurred.";
            break;
            
        case MKErrorServerFailure:
            return @"The map server was unable to return the desired information.";
            break;
            
        case MKErrorLoadingThrottled:
            return @"The data was not loaded because data throttling is in effect.";
            break;
            
        case MKErrorPlacemarkNotFound:
            return @"The specified placemark could not be found.";
            break;
            
        case MKErrorDirectionsNotFound: 
            return @"The specified directions could not be found.";
            break;
    }
    
    return nil;
}

/**
 *  User friendly message for CoreLocation errors
 *
 *  @param error error for which description is needed
 *
 *  @return error description or nil
 */
+ (NSString*) messageForCLError: (NSError*) error {
    
    switch (error.code) {
        case kCLErrorLocationUnknown:
            return @"Location is currently unknown, but application will keep trying to retreive it. Please check location access for this app in settings.";
            break;
            
        case kCLErrorDenied:
            return @"Access to location or ranging has been denied by the user. Please check location access for this app in settings.";
            break;
            
        case kCLErrorNetwork:
            return @"Network is not available. Please check network connection.";
            break;
            
//        case kCLErrorHeadingFailure:
//            return @"Heading could not be determined";
//            break;
            
        case kCLErrorRegionMonitoringDenied:
            return @"Location region monitoring has been denied by the user. Please check location access for this app in settings.";
            break;
            
        case kCLErrorRegionMonitoringFailure:
            return @"Please validate provided address, and location access.";
//            return @"A registered region cannot be monitored.";
            break;
            
//        case kCLErrorRegionMonitoringSetupDelayed:
//            return @"Application could not immediately initialize region monitoring";
//            break;
            
//        case kCLErrorRegionMonitoringResponseDelayed:
//            return @"While events for this fence will be delivered, delivery will not occur immediately";
//            break;
            
        case kCLErrorGeocodeFoundNoResult:
            return @"A geocode request yielded no result. Please check if address is valid.";
            break;
            
        case kCLErrorGeocodeFoundPartialResult:
            return @"A geocode request yielded a partial result";
            break;
            
        case kCLErrorGeocodeCanceled:
            return @"A geocode request was cancelled";
            break;
            
        case kCLErrorDeferredFailed:
            return @"Deferred mode failed";
            break;
            
        case kCLErrorDeferredNotUpdatingLocation:
            return @"Deferred mode failed because location updates disabled or paused";
            break;
            
//        case kCLErrorDeferredAccuracyTooLow:
//            return @"Deferred mode not supported for the requested accuracy";
//            break;
            
        case kCLErrorDeferredDistanceFiltered:
            return @"Deferred mode does not support distance filters";
            break;
            
        case kCLErrorDeferredCanceled:
            return @"Deferred mode request canceled a previous request";
            break;
            
        case kCLErrorRangingUnavailable:
            return @"Ranging cannot be performed";
            break;
            
        case kCLErrorRangingFailure:
            return @"General ranging failure";
            break;
    }
    
    return nil;
}

@end
