//
//  AMAssetRequestDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 6/11/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAssetRequestDBManager.h"
#import "AMAssetRequest.h"
#import "AMDBAssetRequest.h"

@implementation AMAssetRequestDBManager

#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBAssetRequest";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMAssetRequest * assetRequest = (AMAssetRequest *)object;
    AMDBAssetRequest * dbAssetRequest = (AMDBAssetRequest *)dbObject;
    
    dbAssetRequest.requestID = assetRequest.requestID;
    dbAssetRequest.assetID = assetRequest.assetID;
    dbAssetRequest.locationID = assetRequest.locationID;
    dbAssetRequest.posID = assetRequest.posID;
    dbAssetRequest.machineNumber = assetRequest.machineNumber;
    dbAssetRequest.serialNumber = assetRequest.serialNumber;
    dbAssetRequest.updatedMNumber = assetRequest.updatedMNumber;
    dbAssetRequest.updatedSNumber = assetRequest.updatedSNumber;
    dbAssetRequest.createdBy = assetRequest.createdBy;
    dbAssetRequest.createdDate = assetRequest.createdDate;
    dbAssetRequest.woID = assetRequest.woID;
    dbAssetRequest.machineType = assetRequest.machineType;
    dbAssetRequest.verifiedDate = assetRequest.verifiedDate;
    dbAssetRequest.verifyNotes = assetRequest.verifyNotes;
    dbAssetRequest.status = assetRequest.status;
    dbAssetRequest.statusID = assetRequest.statusID;
    dbAssetRequest.moveToWarehouse = assetRequest.moveToWarehouse;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMAssetRequest * assetRequest = [[AMAssetRequest alloc] init];
    AMDBAssetRequest * dbAssetRequest = (AMDBAssetRequest *)dbObject;
    
    assetRequest.requestID = dbAssetRequest.requestID;
    assetRequest.assetID = dbAssetRequest.assetID;
    assetRequest.locationID = dbAssetRequest.locationID;
    assetRequest.posID = dbAssetRequest.posID;
    assetRequest.machineNumber = dbAssetRequest.machineNumber;
    assetRequest.serialNumber = dbAssetRequest.serialNumber;
    assetRequest.updatedMNumber = dbAssetRequest.updatedMNumber;
    assetRequest.updatedSNumber = dbAssetRequest.updatedSNumber;
    assetRequest.createdBy = dbAssetRequest.createdBy;
    assetRequest.createdDate = dbAssetRequest.createdDate;
    assetRequest.woID = dbAssetRequest.woID;
    assetRequest.machineType = dbAssetRequest.machineType;
    assetRequest.verifiedDate = dbAssetRequest.verifiedDate;
    assetRequest.verifyNotes = dbAssetRequest.verifyNotes;
    assetRequest.status = dbAssetRequest.status;
    assetRequest.statusID = dbAssetRequest.statusID;
    assetRequest.moveToWarehouse = dbAssetRequest.moveToWarehouse;
    return assetRequest;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMAssetRequest * assetRequest = (AMAssetRequest *)data;
    
    return [NSPredicate predicateWithFormat:@"requestID = %@",assetRequest.requestID];
}

- (void)replaceFields:(NSDictionary *)idMaps toDBObject:(id)dbObject
{
    AMDBAssetRequest * assetReq = (AMDBAssetRequest *)dbObject;
    
    if ([idMaps objectForKey:assetReq.locationID]) {
        assetReq.locationID = [idMaps objectForKey:assetReq.locationID];
    }
    else if ([idMaps objectForKey:assetReq.requestID]) {
        assetReq.requestID = [idMaps objectForKey:assetReq.requestID];
        assetReq.createdBy = nil;
    }
}
#pragma mark - Methods
+ (AMAssetRequestDBManager *)sharedInstance
{
    static AMAssetRequestDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMAssetRequestDBManager alloc] init];
    });
    
    return sharedInstance;
    
}


@end
