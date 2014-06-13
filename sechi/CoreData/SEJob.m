//
//  SEJob.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEJob.h"


@implementation SEJob

@dynamic c5Source;
@dynamic clientAccountC;
@dynamic clientContactC;
@dynamic clientNameC;
@dynamic contactNameC;
@dynamic createdDate;
@dynamic identifier;
@dynamic infoTextC;
@dynamic removed;
@dynamic jobAddressC;
@dynamic jobEndTimeC;
@dynamic jobNameC;
@dynamic jobStartTimeC;
@dynamic lastModifiedDate;
@dynamic latitudeC;
@dynamic longitudeC;
@dynamic name;
@dynamic notesC;
@dynamic phoneC;
@dynamic sfid;
@dynamic statusC;
@dynamic photos;

/**
 *  Dictionary of values needed for creating RKEntityMapping
 *
 *  @return NSDictionary of API key to property mappings
 */
+ (NSDictionary*) elementToPropertyMappings {
    return @{
             @"id": @"identifier",
             @"name": @"name",
             @"job_name__c": @"jobNameC",
             @"job_address__c": @"jobAddressC",
             @"notes__c": @"notesC",
             @"info_text__c": @"infoTextC",
             @"contact_name__c": @"contactNameC",
             @"client_name__c": @"clientNameC",
             @"sfid": @"sfid",
             @"client_contact__c": @"clientContactC",
             @"client_account__c": @"clientAccountC",
             @"status__c": @"statusC",
             @"phone__c": @"phoneC",
             @"isdeleted": @"removed",
             @"_c5_source": @"c5Source",
             @"longitude__c": @"longitudeC",
             @"latitude__c": @"latitudeC",
             @"job_end_time__c": @"jobEndTimeC",
             @"job_start_time__c": @"jobStartTimeC",
             @"createddate": @"createdDate",
             @"lastmodifieddate": @"lastModifiedDate",
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
