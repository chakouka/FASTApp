//
//  GoogleRouteManage.h
//  Todo
//
//  Created by PwC on 4/14/14.
//  Copyright (c) 2014 viktyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleRouteInfo.h"
#import "GooglePointInfo.h"

typedef void (^GoogleOperationCompletionBlock) (NSInteger type,id result, NSError *error);

@interface GoogleRouteManage : NSObject

@property (strong, nonatomic) NSOperationQueue *requestQueue;
@property (strong, nonatomic) NSURLSession *markerSession;

+ (GoogleRouteManage *)sharedInstance;

- (void)fetchRoutes:(NSMutableArray *)routes
         completion:(GoogleOperationCompletionBlock)completion;

- (void)fetchPoints:(NSMutableArray *)points
           optimize:(BOOL)isOptimize
         completion:(GoogleOperationCompletionBlock)completion;
@end
