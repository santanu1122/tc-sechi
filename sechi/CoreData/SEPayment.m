//
//  SEPayment.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEPayment.h"


@implementation SEPayment

@dynamic identifier;
@dynamic c5Source;
@dynamic removed;
@dynamic sfid;
@dynamic lastModifiedDate;
@dynamic createdDate;
@dynamic name;
@dynamic svcJobC;
@dynamic paymentNotesC;
@dynamic statusC;
@dynamic clientNameC;
@dynamic clientAccountC;
@dynamic jobNameC;
@dynamic paymentDateC;
@dynamic paymentAmountC;

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
             @"svc_job__c": @"svcJobC",
             @"payment_notes__c": @"paymentNotesC",
             @"status__c": @"statusC",
             @"client_name__c": @"clientNameC",
             @"client_account__c": @"clientAccountC",
             @"job_name__c": @"jobNameC",
             @"payment_date__c": @"paymentDateC",
             @"payment_amount__c": @"paymentAmountC",
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
