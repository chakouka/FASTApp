//
//  AMPartsDBManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMObjectDBManager.h"
#import "AMParts.h"

@interface AMPartsDBManager : AMObjectDBManager

+ (AMPartsDBManager *)sharedInstance;
@end
