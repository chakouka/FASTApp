//
//  AMPartsUsedDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/24/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMPartsUsedDBManager.h"
#import "AMDBPartsUsed.h"

@implementation AMPartsUsedDBManager
#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBPartsUsed";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMPartsUsed * parts = (AMPartsUsed *)object;
    AMDBPartsUsed * dbParts = (AMDBPartsUsed *)dbObject;
    
    dbParts.woID = parts.woID;
    dbParts.invoiceID = parts.invoiceID;
    dbParts.pcount = parts.pcount;
    dbParts.partID = parts.partID;
    dbParts.puID = parts.puID;
    dbParts.createdBy = parts.createdBy;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMPartsUsed * parts = [[AMPartsUsed alloc] init];
    AMDBPartsUsed * dbParts = (AMDBPartsUsed *)dbObject;
    
    parts.woID = dbParts.woID;
    parts.invoiceID = dbParts.invoiceID;
    parts.pcount = dbParts.pcount;
    parts.partID = dbParts.partID;
    parts.puID = dbParts.puID;
    parts.createdBy = dbParts.createdBy;
    
    return parts;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMPartsUsed * parts = (AMPartsUsed *)data;
    
    return [NSPredicate predicateWithFormat:@"(invoiceID = %@) AND (partID = %@)",parts.invoiceID,parts.partID];
}

#pragma mark - Methods
+ (AMPartsUsedDBManager *)sharedInstance
{
    static AMPartsUsedDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMPartsUsedDBManager alloc] init];
    });
    
    return sharedInstance;
    
}

@end
