//
//  GooglePointInfo.h
//  AramarkFSP
//
//  Created by FYH on 8/20/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleRouteResult.h"

typedef NS_ENUM(NSInteger, PointType) {
    PointType_Start = 0,
    PointType_Noraml,
    PointType_End,
};

@interface GooglePointInfo : NSObject

@property (nonatomic, strong) NSString *gId;
@property (nonatomic, strong) CLLocation *gLocation;
@property (nonatomic, assign) PointType gType;
@property (nonatomic, strong) NSString *gMode;
@property (nonatomic, strong) NSArray *gPolyLine;
@property (nonatomic, strong) GoogleRouteLegDuration *gDuration;
@property (nonatomic, strong) GoogleRouteLegDistance *gDistance;
@property (nonatomic, strong) NSString *gFlag;

@end
