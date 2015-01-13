//
//  AMFilterDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMFilterDBManager.h"
#import "AMDBFilter.h"

@implementation AMFilterDBManager

#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBFilter";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMFilter * filter = (AMFilter *)object;
    AMDBFilter * dbFilter = (AMDBFilter *)dbObject;
    
    dbFilter.posID = filter.posID;
    dbFilter.filterID = filter.filterID;
    dbFilter.filterName = filter.filterName;
    dbFilter.price = filter.price;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMFilter * filter = [[AMFilter alloc] init];
    AMDBFilter * dbFilter = (AMDBFilter *)dbObject;
    
    filter.posID = dbFilter.posID;
    filter.filterID = dbFilter.filterID;
    filter.filterName = dbFilter.filterName;
    filter.price = dbFilter.price;
    
    return filter;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMFilter * filter = (AMFilter *)data;
    
    return [NSPredicate predicateWithFormat:@"filterID = %@",filter.filterID];
}

#pragma mark - Methods
+ (AMFilterDBManager *)sharedInstance
{
    static AMFilterDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMFilterDBManager alloc] init];
    });
    
    return sharedInstance;
    
}

@end
