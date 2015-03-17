//
//  AMDBNewContact+AddOn.m
//  AramarkFSP
//
//  Created by bkendall on 3/16/15.
//  Copyright (c) 2015 PWC Inc. All rights reserved.
//

#import "AMDBNewContact+AddOn.h"

@implementation AMDBNewContact (AddOn)

+(AMDBNewContact *)newEntityInManagedObjectContext:(NSManagedObjectContext *)context
{
    AMDBNewContact *entity = nil;
    entity = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBNewContact" inManagedObjectContext:context];

    
    return entity;
}

-(NSDictionary *)dictionaryToCreateObject
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:self.fakeID forKeyPath:@"fakeId"];
    [dict setValue:self.name forKeyPath:@"Point_of_Service__c"];
    [dict setValue:self.phone forKeyPath:@"MEI_Customer__c"];
    [dict setValue:self.role forKeyPath:@"Priority"];
    [dict setValue:self.title forKeyPath:@"Subject"];
    [dict setValue:self.contactID forKeyPath:@"Contact"];
    [dict setValue:self.email forKeyPath:@"ContactEmail"];
    [dict setValue:self.firstName forKeyPath:@"FirstName"];
    [dict setValue:self.lastName forKeyPath:@"LastName"];
    
    return dict;
}

@end
