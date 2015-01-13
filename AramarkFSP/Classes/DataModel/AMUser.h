//
//  AMUser.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/7/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMUser : NSObject

@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSDate * timeStamp;
@property (nonatomic, strong) NSString * photoUrl;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, retain) NSString * lunchBreakFrom;
@property (nonatomic, retain) NSString * lunchBreakTo;
@property (nonatomic, retain) NSString * workingHourFrom;
@property (nonatomic, retain) NSString * workingHourTo;
@property (nonatomic, retain) NSDate * positionTimestamp;
@property (nonatomic, retain) NSString * marketCenterEmail;

@end
