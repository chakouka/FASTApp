//
//  NSArray+Addition.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 8/14/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "NSArray+Addition.h"

@implementation NSArray (Addition)

-(id)valueForKeyExcludingNull:(NSString *)key
{
    id value = [self valueForKey:key];
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != NULL"];
        value = [array filteredArrayUsingPredicate:predicate];
    }
    return value;
}

-(id)valueForKeyPathExcludingNull:(NSString *)keyPath
{
    id value = [self valueForKeyPath:keyPath];
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != NULL"];
        value = [array filteredArrayUsingPredicate:predicate];
    }
    return value;
}

@end
