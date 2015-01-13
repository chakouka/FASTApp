//
//  AMDBCustomerPrice+AddOn.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/1/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBCustomerPrice.h"

@interface AMDBCustomerPrice (AddOn)

+(AMDBCustomerPrice *)newEntityInManagedObjectContext:(NSManagedObjectContext *)context;

+(AMDBCustomerPrice *)newEntityWithSFDictionary:(NSDictionary *)dictionary InManagedObjectContext:(NSManagedObjectContext *)context;


@end
