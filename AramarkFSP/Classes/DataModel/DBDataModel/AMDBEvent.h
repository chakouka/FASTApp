//
//  AMDBEvent.h
//  AramarkFSP
//
//  Created by Appledev010 on 6/4/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBEvent : NSManagedObject

@property (nonatomic, retain) NSString * eventID;
@property (nonatomic, retain) NSString * ownerID;
@property (nonatomic, retain) NSString * woID;
@property (nonatomic, retain) NSDate * estimatedTimeStart;
@property (nonatomic, retain) NSDate * estimatedTimeEnd;
@property (nonatomic, retain) NSDate * actualTimeStart;
@property (nonatomic, retain) NSDate * actualTimeEnd;

@end
