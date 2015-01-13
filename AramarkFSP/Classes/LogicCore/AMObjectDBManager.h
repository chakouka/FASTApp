//
//  AMObjectDBManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/18/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMObjectDBManager : NSObject
{
    NSString * _entityName;
}

- (void)memSaveDataList:(NSArray *)dataList ToDB:(NSManagedObjectContext *)context checkExist:(BOOL)check;

- (NSError *)saveDataList:(NSArray *)dataList ToDB:(NSManagedObjectContext *)context checkExist:(BOOL)check;

- (NSArray *)getDataListByFilter:(NSPredicate *)filter fromDB:(NSManagedObjectContext *)context;

- (id)getDataByFilter:(NSPredicate *)filter fromDB:(NSManagedObjectContext *)context;

- (NSError *)clearAllData:(NSManagedObjectContext *)context;

- (NSError *)memClearAllData:(NSManagedObjectContext *)context;

- (NSError *)memClearDataByFilter:(NSPredicate *)filter fromDB:(NSManagedObjectContext *)context;

- (NSError *)memReplaceFieldsByFilter:(NSPredicate *)filter withFields:(NSDictionary *)idMaps fromDB:(NSManagedObjectContext *)context;

- (NSError *)memReplaceFields:(NSString *)fieldName ByFilter:(NSPredicate *)filter withValue:(id) newValue fromDB:(NSManagedObjectContext *)context;

@end
