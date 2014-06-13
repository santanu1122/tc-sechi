//
//  SEProduct.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SEProduct : NSManagedObject


/**
 * Property for saving id field returned by API for Product object.
 */
@property (nonatomic, retain) NSNumber * identifier;

/**
 * Property for saving _c5_source field returned by API for Product object.
 */
@property (nonatomic, retain) NSString * c5Source;

/**
 * Property for saving isdeleted field returned by API for Product object.
 */
@property (nonatomic, retain) NSString * removed;

/**
 * Property for saving sfid field returned by API for Product object.
 */
@property (nonatomic, retain) NSString * sfid;

/**
 * Property for saving lastmodifieddate field returned by API for Product object.
 */
@property (nonatomic, retain) NSDate * lastModifiedDate;

/**
 * Property for saving createddate field returned by API for Product object.
 */
@property (nonatomic, retain) NSDate * createdDate;

/**
 * Property for saving name field returned by API for Product object.
 */
@property (nonatomic, retain) NSString * name;

/**
 * Property for saving isactive field returned by API for Product object.
 */
@property (nonatomic, retain) NSString * active;

/**
 * Property for saving desc field returned by API for Product object.
 */
@property (nonatomic, retain) NSString * desc;

/**
 * Property for saving family field returned by API for Product object.
 */
@property (nonatomic, retain) NSString * family;

/**
 * Property for saving productcode field returned by API for Product object.
 */
@property (nonatomic, retain) NSString * productcode;

/**
 *  Returns RestKit RKEntityMapping used for SEProduct object in provided managed object store.
 *
 *  @param managedObjectStore managedObjectStore where objects will be stored
 *
 *  @return RKEntityMapping for use in RestKit response and request descriptors
 */
+ (RKEntityMapping*) responseMappingForManagedObjectStore: (RKManagedObjectStore*) managedObjectStore;

@end
