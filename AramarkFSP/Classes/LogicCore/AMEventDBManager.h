//
//  AMEventDBManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMEvent.h"
#import "AMObjectDBManager.h"

@interface AMEventDBManager : AMObjectDBManager

+ (AMEventDBManager *)sharedInstance;

@end
