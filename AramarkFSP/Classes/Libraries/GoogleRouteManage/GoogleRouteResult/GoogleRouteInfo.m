//
//  GoogleRouteInfo.m
//  AramarkFSP
//
//  Created by FYH on 8/14/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "GoogleRouteInfo.h"

@implementation GoogleRouteInfo

@synthesize gDistance;
@synthesize gDuration;
@synthesize gId;
@synthesize gFrom;
@synthesize gTo;
@synthesize gMode;
@synthesize gPolyLine;
@synthesize gFlag;

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ From : %f,%f To : %f,%f Distance : %@ Time : %@",self.gId,self.gFrom.coordinate.latitude,self.gFrom.coordinate.longitude,self.gTo.coordinate.latitude,self.gTo.coordinate.longitude,self.gDistance.text, self.gDuration.text];
}

@end
