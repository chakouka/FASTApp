//
//  AMPartsDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMPartsDBManager.h"
#import "AMDBParts.h"

@implementation AMPartsDBManager
#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBParts";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMParts * parts = (AMParts *)object;
    AMDBParts * dbParts = (AMDBParts *)dbObject;
    
    dbParts.partID = parts.partID;
    dbParts.productID = parts.productID;
    dbParts.name = parts.name;
    dbParts.partDescription = parts.partDescription;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMParts * parts = [[AMParts alloc] init];
    AMDBParts * dbParts = (AMDBParts *)dbObject;
    
    parts.partID = dbParts.partID;
    parts.productID = dbParts.productID;
    parts.name = dbParts.name;
    parts.partDescription = dbParts.partDescription;
    
    return parts;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMParts * parts = (AMParts *)data;
    
    return [NSPredicate predicateWithFormat:@"partID = %@",parts.partID];
}

#pragma mark - Methods
+ (AMPartsDBManager *)sharedInstance
{
    static AMPartsDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMPartsDBManager alloc] init];
    });
    
    return sharedInstance;
    
}


@end
