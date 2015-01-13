//
//  AMWODBManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/10/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AMDBWorkOrder.h"
#import "AMWorkOrder.h"
#import "AMObjectDBManager.h"

@interface AMWODBManager : AMObjectDBManager

@property (nonatomic, strong) NSString * selfId;

+ (AMWODBManager *)sharedInstance;

/**
 *  Used by returning pending work order list by Account
 *
 *  @param filter    Filter
 *  @param sortArray Sort Array
 *  @param context   context
 *
 *  @return AMWorkOrder Array
 */
- (NSArray *)getWorkOrderWithPOSByFilter:(NSPredicate *)filter sortArray:(NSArray *)sortArray fromDB:(NSManagedObjectContext *)context;

@end
