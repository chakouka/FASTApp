//
//  AMReportCompletedWODM.h
//  AramarkFSP
//
//  Created by Jonathan.WANG on 7/11/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMReportCompletedWODM : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *mcCompletedCount;
@property (nonatomic, strong) NSNumber * mcCompletedMinutes;
@property (nonatomic, strong) NSNumber * myCompletedCount;
@property (nonatomic, strong) NSNumber * myCompletedMinutes;
@property (nonatomic,strong) NSString *recordType;

@end
