//
//  AMBestDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/24/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMBestDBManager.h"
#import "AMDBBest.h"

@implementation AMBestDBManager
#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBBest";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMBest * best = (AMBest *)object;
    AMDBBest * dbBest = (AMDBBest *)dbObject;
    
    dbBest.point1 = best.point1;
    dbBest.point2 = best.point2;
    dbBest.point3 = best.point3;
    dbBest.woID = best.woID;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMBest * best = [[AMBest alloc] init];
    AMDBBest * dbBest = (AMDBBest *)dbObject;
    
    best.point1 = dbBest.point1;
    best.point2 = dbBest.point2;
    best.point3 = dbBest.point3;
    best.woID = dbBest.woID;
    
    return best;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMBest * best = (AMBest *)data;
    
    return [NSPredicate predicateWithFormat:@"woID = %@",best.woID];
}

#pragma mark - Methods
+ (AMBestDBManager *)sharedInstance
{
    static AMBestDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMBestDBManager alloc] init];
    });
    
    return sharedInstance;
    
}

@end
