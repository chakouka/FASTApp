//
//  AMUser.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/7/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMUser.h"


@implementation AMUser

@synthesize userID;
@synthesize displayName;
@synthesize timeStamp;
@synthesize photoUrl;
@synthesize longitude;
@synthesize latitude;

- (NSString *)description
{
    return [NSString stringWithFormat:@"UserId : %@ ; displayName : %@ ; timeStamp : %@ ; photoUrl : %@",userID,displayName,timeStamp,photoUrl];
}

@end
