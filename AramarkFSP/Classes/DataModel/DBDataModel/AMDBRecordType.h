//
//  AMDBRecordType.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/9/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBRecordType : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectType;

@end
