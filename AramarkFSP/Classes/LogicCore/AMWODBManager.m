//
//  AMWODBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/10/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMWODBManager.h"
#import "AMEvent.h"
#import "AMEventDBManager.h"
#import "AMPoSDBManager.h"

@interface AMWODBManager ()
{
    NSString * _selfId;
}

@end
@implementation AMWODBManager

@synthesize selfId = _selfId;

#pragma mark - Transfer

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBWorkOrder";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMWorkOrder * WO = (AMWorkOrder *)object;
    AMDBWorkOrder * dbWO = (AMDBWorkOrder *)dbObject;
    
    dbWO.accessoriesRequired = WO.accessoriesRequired;
    dbWO.actualTimeEnd = WO.actualTimeEnd;
    dbWO.actualTimeStart = WO.actualTimeStart;
    dbWO.assetID = WO.assetID;
    dbWO.callAhead = WO.callAhead;
    dbWO.caseID = WO.caseID;
    dbWO.complaintCode = WO.complaintCode;
    dbWO.contact = WO.contact;
    dbWO.createdBy = WO.createdBy;
    dbWO.createdDate = WO.createdDate;
    dbWO.estimatedTimeEnd = WO.estimatedTimeEnd;
    dbWO.estimatedTimeStart = WO.estimatedTimeStart;
    dbWO.filterCount = WO.filterCount;
    dbWO.filterType = WO.filterType;
    dbWO.fromLocation = WO.fromLocation;
    dbWO.lastModifiedBy = WO.lastModifiedBy;
    dbWO.lastModifiedDate = WO.lastModifiedDate;
    dbWO.latitude = WO.latitude;
    dbWO.longitude = WO.longitude;
    dbWO.machineType = WO.machineType;
    dbWO.notes = WO.notes;
    dbWO.ownerID = WO.ownerID;
    dbWO.parkingDetail = WO.parkingDetail;
    dbWO.posID = WO.posID;
    dbWO.preferrTimeFrom = WO.preferrTimeFrom;
    dbWO.preferrTimeTo = WO.preferrTimeTo;
    dbWO.priority = WO.priority;
    dbWO.repairCode = WO.repairCode;
    dbWO.status = WO.status;
    dbWO.toLocationID = WO.toLocationID;
    dbWO.vendKey = WO.vendKey;
    dbWO.warranty = WO.warranty;
    dbWO.woID = WO.woID;
    dbWO.woNumber = WO.woNumber;
    dbWO.workLocation = WO.workLocation;
    dbWO.woType = WO.woType;
    dbWO.accountID = WO.accountID;
    dbWO.accountName = WO.accountName;
    dbWO.userID = WO.userID;
    dbWO.age = WO.age;
    dbWO.inspectedTubing = WO.inspectedTubing;
    dbWO.leftInOrderlyManner = WO.leftInOrderlyManner;
    dbWO.testedAll = WO.testedAll;
    dbWO.createdByName = WO.createdByName;
    dbWO.ownerName = WO.ownerName;
    dbWO.toWorkLocation = WO.toWorkLocation;
    dbWO.caseDescription = WO.caseDescription;
    dbWO.recordTypeID = WO.recordTypeID;
    dbWO.contactID = WO.contactID;
    dbWO.subject = WO.subject;
    dbWO.recordTypeName = WO.recordTypeName;
    dbWO.workOrderDescription = WO.workOrderDescription;
    dbWO.caseNumber = WO.caseNumber;
    dbWO.machineTypeName = WO.machineTypeName;
    dbWO.filterTypeName = WO.filterTypeName;
    dbWO.toLocationName = WO.toLocationName;
    dbWO.workOrderCheckinTime = WO.workOrderCheckinTime;
    dbWO.workOrderCheckoutTime = WO.workOrderCheckoutTime;
    dbWO.productName = WO.productName;
    dbWO.estimatedWorkDate = WO.estimatedDate;
    dbWO.lastServiceDate = WO.lastServiceDate;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMWorkOrder * WO = [[AMWorkOrder alloc] init];
    AMDBWorkOrder * dbWO = (AMDBWorkOrder *)dbObject;
    
    WO.accessoriesRequired = dbWO.accessoriesRequired;
    WO.actualTimeEnd = dbWO.actualTimeEnd;
    WO.actualTimeStart = dbWO.actualTimeStart;
    WO.assetID = dbWO.assetID;
    WO.callAhead = dbWO.callAhead;
    WO.caseID = dbWO.caseID;
    WO.complaintCode = dbWO.complaintCode;
    WO.contact = dbWO.contact;
    WO.createdBy = dbWO.createdBy;
    WO.createdDate = dbWO.createdDate;
    WO.estimatedTimeEnd = dbWO.estimatedTimeEnd;
    WO.estimatedTimeStart = dbWO.estimatedTimeStart;
    WO.filterCount = dbWO.filterCount;
    WO.filterType = dbWO.filterType;
    WO.fromLocation = dbWO.fromLocation;
    WO.lastModifiedBy = dbWO.lastModifiedBy;
    WO.lastModifiedDate = dbWO.lastModifiedDate;
    WO.latitude = dbWO.latitude;
    WO.longitude = dbWO.longitude;
    WO.machineType = dbWO.machineType;
    WO.notes = dbWO.notes;
    WO.ownerID = dbWO.ownerID;
    WO.parkingDetail = dbWO.parkingDetail;
    WO.posID = dbWO.posID;
    WO.preferrTimeFrom = dbWO.preferrTimeFrom;
    WO.preferrTimeTo = dbWO.preferrTimeTo;
    WO.priority = dbWO.priority;
    WO.repairCode = dbWO.repairCode;
    WO.status = dbWO.status;
    WO.toLocationID = dbWO.toLocationID;
    WO.vendKey = dbWO.vendKey;
    WO.warranty = dbWO.warranty;
    WO.woID = dbWO.woID;
    WO.woNumber = dbWO.woNumber;
    WO.workLocation = dbWO.workLocation;
    WO.woType = dbWO.woType;
    WO.accountID = dbWO.accountID;
    WO.accountName = dbWO.accountName;
    WO.userID = dbWO.userID;
    WO.age = dbWO.age;
    WO.inspectedTubing = dbWO.inspectedTubing;
    WO.leftInOrderlyManner = dbWO.leftInOrderlyManner;
    WO.testedAll = dbWO.testedAll;
    WO.createdByName = dbWO.createdByName;
    WO.ownerName = dbWO.ownerName;
    WO.toWorkLocation = dbWO.toWorkLocation;
    WO.caseDescription = dbWO.caseDescription;
    WO.recordTypeID = dbWO.recordTypeID;
    WO.contactID = dbWO.contactID;
    WO.subject = dbWO.subject;
    WO.recordTypeName = dbWO.recordTypeName;
    WO.workOrderDescription = dbWO.workOrderDescription;
    WO.caseNumber = dbWO.caseNumber;
    WO.machineTypeName = dbWO.machineTypeName;
    WO.filterTypeName = dbWO.filterTypeName;
    WO.toLocationName = dbWO.toLocationName;
    WO.workOrderCheckinTime = dbWO.workOrderCheckinTime;
    WO.workOrderCheckoutTime = dbWO.workOrderCheckoutTime;
    WO.productName = dbWO.productName;
    WO.estimatedDate = dbWO.estimatedWorkDate;
    WO.lastServiceDate = dbWO.lastServiceDate;
    
    return WO;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    AMDBWorkOrder * dbWO = (AMDBWorkOrder *)dbData;
    if (![dbWO.status isEqualToLocalizedString:@"Closed"]) {
        [self transferObject:data toDBObject:dbData];
    }
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMWorkOrder * wo = (AMWorkOrder *)data;
    
    return [NSPredicate predicateWithFormat:@"woID = %@",wo.woID];
}

- (void)replaceFields:(NSString *)field withValue:(id)value toDBObject:(id)dbObject
{
    AMDBWorkOrder * dbWO = (AMDBWorkOrder *)dbObject;
    if ([field isEqualToString:@"lastModifiedBy"]) {
        dbWO.lastModifiedBy = value;
    }
    else if ([field isEqualToString:@"createdBy"]) {
        dbWO.createdBy = value;
    }

}
#pragma mark - Methods

+ (AMWODBManager *)sharedInstance
{
    static AMWODBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMWODBManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)handleEventList:(AMWorkOrder *)wo withDB:(NSManagedObjectContext *)context checkExist:(BOOL)check
{
    NSArray *currentEventList = [[AMDBManager sharedInstance] getEventListByWOID:wo.woID];
    NSArray *eventIDs = [currentEventList valueForKeyExcludingNull:@"eventID"];
    if (eventIDs.count) {
        NSPredicate * filter = [NSPredicate predicateWithFormat:@"eventID IN %@",eventIDs];
        [[AMEventDBManager sharedInstance] memClearDataByFilter:filter fromDB:context];
    }
    
    if (wo.eventList) {
        for (AMEvent * event in wo.eventList) {
            if ([event.ownerID isEqualToString:_selfId]) {
                wo.estimatedTimeStart = event.estimatedTimeStart;
                wo.estimatedTimeEnd = event.estimatedTimeEnd;
                wo.actualTimeStart = event.actualTimeStart;
                wo.actualTimeEnd = event.actualTimeEnd;
                wo.userID = _selfId;
                break;
            }
        }
        [[AMEventDBManager sharedInstance] memSaveDataList:wo.eventList ToDB:context checkExist:check];
    }
}

- (void)memSaveDataList:(NSArray *)dataList ToDB:(NSManagedObjectContext *)context checkExist:(BOOL)check
{
    [context performBlockAndWait:^{
        
        NSEntityDescription * entDesp = [NSEntityDescription entityForName:_entityName inManagedObjectContext:context];
        NSError * error = nil;
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
        
        fetchRequest.entity = entDesp;
        
        for (AMWorkOrder * wo in dataList) {
            [self handleEventList:wo withDB:context checkExist:check];
            
            if (check) {
                fetchRequest.predicate = [self getCheckExistFilter:wo];
                NSArray * fetchItem = [NSArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
                if (fetchItem.count > 0) {
                    [self handleObject:wo existDBObject:[fetchItem objectAtIndex:0]];
                }
                else {
                    AMDBWorkOrder * dbWO = (AMDBWorkOrder *)[NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:context];
                    
                    [self transferObject:wo toDBObject:dbWO];
                }
            }
            else {
                AMDBWorkOrder * dbWO = (AMDBWorkOrder *)[NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:context];
                
                [self transferObject:wo toDBObject:dbWO];
            }
            
        }
    }];
}

- (NSArray *)getDataListByFilter:(NSPredicate *)filter fromDB:(NSManagedObjectContext *)context
{
    __block NSArray *array;
    [context performBlockAndWait:^{
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSError * error = nil;
        
        [fetch setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:context]];
        [fetch setPredicate:filter];
        
        /*NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
         initWithKey:@"sendTime"
         ascending:NO];
         NSArray *sortDescriptors = [[NSArray alloc]
         initWithObjects:sortDescriptor, nil];
         
         [fetch setSortDescriptors:sortDescriptors];*/
        
        NSArray *dbList = [context executeFetchRequest:fetch error:&error];
        NSMutableArray * resultArray = [NSMutableArray array];
        
        for (AMDBWorkOrder * dbWO in dbList) {
            @autoreleasepool {
                AMWorkOrder * workorder = [self transferDBObjectToObject:dbWO];
                
                NSPredicate * eventfilter = [NSPredicate predicateWithFormat:@"woID = %@", workorder.woID];
                workorder.eventList = [[AMEventDBManager sharedInstance] getDataListByFilter:eventfilter fromDB:context];
                [resultArray addObject:workorder];
            }
        }
        array = resultArray;
    }];

    return array;
}

- (NSArray *)getWorkOrderWithPOSByFilter:(NSPredicate *)filter sortArray:(NSArray *)sortArray fromDB:(NSManagedObjectContext *)context
{
    __block NSArray *array;
    [context performBlockAndWait:^{
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSError * error = nil;
        
        [fetch setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:context]];
        [fetch setPredicate:filter];
        
        if (sortArray) {
            [fetch setSortDescriptors:sortArray];
        }
        
        NSArray *dbList = [context executeFetchRequest:fetch error:&error];
        NSMutableArray * resultArray = [NSMutableArray array];
        for (AMDBWorkOrder *dbWO in dbList) {
            AMWorkOrder * workorder = [self transferDBObjectToObject:dbWO];
            NSPredicate *posFilter = [NSPredicate predicateWithFormat:@"posID = %@", workorder.posID];
            AMPoS *pos = [[AMPoSDBManager sharedInstance] getDataByFilter:posFilter fromDB:context];
            if (pos) {
                workorder.woPoS = pos;
            }
            [resultArray addObject:workorder];
        }
        
        array = resultArray;
    }];
    
    return array;
}

- (id)getDataByFilter:(NSPredicate *)filter fromDB:(NSManagedObjectContext *)context
{
    __block AMWorkOrder * workorder = nil;
    
    [context performBlockAndWait:^{
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSError * error = nil;
        
        [fetch setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:context]];
        [fetch setPredicate:filter];
        
        NSArray *dbList = [context executeFetchRequest:fetch error:&error];
        if (dbList.count) {
            workorder = [self transferDBObjectToObject:[dbList objectAtIndex:0]];
            NSPredicate * eventfilter = [NSPredicate predicateWithFormat:@"woID = %@", workorder.woID];
            
            workorder.eventList = [[AMEventDBManager sharedInstance] getDataListByFilter:eventfilter fromDB:context];
        }
    }];
    
    return workorder;

}

- (void)replaceFields:(NSDictionary *)idMaps toDBObject:(id)dbObject
{
    AMDBWorkOrder * workOrder = (AMDBWorkOrder *)dbObject;
    
    if ([idMaps objectForKey:workOrder.toLocationID]) {
        workOrder.toLocationID = [idMaps objectForKey:workOrder.toLocationID];
    }
}

@end




