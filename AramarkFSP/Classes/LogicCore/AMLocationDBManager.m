//
//  AMLocationDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMLocationDBManager.h"
#import "AMDBLocation.h"

@implementation AMLocationDBManager
#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBLocation";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMLocation * location = (AMLocation *)object;
    AMDBLocation * dbLocation = (AMDBLocation *)dbObject;
    
    dbLocation.name = location.name;
    dbLocation.accountID = location.accountID;
//    if (!dbLocation.locationID.length) {
//        dbLocation.locationID = location.locationID;
//        dbLocation.createdBy = location.createdBy;
//    }
    dbLocation.locationID = location.locationID;
    dbLocation.createdDate = location.createdDate;
    dbLocation.lastModifiedDate = location.lastModifiedDate;
    dbLocation.location = location.location;
    dbLocation.country = location.country;
    dbLocation.state = location.state;
    dbLocation.city = location.city;
    dbLocation.street = location.street;
//    if (!dbLocation.createdBy.length) {
//        dbLocation.lastModifiedBy = location.lastModifiedBy;
//    }
    dbLocation.userID = location.userID;
    dbLocation.addtionalNotes = location.addtionalNotes;
    dbLocation.badgeNeeded = location.badgeNeeded;
    dbLocation.cabinetHeight = location.cabinetHeight;
    dbLocation.dockAvailable = location.dockAvailable;
    dbLocation.doorsRemoved = location.doorsRemoved;
    dbLocation.doorwayWidth = location.doorwayWidth;
    dbLocation.electricOutlet = location.electricOutlet;
    dbLocation.electricity3ft = location.electricity3ft;
    dbLocation.elevatorStairs = location.elevatorStairs;
    dbLocation.elevatorSize = location.elevatorSize;
    dbLocation.freightElevator = location.freightElevator;
    dbLocation.personalProtection = location.personalProtection;
    dbLocation.electricalInPlace = location.electricalInPlace;
    dbLocation.visitByServiceDep = location.visitByServiceDep;
    dbLocation.roomMeasurement = location.roomMeasurement;
    dbLocation.siteLevel = location.siteLevel;
    dbLocation.siteSurveyDate = location.siteSurveyDate;
    dbLocation.specialNotes = location.specialNotes;
    dbLocation.safetyTraining = location.safetyTraining;
    dbLocation.typeFlooring = location.typeFlooring;
    dbLocation.waterSource = location.waterSource;
    
    if (!dbLocation.fakeID.length) {
        dbLocation.fakeID = location.fakeID;  // do not allow override once created
    }
    dbLocation.dataStatus = location.dataStatus;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMLocation * location = [[AMLocation alloc] init];
    AMDBLocation * dbLocation = (AMDBLocation *)dbObject;
    
    location.name = dbLocation.name;
    location.accountID = dbLocation.accountID;
    location.locationID = dbLocation.locationID;
    location.createdBy = dbLocation.createdBy;
    location.createdDate = dbLocation.createdDate;
    location.lastModifiedDate = dbLocation.lastModifiedDate;
    location.location = dbLocation.location;
    location.country = dbLocation.country;
    location.state = dbLocation.state;
    location.city = dbLocation.city;
    location.street = dbLocation.street;
    location.lastModifiedBy = dbLocation.lastModifiedBy;
    location.userID = dbLocation.userID;
    location.addtionalNotes = dbLocation.addtionalNotes;
    location.badgeNeeded = dbLocation.badgeNeeded;
    location.cabinetHeight = dbLocation.cabinetHeight;
    location.dockAvailable = dbLocation.dockAvailable;
    location.doorsRemoved = dbLocation.doorsRemoved;
    location.doorwayWidth = dbLocation.doorwayWidth;
    location.electricOutlet = dbLocation.electricOutlet;
    location.electricity3ft = dbLocation.electricity3ft;
    location.elevatorStairs = dbLocation.elevatorStairs;
    location.elevatorSize = dbLocation.elevatorSize;
    location.freightElevator = dbLocation.freightElevator;
    location.personalProtection = dbLocation.personalProtection;
    location.electricalInPlace = dbLocation.electricalInPlace;
    location.visitByServiceDep = dbLocation.visitByServiceDep;
    location.roomMeasurement = dbLocation.roomMeasurement;
    location.siteLevel = dbLocation.siteLevel;
    location.siteSurveyDate = dbLocation.siteSurveyDate;
    location.specialNotes = dbLocation.specialNotes;
    location.safetyTraining = dbLocation.safetyTraining;
    location.typeFlooring = dbLocation.typeFlooring;
    location.waterSource = dbLocation.waterSource;
    location.fakeID = dbLocation.fakeID;
    location.dataStatus = dbLocation.dataStatus;
    
    return location;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMLocation * location = (AMLocation *)data;
    
    if (location.fakeID) {
        return [NSPredicate predicateWithFormat:@"locationID = %@ OR fakeID = %@",location.locationID, location.fakeID];
    } else {
        return [NSPredicate predicateWithFormat:@"locationID = %@",location.locationID];
    }
}

- (void)replaceFields:(NSDictionary *)idMaps toDBObject:(id)dbObject
{
    AMDBLocation * location = (AMDBLocation *)dbObject;
    
    if ([idMaps objectForKey:location.fakeID]) {
        location.locationID = [idMaps objectForKey:location.fakeID];
        location.createdBy = nil;
        location.dataStatus = @(EntityStatusSyncSuccess);
    } else {
        location.createdBy = nil;
        location.dataStatus = @(EntityStatusSyncFail);
    }
}

- (void)replaceFields:(NSString *)field withValue:(id)value toDBObject:(id)dbObject
{
    AMDBLocation * dbLocation = (AMDBLocation *)dbObject;
    if ([field isEqualToString:@"lastModifiedBy"]) {
        dbLocation.lastModifiedBy = value;
    }
}

#pragma mark - Methods
+ (AMLocationDBManager *)sharedInstance
{
    static AMLocationDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMLocationDBManager alloc] init];
    });
    
    return sharedInstance;
    
}

@end
