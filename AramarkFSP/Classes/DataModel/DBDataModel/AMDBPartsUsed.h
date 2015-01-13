//
//  AMDBPartsUsed.h
//  AramarkFSP
//
//  Created by Appledev010 on 6/1/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBPartsUsed : NSManagedObject

@property (nonatomic, retain) NSNumber * pcount;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSString * invoiceID;
@property (nonatomic, retain) NSString * partID;
@property (nonatomic, retain) NSString * puID;
@property (nonatomic, retain) NSString * woID;

@end
