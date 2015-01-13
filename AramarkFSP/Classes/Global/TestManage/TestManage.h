//
//  TestManage.h
//  AramarkFSP
//
//  Created by PwC on 5/6/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  All of these methods are used for testing. Remove import when release.
 */

@class AnnotationInfo;

@interface TestManage : NSObject

@property (nonatomic,strong)NSMutableArray *localorderList;
@property (nonatomic,strong)NSMutableArray *localTestTages;
@property (nonatomic,strong)NSMutableArray *localTestList1;
@property (nonatomic,strong)NSMutableArray *localTestList2;
@property (nonatomic,strong)NSMutableArray *localTestList3;

+ (TestManage *)sharedInstance;
- (AnnotationInfo *)randomAnnotationInfo;
- (AMWorkOrder *)randomLocalWorkOrder;
- (NSMutableArray *)refreshLocalOrderList;
- (NSMutableArray *)arrLocalList;
- (NSMutableArray *)listWithCenter:(CLLocation *)center WorkOrder:(AMWorkOrder *)aWorkOrder andRadius:(CGFloat)aRadius;

@end
