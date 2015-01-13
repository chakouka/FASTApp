//
//  AMFileManage.h
//  AramarkFSP
//
//  Created by FYH on 9/22/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMFileManage : NSObject

+ (NSString *)pathWithName:(NSString *)aName;
+ (void)saveData:(NSData *)aData withName:(NSString *)aName;
+ (NSData *)dataWithName:(NSString *)aName;
+ (void)removeDataWithName:(NSString *)aName;

@end
