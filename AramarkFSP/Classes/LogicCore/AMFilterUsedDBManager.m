//
//  AMFilterUsedDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/24/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMFilterUsedDBManager.h"
#import "AMDBFilterUsed.h"

@implementation AMFilterUsedDBManager
#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBFilterUsed";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMFilterUsed * filter = (AMFilterUsed *)object;
    AMDBFilterUsed * dbFilter = (AMDBFilterUsed *)dbObject;
    
    dbFilter.woID = filter.woID;
    dbFilter.invoiceID = filter.invoiceID;
    dbFilter.filterID = filter.filterID;
    dbFilter.fcount = filter.fcount;
    dbFilter.fuID = filter.fuID;
    dbFilter.createdBy = filter.createdBy;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMFilterUsed * filter = [[AMFilterUsed alloc] init];
    AMDBFilterUsed * dbFilter = (AMDBFilterUsed *)dbObject;
    
    filter.woID = dbFilter.woID;
    filter.invoiceID = dbFilter.invoiceID;
    filter.filterID = dbFilter.filterID;
    filter.fcount = dbFilter.fcount;
    filter.fuID = dbFilter.fuID;
    filter.createdBy = dbFilter.createdBy;
    
    return filter;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMFilterUsed * filter = (AMFilterUsed *)data;
    
    return [NSPredicate predicateWithFormat:@"(invoiceID = %@) AND (filterID = %@)",filter.invoiceID,filter.filterID];
}

#pragma mark - Methods
+ (AMFilterUsedDBManager *)sharedInstance
{
    static AMFilterUsedDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMFilterUsedDBManager alloc] init];
    });
    
    return sharedInstance;
    
}

@end
