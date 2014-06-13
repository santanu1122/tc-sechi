//
//  SEClient.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SEClient : NSManagedObject

/*
 * Property for saving id field returned by API for Client object.
 */
@property (nonatomic, retain) NSNumber * identifier;

/*
 * Property for saving _c5_source field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * c5Source;

/*
 * Property for saving name field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * name;

/*
 * Property for saving lastmodifieddate field returned by API for Client object.
 */
@property (nonatomic, retain) NSDate * lastModifiedDate;

/*
 * Property for saving isdeleted field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * removed;

/*
 * Property for saving sfid field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * sfid;

/*
 * Property for saving createddate field returned by API for Client object.
 */
@property (nonatomic, retain) NSDate * createdDate;

/*
 * Property for saving firstname field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * firstname;

/*
 * Property for saving lastname field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * lastname;

/*
 * Property for saving email field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * email;

/*
 * Property for saving business_phone__c field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * businessPhoneC;

/*
 * Property for saving company_address__c field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * companyAddressC;

/*
 * Property for saving phone field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * phone;

/*
 * Property for saving company_name__c field returned by API for Client object.
 */
@property (nonatomic, retain) NSString * companyNameC;

/**
 *  Returns RestKit RKEntityMapping used for SEClient object in provided managed object store.
 *
 *  @param managedObjectStore managedObjectStore where objects will be stored
 *
 *  @return RKEntityMapping for use in RestKit response and request descriptors
 */
+ (RKEntityMapping*) responseMappingForManagedObjectStore: (RKManagedObjectStore*) managedObjectStore;

@end
