//
//  AMAssetDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAssetDBManager.h"
#import "AMDBAsset.h"

@implementation AMAssetDBManager
#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBAsset";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMAsset * asset = (AMAsset *)object;
    AMDBAsset * dbAsset = (AMDBAsset *)dbObject;
    
    dbAsset.assetID = asset.assetID;
    dbAsset.installDate = asset.installDate;
    dbAsset.lastModifiedBy = asset.lastModifiedBy;
    dbAsset.lastModifiedDate = asset.lastModifiedDate;
    dbAsset.lastVerifiedDate = asset.lastVerifiedDate;
    dbAsset.locationID = asset.locationID;
    dbAsset.machineNumber = asset.machineNumber;
    dbAsset.machineType = asset.machineType;
    dbAsset.nextPMDate = asset.nextPMDate;
    dbAsset.notes = asset.notes;
    dbAsset.posID = asset.posID;
    dbAsset.serialNumber = asset.serialNumber;
    dbAsset.userID = asset.userID;
    dbAsset.vendKey = asset.vendKey;
    dbAsset.productID = asset.productID;
    dbAsset.assetName = asset.assetName;
    dbAsset.verificationStatus = asset.verificationStatus;
    dbAsset.mSerialNumber = asset.mSerialNumber;
    dbAsset.mMachineNumber = asset.mMachineNumber;
    dbAsset.locationName = asset.locationName;
    dbAsset.productName = asset.productName;
    dbAsset.manufacturerWebsite = asset.manufacturerWebsite;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMAsset * asset = [[AMAsset alloc] init];
    AMDBAsset * dbAsset = (AMDBAsset *)dbObject;
    
    asset.assetID = dbAsset.assetID;
    asset.installDate = dbAsset.installDate;
    asset.lastModifiedBy = dbAsset.lastModifiedBy;
    asset.lastModifiedDate = dbAsset.lastModifiedDate;
    asset.lastVerifiedDate = dbAsset.lastVerifiedDate;
    asset.locationID = dbAsset.locationID;
    asset.machineNumber = dbAsset.machineNumber;
    asset.machineType = dbAsset.machineType;
    asset.nextPMDate = dbAsset.nextPMDate;
    asset.notes = dbAsset.notes;
    asset.posID = dbAsset.posID;
    asset.serialNumber = dbAsset.serialNumber;
    asset.userID = dbAsset.userID;
    asset.vendKey = dbAsset.vendKey;
    asset.productID = dbAsset.productID;
    asset.assetName = dbAsset.assetName;
    asset.verificationStatus = dbAsset.verificationStatus;
    asset.mSerialNumber = dbAsset.mSerialNumber;
    asset.mMachineNumber = dbAsset.mMachineNumber;
    asset.locationName = dbAsset.locationName;
    asset.productName = dbAsset.productName;
    asset.manufacturerWebsite = dbAsset.manufacturerWebsite;

    return asset;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMAsset * asset = (AMAsset *)data;
    
    if (asset.assetID) {
        if (asset.machineNumber) {
            if (asset.serialNumber) {
                return [NSPredicate predicateWithFormat:@"(assetID = %@) AND (machineNumber = %@) AND (serialNumber = %@)",asset.assetID,asset.machineNumber,asset.serialNumber];
            }
            else {
                return [NSPredicate predicateWithFormat:@"(assetID = %@) AND (machineNumber = %@)",asset.assetID,asset.machineNumber];
            }
        }
        else {
            if (asset.serialNumber) {
                return [NSPredicate predicateWithFormat:@"(assetID = %@) AND (serialNumber = %@)",asset.assetID,asset.serialNumber];
            }
            else {
                return [NSPredicate predicateWithFormat:@"(assetID = %@)",asset.assetID];
            }

        }
    }
    else {
        if (asset.machineNumber) {
            if (asset.serialNumber) {
                return [NSPredicate predicateWithFormat:@"(machineNumber = %@) AND (serialNumber = %@)",asset.machineNumber,asset.serialNumber];
            }
            else {
                return [NSPredicate predicateWithFormat:@"(machineNumber = %@)",asset.machineNumber];
            }
        }
        else {
            if (asset.serialNumber) {
                return [NSPredicate predicateWithFormat:@"(serialNumber = %@)",asset.assetID,asset.machineNumber,asset.serialNumber];
            }
            else {
                return [NSPredicate predicateWithFormat:@"(assetID = %@) AND (machineNumber = %@) AND (serialNumber = %@)",asset.assetID,asset.machineNumber,asset.serialNumber];
            }

        }

    }
    
}

- (void)replaceFields:(NSDictionary *)idMaps toDBObject:(id)dbObject
{
    AMDBAsset * asset = (AMDBAsset *)dbObject;
    
    if ([idMaps objectForKey:asset.locationID]) {
        asset.locationID = [idMaps objectForKey:asset.locationID];
    }
}

- (void)replaceFields:(NSString *)field withValue:(id)value toDBObject:(id)dbObject
{
    AMDBAsset * dbAsset = (AMDBAsset *)dbObject;
    if ([field isEqualToString:@"lastModifiedBy"]) {
        dbAsset.lastModifiedBy = value;
    }
    
}

#pragma mark - Methods
+ (AMAssetDBManager *)sharedInstance
{
    static AMAssetDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMAssetDBManager alloc] init];
    });
    
    return sharedInstance;
    
}

@end
