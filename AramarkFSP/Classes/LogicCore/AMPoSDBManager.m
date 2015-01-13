//
//  AMPoSDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMPoSDBManager.h"
#import "AMDBPoS.h"

@implementation AMPoSDBManager
#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBPoS";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMPoS * pos = (AMPoS *)object;
    AMDBPoS * dbPoS = (AMDBPoS *)dbObject;
    
    dbPoS.bdm = pos.bdm;
    dbPoS.driverName = pos.driverName;
    dbPoS.name = pos.name;
    dbPoS.posID = pos.posID;
    dbPoS.routeNumber = pos.routeNumber;
    dbPoS.segment = pos.segment;
    dbPoS.parkingDetail = pos.parkingDetail;
    dbPoS.nam = pos.nam;
    dbPoS.kam = pos.kam;
    dbPoS.meiNumber = pos.meiNumber;
    dbPoS.naBillingType = pos.naBillingType;
    dbPoS.routeLookupID = pos.routeLookupID;
    dbPoS.routeLookupName = pos.routeLookupName;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMPoS * pos = [[AMPoS alloc] init];
    AMDBPoS * dbPoS = (AMDBPoS *)dbObject;
    
    pos.bdm = dbPoS.bdm;
    pos.driverName = dbPoS.driverName;
    pos.name = dbPoS.name;
    pos.posID = dbPoS.posID;
    pos.routeNumber = dbPoS.routeNumber;
    pos.segment = dbPoS.segment;
    pos.parkingDetail = dbPoS.parkingDetail;
    pos.nam = dbPoS.nam;
    pos.kam = dbPoS.kam;
    pos.meiNumber = dbPoS.meiNumber;
    pos.naBillingType = dbPoS.naBillingType;
    pos.routeLookupID = dbPoS.routeLookupID;
    pos.routeLookupName = dbPoS.routeLookupName;
    
    return pos;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMPoS * pos = (AMPoS *)data;
    
    return [NSPredicate predicateWithFormat:@"posID = %@",pos.posID];
}

- (void)replaceFields:(NSString *)field withValue:(id)value toDBObject:(id)dbObject
{
    AMDBPoS * dbPoS = (AMDBPoS *)dbObject;
    if ([field isEqualToString:@"lastModifiedBy"]) {
        dbPoS.lastModifiedBy = value;
    }
    
}

#pragma mark - Methods
+ (AMPoSDBManager *)sharedInstance
{
    static AMPoSDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMPoSDBManager alloc] init];
    });
    
    return sharedInstance;
    
}

@end
