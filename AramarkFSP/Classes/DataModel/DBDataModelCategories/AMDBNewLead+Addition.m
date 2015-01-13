//
//  AMDBNewLead+Addition.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/15/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBNewLead+Addition.h"

@implementation AMDBNewLead (Addition)

+(AMDBNewLead *)newEntityInManagedObjectContext:(NSManagedObjectContext *)context
{
    AMDBNewLead *entity = nil;
    entity = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBNewLead" inManagedObjectContext:context];
    entity.dataStatus = [NSNumber numberWithInt:EntityStatusNew];
    entity.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];
    entity.createdDate = [NSDate date];
    
    return entity;
}

+(AMDBNewLead *)insertNewEntityWithSetupBlock:(void(^)(AMDBNewLead *newAttachment))block
                       inManagedObjectContext:(NSManagedObjectContext *)context
{
    AMDBNewLead *newEntity = [self newEntityInManagedObjectContext:context];
    block(newEntity);
    newEntity.dataStatus = @(EntityStatusCreated);
    
    return newEntity;
}

-(NSDictionary *)dictionaryToUploadSalesforce
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:self.fakeID forKeyPath:@"fakeId"];
    
    NSString *combinedStreet = [NSString stringWithFormat:@"%@ %@", self.street, self.street2];
    [dict setValue:combinedStreet forKeyPath:@"Street"];
    [dict setValue:self.city forKeyPath:@"City"];
    [dict setValue:self.stateProvince forKeyPath:@"State"];
    [dict setValue:self.zipCode forKeyPath:@"PostalCode"];
    [dict setValue:self.country forKeyPath:@"Country"];
    
    [dict setValue:self.title forKeyPath:@"Title"];
    [dict setValue:self.emailAddress forKeyPath:@"Email"];
    [dict setValue:self.phoneNumber forKeyPath:@"Phone"];
    [dict setValue:self.companyName forKeyPath:@"Company"];
    [dict setValue:self.referingEmployee forKeyPath:@"Referring_Employee__c"];
    [dict setValue:self.firstName forKeyPath:@"FirstName"];
    [dict setValue:self.lastName forKeyPath:@"LastName"];
    [dict setValue:self.salutation forKeyPath:@"Salutation"];
    
    NSMutableArray *currentProductList = [NSMutableArray array];
    if (self.hasCoffee.boolValue) {
        [currentProductList addObject:@"Coffee"];
    }
    if (self.hasWater.boolValue) {
        [currentProductList addObject:@"Water"];
    }
    if (self.hasIce.boolValue) {
        [currentProductList addObject:@"Ice"];
    }
    if (self.hasPrivateLabel.boolValue) {
        [currentProductList addObject:@"Private Label"];
    }
    if (self.hasSingleCup.boolValue) {
        [currentProductList addObject:@"Single Cup"];
    }
    NSString *currentProducts = [currentProductList componentsJoinedByString:@", "];
    NSString *combinedDescription = [NSString stringWithFormat:
                                     @"Company Size - %@\n"
                                     "Current Provider - %@\n"
                                     "Comments - %@\n"
                                     "Current Products - %@\n"
                                     "Satisfaction Level - %@\n",
                                     self.companySize, self.currentProvider, self.comments, currentProducts, self.satisfactionLevel];
    [dict setValue:combinedDescription forKeyPath:@"Description"];

    return dict;
}







@end
