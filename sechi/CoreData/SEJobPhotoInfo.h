//
//  SEJobPhotoInfo.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SEJob;

@interface SEJobPhotoInfo : NSManagedObject

/**
 *  Path of the file where it was saved on the device.
 */
@property (nonatomic, retain) NSString * filePath;

/**
 *  SEJob object which is an owner of this photo.
 */
@property (nonatomic, retain) SEJob *job;

@end
