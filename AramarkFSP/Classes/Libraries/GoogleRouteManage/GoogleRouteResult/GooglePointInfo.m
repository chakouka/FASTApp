//
//  GooglePointInfo.m
//  AramarkFSP
//
//  Created by FYH on 8/20/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "GooglePointInfo.h"

@implementation GooglePointInfo
@synthesize gId;
@synthesize gType;
@synthesize gDistance;
@synthesize gDuration;
@synthesize gFlag;
@synthesize gLocation;
@synthesize gMode;
@synthesize gPolyLine;

-(NSString *)description
{
    return [NSString stringWithFormat:@"%d - %@ - %@ - %@ - %@",gType,gId,gDistance.text,gDuration.text,gLocation];
}

@end
