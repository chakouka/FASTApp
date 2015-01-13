//
//  AMDBUser.h
//  AramarkFSP
//
//  Created by Aaron Hu on 10/22/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBUser : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * lunchBreakFrom;
@property (nonatomic, retain) NSString * lunchBreakTo;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSDate * positionTimestamp;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * workingHourFrom;
@property (nonatomic, retain) NSString * workingHourTo;
@property (nonatomic, retain) NSString * marketCenterEmail;

@end
