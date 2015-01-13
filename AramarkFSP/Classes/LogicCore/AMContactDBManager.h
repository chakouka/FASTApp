//
//  AMContactDBManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMObjectDBManager.h"
#import "AMContact.h"

@interface AMContactDBManager : AMObjectDBManager

+ (AMContactDBManager *)sharedInstance;
@end
