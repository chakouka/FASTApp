//
//  AMDBNewCase+Create.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/24/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBNewCase.h"

@interface AMDBNewCase (AddOn)

+(AMDBNewCase *)newEntityInManagedObjectContext:(NSManagedObjectContext *)context;

-(NSDictionary *)dictionaryToCreateObject;

@end
