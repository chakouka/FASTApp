//
//  AMDBReport+AddOn.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/8/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBReport.h"

@interface AMDBReport (AddOn)

+(void)insertNewEntitiesWithSFResponse:(NSDictionary *)dictionary InManagedObjectContext:(NSManagedObjectContext *)context;

+(AMDBReport *)insertNewEntityWithDay:(NSString *)day
                           recordType:(NSString *)recordType
                       dataDictionary:(NSDictionary *)dataDictionary
               InManagedObjectContext:(NSManagedObjectContext *)context;

@end
