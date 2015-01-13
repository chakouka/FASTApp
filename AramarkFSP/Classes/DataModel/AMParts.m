//
//  AMParts.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMParts.h"

@implementation AMParts

@synthesize partID;
@synthesize name;
@synthesize productID;

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ | %@ | %@",partID,name,productID];
}

@end
