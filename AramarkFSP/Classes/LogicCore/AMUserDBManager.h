//
//  AMUserDBManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/10/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AMUser.h"
#import "AMObjectDBManager.h"

@interface AMUserDBManager : AMObjectDBManager

+ (AMUserDBManager *)sharedInstance;

- (void)updateUser:(NSPredicate *)filter timeStamp:(NSDate *)timeStamp ToDB:(NSManagedObjectContext *)context;
@end
