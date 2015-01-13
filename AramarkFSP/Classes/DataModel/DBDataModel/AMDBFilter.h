//
//  AMDBFilter.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/31/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBFilter : NSManagedObject

@property (nonatomic, retain) NSString * posID;
@property (nonatomic, retain) NSString * filterID;
@property (nonatomic, retain) NSString * filterName;
@property (nonatomic, retain) NSNumber * price;

@end
