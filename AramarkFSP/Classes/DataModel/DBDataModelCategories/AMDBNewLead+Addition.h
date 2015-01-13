//
//  AMDBNewLead+Addition.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/15/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBNewLead.h"

@interface AMDBNewLead (Addition)

+(AMDBNewLead *)insertNewEntityWithSetupBlock:(void(^)(AMDBNewLead *newAttachment))block
                          inManagedObjectContext:(NSManagedObjectContext *)context;

-(NSDictionary *)dictionaryToUploadSalesforce;

@end
