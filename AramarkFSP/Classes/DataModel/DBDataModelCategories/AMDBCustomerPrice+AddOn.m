//
//  AMDBCustomerPrice+AddOn.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/1/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBCustomerPrice+AddOn.h"

@implementation AMDBCustomerPrice (AddOn)

+(AMDBCustomerPrice *)newEntityInManagedObjectContext:(NSManagedObjectContext *)context;
{
    AMDBCustomerPrice *entity = nil;
    entity = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBCustomerPrice" inManagedObjectContext:context];
    return entity;
}

+(AMDBCustomerPrice *)newEntityWithSFDictionary:(NSDictionary *)dictionary InManagedObjectContext:(NSManagedObjectContext *)context;
{
    NSString *customerPriceID = [dictionary valueForKeyPathWithNullToNil:@"Id"];
    
    AMDBCustomerPrice *entity = [[AMDBManager sharedInstance] getCustomerPriceByID:customerPriceID];
    if (!entity) {
        entity = [self newEntityInManagedObjectContext:context];
    } else {
        entity = (AMDBCustomerPrice *)[context objectWithID: entity.objectID];
    }
    
    entity.customerPriceID = [dictionary valueForKeyPathWithNullToNil:@"Id"];
    entity.productName = [dictionary valueForKeyPathWithNullToNil:@"Product__r.Name"];
    entity.productID = [dictionary valueForKeyPathWithNullToNil:@"Product__r.Id"];
    entity.price = [dictionary valueForKeyPathWithNullToNil:@"Price__c"];
    entity.posID = [dictionary valueForKeyPathWithNullToNil:@"Point_of_Service__c"];
//    entity.productType = [dictionary valueForKeyPathWithNullToNil:@"Product__r.RecordType.Name"]; //Use record type from Customer price instead of product record type - changed on 11/05/2014 by Aaron
    entity.productType = [dictionary valueForKeyPathWithNullToNil:@"RecordType.Name"]; //The Record type name should be 'Filters','Invoice Codes' not 'Filter', Invoice Code'
    
    return entity;
}

@end
