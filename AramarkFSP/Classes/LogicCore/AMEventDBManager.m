//
//  AMEventDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMEventDBManager.h"
#import "AMDBEvent.h"

@implementation AMEventDBManager

#pragma mark - Transfer
- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBEvent";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMEvent * event = (AMEvent *)object;
    AMDBEvent * dbEvent = (AMDBEvent *)dbObject;
    
    dbEvent.eventID = event.eventID;
    dbEvent.ownerID = event.ownerID;
    dbEvent.woID = event.woID;
    dbEvent.estimatedTimeStart = event.estimatedTimeStart;
    dbEvent.estimatedTimeEnd = event.estimatedTimeEnd;
    dbEvent.actualTimeStart = event.actualTimeStart;
    dbEvent.actualTimeEnd = event.actualTimeEnd;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMEvent * event = [[AMEvent alloc] init];
    AMDBEvent * dbEvent = (AMDBEvent *)dbObject;
    
    event.eventID = dbEvent.eventID;
    event.ownerID = dbEvent.ownerID;
    event.woID = dbEvent.woID;
    event.estimatedTimeStart = dbEvent.estimatedTimeStart;
    event.estimatedTimeEnd = dbEvent.estimatedTimeEnd;
    event.actualTimeStart = dbEvent.actualTimeStart;
    event.actualTimeEnd = dbEvent.actualTimeEnd;
    
    return event;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMEvent * event = (AMEvent *)data;
    
    return [NSPredicate predicateWithFormat:@"eventID = %@",event.eventID];
}

#pragma mark - Methods

+ (AMEventDBManager *)sharedInstance
{
    static AMEventDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMEventDBManager alloc] init];
    });
    
    return sharedInstance;
}

@end
