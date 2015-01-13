//
//  AMObjectDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/18/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMObjectDBManager.h"
#import <CoreData/CoreData.h>

@implementation AMObjectDBManager

#pragma mark - Internal Methods

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    
}

- (id)transferDBObjectToObject:(id)dbObject
{
    return nil;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    return nil;
}

- (void)replaceFields:(NSDictionary *)idMaps toDBObject:(id)dbObject
{
    
}

- (void)replaceFields:(NSString *)field withValue:(id)value toDBObject:(id)dbObject
{
    
}
#pragma mark - Methods
- (void)memSaveDataList:(NSArray *)dataList ToDB:(NSManagedObjectContext *)context checkExist:(BOOL)check
{
    [context performBlockAndWait:^{
        
        NSEntityDescription * entDesp = [NSEntityDescription entityForName:_entityName inManagedObjectContext:context];
        NSError * error = nil;
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
        
        fetchRequest.entity = entDesp;
        
        for (id data in dataList) {
            
            if (check) {
                fetchRequest.predicate = [self getCheckExistFilter:data];
                NSArray * fetchItem = [NSArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
                if (fetchItem.count > 0) {
                    [self handleObject:data existDBObject:[fetchItem objectAtIndex:0]];
                }
                else {
                    id dbObject = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:context];
                    
                    [self transferObject:data toDBObject:dbObject];
                }
            }
            else {
                id dbObject = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:context];
                
                [self transferObject:data toDBObject:dbObject];
            }
            
        }
    }];

}

- (NSError *)saveDataList:(NSArray *)dataList ToDB:(NSManagedObjectContext *)context checkExist:(BOOL)check
{
    __block NSError * error = nil;

    [context performBlockAndWait:^{
        [self memSaveDataList:dataList ToDB:context checkExist:check];
        [context save:&error];
        DLog(@"save%@List error=%@",_entityName,[error description]);
    }];
    

    
    return error;
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
        
        for (id data in dbList) {
            @autoreleasepool {
                id object = [self transferDBObjectToObject:data];
                [resultArray addObject:object];
            }
        }
        array = resultArray;
    }];
    
    return array;

}

- (id)getDataByFilter:(NSPredicate *)filter fromDB:(NSManagedObjectContext *)context
{
    __block id object = nil;

    [context performBlockAndWait:^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSError * error = nil;
        
        [fetch setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:context]];
        [fetch setPredicate:filter];
        
        NSArray *dbList = [context executeFetchRequest:fetch error:&error];
        if (dbList.count) {
            object = [self transferDBObjectToObject:[dbList objectAtIndex:0]];
        }
    }];
    

    return object;
}

- (NSError *)memClearAllData:(NSManagedObjectContext *)context
{
    __block NSError * error = nil;

    [context performBlockAndWait:^{
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        
        [fetch setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:context]];
        
        NSArray *dbList = [context executeFetchRequest:fetch error:&error];
        for (id object in dbList) {
            [context deleteObject:object];
        }
    }];


    return error;
}

- (NSError *)clearAllData:(NSManagedObjectContext *)context
{
    __block NSError * error = nil;

    [context performBlockAndWait:^{
        [self memClearAllData:context];
        [context save:&error];
    }];
    
    

    return error;
}

- (NSError *)memClearDataByFilter:(NSPredicate *)filter fromDB:(NSManagedObjectContext *)context
{
    __block NSError * error = nil;

    [context performBlockAndWait:^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        
        [fetch setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:context]];
        [fetch setPredicate:filter];
        
        NSArray *dbList = [context executeFetchRequest:fetch error:&error];
        for (id object in dbList) {
            [context deleteObject:object];
        }
    }];
    

    return error;

}

- (NSError *)memReplaceFieldsByFilter:(NSPredicate *)filter withFields:(NSDictionary *)idMaps fromDB:(NSManagedObjectContext *)context
{
    __block NSError * error = nil;

    [context performBlockAndWait:^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        
        [fetch setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:context]];
        [fetch setPredicate:filter];
        NSArray *dbList = nil;
        
        @try {
            dbList = [context executeFetchRequest:fetch error:&error];
        }
        @catch (NSException *exception) {
            DLog(@"execute fetch exception: %@", exception);
            dbList = nil;
        }
        @finally {
            for (id object in dbList) {
                [self replaceFields:idMaps toDBObject:object];
            }
        }
    }];
    
    
    return error;
    
}

- (NSError *)memReplaceFields:(NSString *)fieldName ByFilter:(NSPredicate *)filter withValue:(id) newValue fromDB:(NSManagedObjectContext *)context
{
    __block NSError * error = nil;
    
    [context performBlockAndWait:^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:context]];
        [fetch setPredicate:filter];
        
        NSArray *dbList = [context executeFetchRequest:fetch error:&error];
        for (id object in dbList) {
            [self replaceFields:fieldName withValue:newValue toDBObject:object];
        }
    }];
    
    return error;
    
}

@end
