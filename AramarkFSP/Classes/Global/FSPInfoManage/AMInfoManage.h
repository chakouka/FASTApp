//
//  FSPInfoManage.h
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AnnotationInfo;
@class AMWorkOrder;
@class GoogleRouteResult;

@interface AMInfoManage : NSObject

@property (strong, nonatomic) NSString *currentCheckinWorkOrderId;
@property (strong, nonatomic) NSMutableDictionary *checkOutTempInfo;

+ (AMInfoManage *)sharedInstance;

- (AnnotationInfo *)covertAnnotationInfoFromLocalWorkOrderInfo:(AMWorkOrder *)aLocalWorkOrderInfo withIndex:(NSInteger)aIndex;

- (NSMutableArray *)retrieveRouteDurationAndDistanceFrom:(GoogleRouteResult *)aGoogleRouteResult toList:(NSMutableArray *)aWorkOrderList;

- (AnnotationInfo *)covertAnnotationInfoFromNearWorkOrderInfo:(AMWorkOrder *)aNearWorkOrderInfo withIndex:(NSInteger)aIndex;

@end
