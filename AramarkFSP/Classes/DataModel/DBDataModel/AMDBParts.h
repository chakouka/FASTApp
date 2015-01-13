//
//  AMDBParts.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 8/8/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBParts : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * partID;
@property (nonatomic, retain) NSString * productID;
@property (nonatomic, retain) NSString * partDescription;

@end
