//
//  AMPartsUsed.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/24/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMPartsUsed : NSObject
@property (nonatomic, strong) NSString * partID;
@property (nonatomic, strong) NSString * woID;
@property (nonatomic, strong) NSString * invoiceID;
@property (nonatomic, strong) NSNumber * pcount;
@property (nonatomic, strong) NSString * puID;
@property (nonatomic, strong) NSString * createdBy;
@end
