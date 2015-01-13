//
//  AMWOTypeManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 6/7/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMWorkOrder.h"
#import "AMAccount.h"
#import "AMCase.h"
#import "AMPoS.h"
#import "AMAsset.h"
#import "AMConstants.h"

@interface AMWOTypeManager : NSObject

- (void)getWOListByType:(NSArray *)woList completion:(AMDBOperationCompletionBlock)completionBlock;
@end
