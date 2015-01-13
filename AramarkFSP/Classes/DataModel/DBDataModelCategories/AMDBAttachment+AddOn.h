//
//  AMDBAttachment+AddOn.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/9/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBAttachment.h"

@interface AMDBAttachment (AddOn)

+(void)insertNewEntitiesWithSFResponse:(NSArray *)array InManagedObjectContext:(NSManagedObjectContext *)context;

+(AMDBAttachment *)insertNewEntityWithSFDictionary:(NSDictionary *)dictionary InManagedObjectContext:(NSManagedObjectContext *)context;

+(AMDBAttachment *)insertNewEntityWithSetupBlock:(void(^)(AMDBAttachment *newAttachment))block
                          inManagedObjectContext:(NSManagedObjectContext *)context;

-(NSDictionary *)dictionaryToUploadSalesforce;


@end
