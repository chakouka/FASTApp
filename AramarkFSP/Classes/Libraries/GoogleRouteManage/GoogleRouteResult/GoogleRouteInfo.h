//
//  GoogleRouteInfo.h
//  AramarkFSP
//
//  Created by FYH on 8/14/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleRouteResult.h"

@interface GoogleRouteInfo : NSObject

@property (nonatomic, strong) NSString *gId;
@property (nonatomic, strong) CLLocation *gFrom;
@property (nonatomic, strong) CLLocation *gTo;
@property (nonatomic, strong) NSString *gMode;
@property (nonatomic, strong) NSArray *gPolyLine;
@property (nonatomic, strong) GoogleRouteLegDuration *gDuration;
@property (nonatomic, strong) GoogleRouteLegDistance *gDistance;
@property (nonatomic, strong) NSString *gFlag;

@end
