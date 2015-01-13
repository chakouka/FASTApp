//
//  AMDBReport.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/17/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBReport : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * mcCompletedCount;
@property (nonatomic, retain) NSNumber * mcCompletedMinutes;
@property (nonatomic, retain) NSNumber * myCompletedCount;
@property (nonatomic, retain) NSNumber * myCompletedMinutes;
@property (nonatomic, retain) NSString * recordType;

@end
