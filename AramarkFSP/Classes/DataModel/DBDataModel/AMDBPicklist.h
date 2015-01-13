//
//  AMDBPicklist.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 8/5/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBPicklist : NSManagedObject

@property (nonatomic, retain) NSString * objectName;
@property (nonatomic, retain) NSString * fieldName;
@property (nonatomic, retain) NSString * fieldValue;

@end
