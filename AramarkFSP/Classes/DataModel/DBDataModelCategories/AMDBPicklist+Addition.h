//
//  AMDBPicklist+Addition.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 8/5/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBPicklist.h"

@interface AMDBPicklist (Addition)

+(void)insertNewEntitiesWithSFResponse:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context;

@end
