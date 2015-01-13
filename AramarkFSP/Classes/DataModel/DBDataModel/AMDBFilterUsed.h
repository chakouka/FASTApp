//
//  AMDBFilterUsed.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/31/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBFilterUsed : NSManagedObject

@property (nonatomic, retain) NSNumber * fcount;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSString * filterID;
@property (nonatomic, retain) NSString * fuID;
@property (nonatomic, retain) NSString * invoiceID;
@property (nonatomic, retain) NSString * woID;

@end
