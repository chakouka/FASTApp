//
//  NSDictionary+Addition.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/23/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Addition)

-(id)valueForKeyWithNullToNil:(NSString *)key;
-(id)valueForKeyPathWithNullToNil:(NSString *)keyPath;
-(id)valueForUndefinedKey:(NSString *)key;

@end
