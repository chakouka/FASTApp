//
//  AMOnlineOprManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMWorkOrder.h"

@interface AMOnlineOprManager : NSObject
@property (nonatomic, strong) NSString * selfUId;
@property (nonatomic, strong) NSDate * timeStamp;

+ (AMOnlineOprManager *)sharedInstance;

- (void)updateSingleWO:(AMWorkOrder *)wo completion:(AMDBOperationCompletionBlock)syncCompletionHandler;

- (void)assignWorkOrderToSelf:(AMWorkOrder *)wo completion:(AMDBOperationCompletionBlock)syncCompletionHandler;

/**
 *  Assign Work Order to self in Near Me
 *
 *  @param woId              work order id
 *  @param completionHandler completion block
 */
- (void)assignWorkOrderToSelfFromNearMe:(NSString *)woId completion:(AMDBOperationCompletionBlock)completionHandler;

@end
