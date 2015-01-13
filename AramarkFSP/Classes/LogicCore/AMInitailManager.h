//
//  AMInitailManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/25/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMConstants.h"

@interface AMInitailManager : NSObject
@property (nonatomic, strong) NSString * selfUId;
@property (nonatomic, strong) NSDate * timeStamp;

+ (AMInitailManager *)sharedInstance;

/**
 * Start Initial
 */
- (void)startInitialization:(AMDBOperationCompletionBlock)initCompletionHandler;

@end
