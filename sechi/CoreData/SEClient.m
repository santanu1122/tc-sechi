//
//  SEClient.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEClient.h"


@implementation SEClient

@dynamic identifier;
@dynamic c5Source;
@dynamic name;
@dynamic lastModifiedDate;
@dynamic removed;
@dynamic sfid;
@dynamic createdDate;
@dynamic firstname;
@dynamic lastname;
@dynamic email;
@dynamic businessPhoneC;
@dynamic companyAddressC;
@dynamic phone;
@dynamic companyNameC;

/**
 *  Dictionary of values needed for creating RKEntityMapping
 *
 *  @return NSDictionary of API key to property mappings
 */
+ (NSDictionary*) elementToPropertyMappings {
    return @{
             @"id": @"identifier",
             @"_c5_source": @"c5Source",
             @"name": @"name",
             @"lastmodifieddate": @"lastModifiedDate",
             @"isdeleted": @"removed",
             @"sfid": @"sfid",
             @"createddate": @"createdDate",
             @"firstname": @"firstname",
             @"lastname": @"lastname",
             @"email": @"email",
             @"business_phone__c": @"businessPhoneC",
             @"company_address__c": @"companyAddressC",
             @"phone": @"phone",
             @"company_name__c": @"companyNameC",
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
