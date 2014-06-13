//
//  SEPayment.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SEPayment : NSManagedObject

/**
 * Property for saving id field returned from API for Payment object.
 */
@property (nonatomic, retain) NSNumber * identifier;

/**
 * Property for saving _c5_source field returned from API for Payment object.
 */
@property (nonatomic, retain) NSString * c5Source;

/**
 * Property for saving isdeleted field returned from API for Payment object.
 */
@property (nonatomic, retain) NSString * removed;

/**
 * Property for saving sfid field returned from API for Payment object.
 */
@property (nonatomic, retain) NSString * sfid;

/**
 * Property for saving lastmodifieddate field returned from API for Payment object.
 */
@property (nonatomic, retain) NSDate * lastModifiedDate;

/**
 * Property for saving createddate field returned from API for Payment object.
 */
@property (nonatomic, retain) NSDate * createdDate;

/**
 * Property for saving name field returned from API for Payment object.
 */
@property (nonatomic, retain) NSString * name;

/**
 * Property for saving svc_job__c field returned from API for Payment object.
 */
@property (nonatomic, retain) NSString * svcJobC;

/**
 * Property for saving payment_notes__c field returned from API for Payment object.
 */
@property (nonatomic, retain) NSString * paymentNotesC;

/**
 * Property for saving status__c field returned from API for Payment object.
 */
@property (nonatomic, retain) NSString * statusC;

/**
 * Property for saving client_name__c field returned from API for Payment object.
 */
@property (nonatomic, retain) NSString * clientNameC;

/**
 * Property for saving client_account__c field returned from API for Payment object.
 */
@property (nonatomic, retain) NSString * clientAccountC;

/**
 * Property for saving job_name__c field returned from API for Payment object.
 */
@property (nonatomic, retain) NSString * jobNameC;

/**
 * Property for saving payment_date__c field returned from API for Payment object.
 */
@property (nonatomic, retain) NSDate * paymentDateC;

/**
 * Property for saving payment_amount__c field returned from API for Payment object.
 */
@property (nonatomic, retain) NSNumber * paymentAmountC;

/**
 *  Returns RestKit RKEntityMapping used for SEPayment object in provided managed object store.
 *
 *  @param managedObjectStore managedObjectStore where objects will be stored
 *
 *  @return RKEntityMapping for use in RestKit response and request descriptors
 */
+ (RKEntityMapping*) responseMappingForManagedObjectStore: (RKManagedObjectStore*) managedObjectStore;

@end
