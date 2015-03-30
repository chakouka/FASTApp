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
    entity.createdDate = [NSDate date];
    entity.dataStatus = [NSNumber numberWithInt:EntityStatusNew];
    entity.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];;

    
    return entity;
}

-(NSDictionary *)dictionaryToCreateObject
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:self.fakeID forKeyPath:@"FakeId"];
    [dict setValue:self.name forKeyPath:@"Name"];
    [dict setValue:self.phone forKeyPath:@"Phone"];
    [dict setValue:self.role forKeyPath:@"Role"];
    [dict setValue:self.title forKeyPath:@"Title"];
    [dict setValue:self.email forKeyPath:@"Email"];
    [dict setValue:self.firstName forKeyPath:@"FirstName"];
    [dict setValue:self.lastName forKeyPath:@"LastName"];
    [dict setValue:self.posID forKeyPath:@"PosID"];
    
    return dict;
}

@end
