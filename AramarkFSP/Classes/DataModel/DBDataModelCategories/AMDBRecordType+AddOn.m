//
//  AMDBRecordType+AddOn.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/9/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBRecordType+AddOn.h"

@implementation AMDBRecordType (AddOn)

+(void)insertNewEntitiesWithSFResponse:(NSArray *)array InManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *dict in array) {
        [self insertNewEntityWithSFDictionary:dict InManagedObjectContext:context];
    }
}

+(AMDBRecordType *)insertNewEntityWithSFDictionary:(NSDictionary *)dictionary InManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *recordTypeID = [dictionary valueForKeyWithNullToNil:@"Id"];
    
    AMDBRecordType *entity = [[AMDBManager sharedInstance] getRecordTypeByID:recordTypeID];
    if (!entity) {
        entity = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBRecordType" inManagedObjectContext:context];
    } else {
        entity = (AMDBRecordType *)[context objectWithID: entity.objectID];
    }
    
    entity.id = [dictionary valueForKeyWithNullToNil:@"Id"];
    entity.name = [dictionary valueForKeyWithNullToNil:@"Name"];
    entity.objectType = [dictionary valueForKeyWithNullToNil:@"SobjectType"];
    
    return entity;
}

@end
