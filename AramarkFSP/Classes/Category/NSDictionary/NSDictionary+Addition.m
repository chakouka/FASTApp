//
//  NSDictionary+Addition.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/23/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "NSDictionary+Addition.h"

@implementation NSDictionary (Addition)

-(id)valueForKeyWithNullToNil:(NSString *)key
{
    id value = [self valueForKey:key];
    return [value isKindOfClass:[NSNull class]] ? nil : value;
}

-(id)valueForKeyPathWithNullToNil:(NSString *)keyPath
{
    id value = [self valueForKeyPath:keyPath];
    return [value isKindOfClass:[NSNull class]] ? nil : value;
}

-(id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}
@end
