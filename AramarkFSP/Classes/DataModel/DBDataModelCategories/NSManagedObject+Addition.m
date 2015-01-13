//
//  NSManagedObject+Addition.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/15/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "NSManagedObject+Addition.h"

@implementation NSManagedObject (Addition)

+(instancetype)createNewEntityInManagedObjectContext:(NSManagedObjectContext *)moc
{    
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:moc];
}

-(void)saveWithCompletion:(AMDBOperationCompletionBlock)completionBlock;
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlock:^{
        NSError *error = nil;
        [moc save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
}

@end
