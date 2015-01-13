//
//  AMDBReport+AddOn.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/8/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBReport+AddOn.h"
#import "AMProtocolParser.h"

@implementation AMDBReport (AddOn)

+(void)insertNewEntitiesWithSFResponse:(NSDictionary *)dictionary InManagedObjectContext:(NSManagedObjectContext *)context
{
    NSDictionary *reports = dictionary[@"mapDate2MapCount"];
    if (!reports) {
        return;
    }
    
    for (NSString *day in reports) {
        NSDictionary *dayDict = reports[day];
        for (NSString *recordType in dayDict) {
            NSDictionary *dayRecordDict = dayDict[recordType];
            [self insertNewEntityWithDay:day recordType:recordType dataDictionary:dayRecordDict InManagedObjectContext:context];
        }
    }
}

+(AMDBReport *)insertNewEntityWithDay:(NSString *)day
                           recordType:(NSString *)recordType
                       dataDictionary:(NSDictionary *)dataDictionary
               InManagedObjectContext:(NSManagedObjectContext *)context
{
    AMDBReport *entity = nil;
    if (!dataDictionary || !day || !recordType) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    formatter.dateFormat = @"MM/dd/yyyy";
    NSDate *date = [formatter dateFromString:day];
    
    if (!date) {
        formatter.dateFormat = @"yyyy-MM-dd";
        date = [formatter dateFromString:day];
    }
    
    entity = [[AMDBManager sharedInstance] getReportByDate:date andRecordType:recordType];
    
    if (!entity) {
        entity = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBReport" inManagedObjectContext:context];
    } else {
        entity = (AMDBReport *)[context objectWithID: entity.objectID];
    }
    

    // fill in data
    entity.date = date;
    entity.recordType = recordType;
    entity.myCompletedCount = [dataDictionary valueForKeyWithNullToNil:@"MyCompletedCount"];
    entity.myCompletedMinutes = [dataDictionary valueForKeyWithNullToNil:@"MyCompletedMinutes"];
    entity.mcCompletedCount = [dataDictionary valueForKeyWithNullToNil:@"McCompletedCount"];
    entity.mcCompletedMinutes = [dataDictionary valueForKeyWithNullToNil:@"McCompletedMinutes"];
    
    NSError *error;
    [context save:&error];
    if (error) {
        DLog(@"save report entity error: %@", error.localizedDescription);
    }
    
    return entity;
}







#pragma mark - Deprecated

+(AMDBReport *)insertNewEntityWithSFDictionary:(NSDictionary *)dictionary InManagedObjectContext:(NSManagedObjectContext *)context
{
    AMDBReport *entity = nil;
    if (!dictionary) {
        return nil;
    }
    
    NSString *key = dictionary.allKeys.firstObject;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    formatter.dateFormat = @"MM/dd/yyyy";
    NSDate *date = [formatter dateFromString:key];
    
    entity = [[AMDBManager sharedInstance] getReportByDate:date];
    
    if (!entity) {
        entity = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBReport" inManagedObjectContext:context];
    } else {
        entity = (AMDBReport *)[context objectWithID: entity.objectID];
    }
    
    [entity setValueWithSFDictionary:dictionary];
    
    NSError *error;
    [context save:&error];
    if (error) {
        DLog(@"save report entity error: %@", error.localizedDescription);
    }
    
    return entity;
}

-(void)setValueWithSFDictionary:(NSDictionary *)dictionary
{
    AMDBReport *entity = self;
    
    NSString *key = dictionary.allKeys.firstObject;
    NSDictionary *detailDict = dictionary[key];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    formatter.dateFormat = @"MM/dd/yyyy";
    
    entity.date = [formatter dateFromString:key];
    entity.myCompletedCount = [detailDict valueForKeyWithNullToNil:@"MyCompletedCount"];
    entity.myCompletedMinutes = [detailDict valueForKeyWithNullToNil:@"MyCompletedMinutes"];
    entity.mcCompletedCount = [detailDict valueForKeyWithNullToNil:@"McCompletedCount"];
    entity.mcCompletedMinutes = [detailDict valueForKeyWithNullToNil:@"McCompletedMinutes"];
}


@end




