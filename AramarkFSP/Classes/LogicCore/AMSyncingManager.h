//
//  AMSyncingManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMConstants.h"

@interface AMSyncingManager : NSObject

@property (nonatomic, strong) NSString * selfUId;
@property (nonatomic, strong) NSDate * timeStamp;

+ (AMSyncingManager *)sharedInstance;

/**
 * Start Syncing
 */
- (void)startSyncing:(AMDBOperationCompletionBlock)syncCompletionHandler;

- (void)activeAutoSyncing:(AMDBOperationCompletionBlock)syncCompletionHandler;
- (void)cancelAutoSyncing;
- (void)updateCurrentLongitude:(NSNumber *)longitude andLatitude:(NSNumber *)latitude;

-(BOOL)isSyncing;

@end
