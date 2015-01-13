//
//  AMDBPicklist+Addition.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 8/5/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBPicklist+Addition.h"

@implementation AMDBPicklist (Addition)


+(void)insertNewEntitiesWithSFResponse:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context;
{
    for (NSString *objectName in dictionary) {
        NSDictionary *fieldDict = [dictionary valueForKeyWithNullToNil:objectName];
        for (NSString *fieldName in fieldDict) {
            NSArray *fieldValueList = [fieldDict valueForKeyWithNullToNil:fieldName];
            for (NSString *fieldValue in fieldValueList) {
                [self insertNewEntityWithObjectName:objectName fieldName:fieldName fieldValue:fieldValue inManagedObjectContext:context];
            }
        }
    }
}


+(void)insertNewEntityWithObjectName:(NSString *)objName
                           fieldName:(NSString *)fieldName
                          fieldValue:(NSString *)fieldValue
              inManagedObjectContext:(NSManagedObjectContext *)moc
{
    AMDBPicklist *picklist = [[AMDBManager sharedInstance] getPicklistWithObjectName:objName fieldName:fieldName fieldValue:fieldValue];
    if (!picklist) {
        picklist = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBPicklist" inManagedObjectContext:moc];
        picklist.objectName = objName;
        picklist.fieldName = fieldName;
        picklist.fieldValue = fieldValue;
    }
}


@end






