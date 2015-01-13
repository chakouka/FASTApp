//
//  AMEvent.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMEvent : NSObject

@property (nonatomic, strong) NSString * eventID;
@property (nonatomic, strong) NSString * woID;
@property (nonatomic, strong) NSString * ownerID;
@property (nonatomic, strong) NSDate * estimatedTimeStart;
@property (nonatomic, strong) NSDate * estimatedTimeEnd;
@property (nonatomic, strong) NSDate * actualTimeStart;
@property (nonatomic, strong) NSDate * actualTimeEnd;

@end
