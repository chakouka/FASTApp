//
//  NSManagedObject+Addition.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/15/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Addition)

+(instancetype)createNewEntityInManagedObjectContext:(NSManagedObjectContext *)moc;

-(void)saveWithCompletion:(AMDBOperationCompletionBlock)completionBlock;

@end
