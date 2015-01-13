//
//  AMDBNewWorkOrder+Create.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/25/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBNewWorkOrder.h"
#import "AMWorkOrder.h"

@interface AMDBNewWorkOrder (AddOn)

+(AMDBNewWorkOrder *)newEntityInManagedObjectContext:(NSManagedObjectContext *)context;

+(AMDBNewWorkOrder *)newEntityWithAMWorkOrder:(AMWorkOrder *)workOrder InManagedObjectContext:(NSManagedObjectContext *)context;

-(NSDictionary *)dictionaryToCreateObject;

@end
