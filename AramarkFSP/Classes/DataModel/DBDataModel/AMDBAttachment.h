//
//  AMDBAttachment.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/28/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBAttachment : NSManagedObject

@property (nonatomic, retain) NSNumber * bodyLength;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSNumber * dataStatus;
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) NSString * fakeID;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * localURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * remoteURL;
@property (nonatomic, retain) NSString * createdById;

@end
