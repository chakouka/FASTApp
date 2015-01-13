//
//  AMFileManage.m
//  AramarkFSP
//
//  Created by FYH on 9/22/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMFileManage.h"

@implementation AMFileManage

+ (NSString *)pathWithName:(NSString *)aName {
    NSString *documentsDirectory = NSTemporaryDirectory();
    return [documentsDirectory stringByAppendingPathComponent:aName];
}

+ (void)saveData:(NSData *)aData withName:(NSString *)aName {
    [aData writeToFile:[self pathWithName:aName] atomically:YES];
}

+ (NSData *)dataWithName:(NSString *)aName {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self pathWithName:aName]]) {
        return [NSData dataWithContentsOfFile:[self pathWithName:aName]];
    }
    
    return nil;
}

+ (void)removeDataWithName:(NSString *)aName {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self pathWithName:aName]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self pathWithName:aName] error:nil];
    }
}

@end
