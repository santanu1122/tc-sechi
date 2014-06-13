//
//  SERestClient.m
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SERestClient.h"
#import "SEJob.h"
#import "SEClient.h"
#import "SEProduct.h"
#import "SEPayment.h"

@interface SERestClient()

@property (nonatomic) BOOL apiErrorWasDisplayed;
@property (strong, nonatomic) NSTimer* syncTimer;
@property (strong, nonatomic) NSNumber* syncInterval;
@property (strong, nonatomic) NSURL* baseURL;

@property (copy, nonatomic) void (^RKFailureBlock)(RKObjectRequestOperation*, NSError*);

@end

@implementation SERestClient


/**
 *  Create instance of our singleton and setup networking.
 *
 *  @return instance of SERestClient
 */
+ (SERestClient*) instance {

    static SERestClient* _instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _instance = [[[self class] alloc] init];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"values" ofType:@"plist"]];
        [_instance setBaseURL:[NSURL URLWithString:[dictionary valueForKeyPath:@"APIUrl"]]];
        [_instance setSyncInterval:[dictionary valueForKeyPath:@"SyncInterval"]];
        
        if (!_instance.baseURL) {
            [[[UIAlertView alloc] initWithTitle:@"API Base URL"
                                       message:@"Base URL in values.plist file is incorrect, please check it's value."
                                      delegate:nil
                             cancelButtonTitle:@"Close"
                              otherButtonTitles:nil] show];
        }
        
        if(!_instance.syncInterval) {
            [[[UIAlertView alloc] initWithTitle:@"Sync Interval"
                                        message:@"Sync Interval in values.plist file is incorrect, please check it's value. Data sync loop will be disabled."
                                       delegate:nil
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:nil] show];
        }
        
        [_instance restKitSetup];
        [[_instance syncTimer] fire];
    });
    return _instance;
}

/**
 *  Invalidates sync timer before destroing an object.
 */
- (void) dealloc {
    [self.syncTimer invalidate];
}

/**
 *  Setup RestKit Object Manager. BaseURL, cacheing, response and request descriptors, routes.
 */
- (void) restKitSetup {
    
    NSError *error = nil;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"]];
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"database.sqlite"];
    
    [[NSFileManager defaultManager] removeItemAtPath:storePath
                                               error:&error];
    if(error != nil) {
        NSLog(@"%@", error);
        error = nil;
    }
    
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath
                                                                     fromSeedDatabaseAtPath:nil
                                                                          withConfiguration:nil
                                                                                    options:nil
                                                                                      error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    [managedObjectStore createManagedObjectContexts];
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    self.managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
    
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:self.baseURL ? self.baseURL : [NSURL URLWithString:@""]];
    [objectManager.HTTPClient setDefaultHeader:@"Content-Type"
                                         value:@"application/x-www-form-urlencoded"];
    objectManager.managedObjectStore = managedObjectStore;
    [RKObjectManager setSharedManager:objectManager];
    
    [self setupResponseMapping];
    
//    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace); // set all logs to trace,
    self.apiErrorWasDisplayed = NO;
    
    __block SERestClient* weakSelf = self;
    self.RKFailureBlock = ^(RKObjectRequestOperation *operation, NSError *error) {
        
        if(!([error.domain isEqualToString:NSURLErrorDomain] && error.code == -1009)) {
            [weakSelf performSelectorOnMainThread:@selector(showError)
                                   withObject:nil
                                waitUntilDone:NO];
        }
        
    };
}

/**
 *  Show API error only once per application run, as an effect of using apiErrorWasDisplayed property.
 */
- (void) showError {
    
    if(!self.apiErrorWasDisplayed) {
        self.apiErrorWasDisplayed = YES;
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"API server is not responding, or base url is incorrect."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
}

/**
 *  Setup RestKit responses mapping for all kind of objects used in application.
 */
- (void) setupResponseMapping {
    RKEntityMapping* jobsMapping = [SEJob responseMappingForManagedObjectStore:[[RKObjectManager sharedManager] managedObjectStore]];
    RKEntityMapping* clientsMapping = [SEClient responseMappingForManagedObjectStore:[[RKObjectManager sharedManager] managedObjectStore]];
    RKEntityMapping* productsMapping = [SEProduct responseMappingForManagedObjectStore:[[RKObjectManager sharedManager] managedObjectStore]];
    RKEntityMapping* paymentsMapping = [SEPayment responseMappingForManagedObjectStore:[[RKObjectManager sharedManager] managedObjectStore]];
    
    RKResponseDescriptor* jobsListResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:jobsMapping
                                                                                                    method:RKRequestMethodGET
                                                                                               pathPattern:@"jobs"
                                                                                                   keyPath:@"jobs"
                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor* clientsListResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:clientsMapping
                                                                                                    method:RKRequestMethodGET
                                                                                               pathPattern:@"clients"
                                                                                                   keyPath:@"clients"
                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor* productsListResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productsMapping
                                                                                                    method:RKRequestMethodGET
                                                                                               pathPattern:@"parts"
                                                                                                   keyPath:@"parts"
                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor* paymentsListResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:paymentsMapping
                                                                                                    method:RKRequestMethodGET
                                                                                               pathPattern:@"payments"
                                                                                                   keyPath:@"payments"
                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:jobsListResponseDescriptor];
    [[RKObjectManager sharedManager] addResponseDescriptor:clientsListResponseDescriptor];
    [[RKObjectManager sharedManager] addResponseDescriptor:productsListResponseDescriptor];
    [[RKObjectManager sharedManager] addResponseDescriptor:paymentsListResponseDescriptor];
}

- (void) refreshJobsList {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"jobs"
                                           parameters:nil
                                              success:nil
                                              failure:self.RKFailureBlock];
}

- (void) refreshClientsList {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"clients"
                                           parameters:nil
                                              success:nil
                                              failure:self.RKFailureBlock];
}

- (void) refreshPaymentsList {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"payments"
                                           parameters:nil
                                              success:nil
                                              failure:self.RKFailureBlock];
}

- (void) refreshPartsList {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"parts"
                                           parameters:nil
                                              success:nil
                                              failure:self.RKFailureBlock];
}

/**
 *  This time is used to run database sync every [time interval from plist] seconds.
 *
 *  @return NSTimer object used for firing update;
 */
-(NSTimer *)syncTimer {
    if(!_syncTimer && _syncInterval.integerValue) {
        _syncTimer = [NSTimer timerWithTimeInterval:self.syncInterval.doubleValue
                                             target:self
                                           selector:@selector(performDataSync:)
                                           userInfo:nil
                                            repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_syncTimer
                                  forMode:NSRunLoopCommonModes];
    }
    return _syncTimer;
}

/**
 *  Action called by syncTimer. Starts running all sync methods in a MainThred.
 *
 *  @param timer NSTimer class object that called this method (sender).
 */
- (void) performDataSync: (NSTimer*) timer {
    NSLog(@"Data sync will occur now...");
    [self performSelectorOnMainThread:@selector(performDataSync)
                           withObject:nil
                        waitUntilDone:NO];
}

/**
 *  Runs all methods for syncing data,
 */
- (void) performDataSync {
    [[SERestClient instance] refreshJobsList];
    [[SERestClient instance] refreshClientsList];
    [[SERestClient instance] refreshPartsList];
    [[SERestClient instance] refreshPaymentsList];
}

@end
