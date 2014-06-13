//
//  SEProduct.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEProduct.h"


@implementation SEProduct

@dynamic identifier;
@dynamic c5Source;
@dynamic removed;
@dynamic sfid;
@dynamic lastModifiedDate;
@dynamic createdDate;
@dynamic name;
@dynamic active;
@dynamic desc;
@dynamic family;
@dynamic productcode;

/**
 *  Dictionary of values needed for creating RKEntityMapping
 *
 *  @return NSDictionary of API key to property mappings
 */
+ (NSDictionary*) elementToPropertyMappings {
    return @{
             @"id": @"identifier",
             @"_c5_source": @"c5Source",
             @"isdeleted": @"removed",
             @"sfid": @"sfid",
             @"lastmodifieddate": @"lastModifiedDate",
             @"createddate": @"createdDate",
             @"name": @"name",
             @"isactive": @"active",
             @"desc": @"description",
             @"family": @"family",
             @"productcode": @"productcode",
         };
}

+ (RKEntityMapping*) responseMappingForManagedObjectStore: (RKManagedObjectStore*) managedObjectStore {
    
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class])
                                                         inManagedObjectStore:managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:[self elementToPropertyMappings]];
    entityMapping.identificationAttributes = @[ @"identifier" ];
    
    return entityMapping;
}


@end
