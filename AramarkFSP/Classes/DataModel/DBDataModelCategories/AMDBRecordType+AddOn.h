//
//  AMDBRecordType+AddOn.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/9/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBRecordType.h"

@interface AMDBRecordType (AddOn)

+(void)insertNewEntitiesWithSFResponse:(NSArray *)array InManagedObjectContext:(NSManagedObjectContext *)context;

+(AMDBRecordType *)insertNewEntityWithSFDictionary:(NSDictionary *)dictionary InManagedObjectContext:(NSManagedObjectContext *)context;

@end
