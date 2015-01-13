//
//  NSArray+Addition.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 8/14/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Addition)

-(id)valueForKeyExcludingNull:(NSString *)key;
-(id)valueForKeyPathExcludingNull:(NSString *)keyPath;

@end
