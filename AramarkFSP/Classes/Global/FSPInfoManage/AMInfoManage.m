//
//  AMInfoManage.m
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMInfoManage.h"
#import "AnnotationInfo.h"
#import "AMWorkOrder.h"
#import "GoogleRouteResult.h"
#import "AMProtocolParser.h"

/***************************************************************************************************************
 Change Log:
 -----------
 December 2014 Relese. ITEM000155: Show POS Name instead of Account Name on Map Annotations. By Hari Kolasani. 12/9/2014
 ***************************************************************************************************************/

@implementation AMInfoManage
@synthesize currentCheckinWorkOrderId;
@synthesize checkOutTempInfo;

+ (AMInfoManage *)sharedInstance {
	static AMInfoManage *sharedManager;
    
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    sharedManager = [[AMInfoManage alloc] init];
	});
    
	return sharedManager;
}

- (AnnotationInfo *)covertAnnotationInfoFromLocalWorkOrderInfo:(AMWorkOrder *)aLocalWorkOrderInfo withIndex:(NSInteger)aIndex
{
    AnnotationInfo *info = [[AnnotationInfo alloc] init];
    
    info.index = aIndex;
    info.woID = aLocalWorkOrderInfo.woID;
    
    if ([aLocalWorkOrderInfo.status isEqualToLocalizedString:@"In Progress"] || [aLocalWorkOrderInfo.status isEqualToLocalizedString:@"Checked Out"]) {
        info.viewType = AnnotationViewType_CheckOut;
    }
    else if([aLocalWorkOrderInfo.status isEqualToLocalizedString:@"Scheduled"])
    {
        info.viewType = AnnotationViewType_CheckIn;
    }
    else if([aLocalWorkOrderInfo.status isEqualToLocalizedString:@"Queued"])
    {
        info.viewType = AnnotationViewType_NearMe;
    }
    else
    {
        [AMUtilities showAlertWithInfo:MyLocal(@"Work order status error!")];
        return nil;
    }
    
    info.partType = MapLocationType_TargetPoint;
    info.title = aLocalWorkOrderInfo.contact;
    info.subtitle = aLocalWorkOrderInfo.workLocation;
    //CHANGE: ITEM000155
    AMPoS *woPoS  = [[AMLogicCore sharedInstance] getPoSInfoByID:aLocalWorkOrderInfo.posID];
    info.accountName = woPoS.name;
    info.count = [[[AMLogicCore sharedInstance] getAccountPendingWorkOrderList:aLocalWorkOrderInfo.accountID] count];
    info.location = [[CLLocation alloc] initWithLatitude:[aLocalWorkOrderInfo.latitude floatValue] longitude:[aLocalWorkOrderInfo.longitude floatValue]];
    return info;
}

- (AnnotationInfo *)covertAnnotationInfoFromNearWorkOrderInfo:(AMWorkOrder *)aNearWorkOrderInfo withIndex:(NSInteger)aIndex
{
    AnnotationInfo *info = [[AnnotationInfo alloc] init];
    
    info.index = aIndex;
    info.woID = aNearWorkOrderInfo.woID;
    info.viewType = AnnotationViewType_NearMe;
    info.partType = MapLocationType_TargetPoint;
    info.title = aNearWorkOrderInfo.contact;
    info.subtitle = aNearWorkOrderInfo.workLocation;

    /*
        Traher, 1/10/2015
        - Code below did not function properly for dislaying POS name on annotation for Near Me
        - Reverted back to using the Account name field from aNearWorkOrderInfo, and modified SFDC SOQL
            query to return POS Name in place of Account Name
        //CHANGE: ITEM000155
        AMPoS *woPoS  = [[AMLogicCore sharedInstance] getPoSInfoByID:aNearWorkOrderInfo.posID];
        info.accountName = woPoS.name;
     */
    
    //  ITEM000155 bug fix, Traher 1/10/2015
    info.accountName = aNearWorkOrderInfo.accountName;
    
    info.count = [[[AMLogicCore sharedInstance] getAccountPendingWorkOrderList:aNearWorkOrderInfo.accountID] count];
    info.location = [[CLLocation alloc] initWithLatitude:[aNearWorkOrderInfo.latitude floatValue] longitude:[aNearWorkOrderInfo.longitude floatValue]];
    return info;
}

- (NSMutableArray *)retrieveRouteDurationAndDistanceFrom:(GoogleRouteResult *)aGoogleRouteResult toList:(NSMutableArray *)aWorkOrderList
{
    NSMutableArray *arrLegs = ((GoogleRoute *)[[aGoogleRouteResult routes] firstObject]).legs;
//    NSMutableArray *arrOrder = ((GoogleRoute *)[[aGoogleRouteResult routes] firstObject]).waypoint_order;;
    
    NSMutableArray *arrOrderInfos = [aWorkOrderList mutableCopy];
    
    NSMutableArray *arrResult = [[NSMutableArray alloc] initWithCapacity:[arrLegs count]];
    
    for (GoogleRouteLeg *leg in arrLegs) {
        NSMutableArray *arrSame = [NSMutableArray array];
        
        for (AMWorkOrder *info in arrOrderInfos) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[info.latitude floatValue] longitude:[info.longitude floatValue]];
            
            if ([location distanceFromLocation:leg.relateLocation] < 0.000001) {
                if (![arrSame containsObject:info]) {
                    [arrSame addObject:info];
                }
            }
        }
        
        for (AMWorkOrder *info0 in arrSame) {
            if ([arrOrderInfos containsObject:info0]) {
                [arrOrderInfos removeObject:info0];
            }
            info0.nextDistance = MyLocal(@"1 ft");
            info0.nextTime = MyLocal(@"1 min");
        }
        
        AMWorkOrder *lastWorkOrder = [arrSame firstObject];
        lastWorkOrder.nextDistance = leg.distance.text;
        lastWorkOrder.nextTime = leg.duration.text;
        lastWorkOrder.nextDistanceValue = leg.distance.value;
        lastWorkOrder.nextTimeValue = leg.duration.value;
        
        [arrResult addObjectsFromArray:arrSame];
    }
    
    for (AMWorkOrder *info in arrOrderInfos) {
        info.nextDistance = MyLocal(@"1 ft");
        info.nextTime = MyLocal(@"1 min");
    }
    
    [arrResult addObjectsFromArray:arrOrderInfos];
    
//    for (NSInteger i = 0 ; i < [arrResult count] ; i++) {
//        AMWorkOrder *aWorkOrder = [arrResult objectAtIndex:i];
//        
//        if (i == 0) {
//            [self updateEstimatedTimeFor:aWorkOrder withStartTime:0.0]; //TODO::Need Start Time
//        }
//        else
//        {
//            AMWorkOrder *aPreAMWorkOrder = [arrResult objectAtIndex:(i - 1)];
//            AMEvent *event = [[AMLogicCore sharedInstance] getSelfEventByWOID:aPreAMWorkOrder.woID];
//            NSTimeInterval estiPreEndTime = [AMUtilities timeBySecondWithDate:event.estimatedTimeEnd];
//            
//            [self updateEstimatedTimeFor:aWorkOrder withStartTime:estiPreEndTime];
//        }
//    }
    
//    [self updateEstimatedTimeFor:arrResult withNoonBreakStartTime:<#(NSTimeInterval)#> andNoonBreakEndTime:<#(NSTimeInterval)#>];TODO::Need start time and end time
    
//    for (NSInteger i = 0 ; i < [arrResult count] ; i++) {
//        AMWorkOrder *aWorkOrder = [arrResult objectAtIndex:i];
//        
//        NSTimeZone *aZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
//        
//        DLog(@"result time : %@ - %@",[aWorkOrder.estimatedTimeStart formattedDateWithFormat:@"HH:mm:ss" timeZone:aZone],[aWorkOrder.estimatedTimeEnd formattedDateWithFormat:@"HH:mm:ss" timeZone:aZone]);
//    }
    
    return arrResult;
}

- (void)updateEstimatedTimeFor:(AMWorkOrder *)aWorkOrder withStartTime:(NSTimeInterval)aStartTime
{
    AMEvent *event = [[AMLogicCore sharedInstance] getSelfEventByWOID:aWorkOrder.woID];
    
    NSTimeInterval startTime = [AMUtilities timeBySecondWithDate:event.estimatedTimeStart];
    NSTimeInterval endTime = [AMUtilities timeBySecondWithDate:event.estimatedTimeEnd];
    NSTimeInterval workDuration = endTime - startTime;

    NSTimeInterval estiStartTime = aStartTime + [aWorkOrder.nextTimeValue floatValue];
    NSTimeInterval estiEndTime = estiStartTime + workDuration;
    
    event.estimatedTimeStart = [AMUtilities dateWithTimeSecond:estiStartTime];
    event.estimatedTimeEnd = [AMUtilities dateWithTimeSecond:estiEndTime];
    
    aWorkOrder.estimatedTimeStart = [AMUtilities dateWithTimeSecond:estiStartTime];
    aWorkOrder.estimatedTimeEnd = [AMUtilities dateWithTimeSecond:estiEndTime];
    
    [[AMLogicCore sharedInstance] updateEvent:event completionBlock:nil];
}

- (void)updateEstimatedTimeFor:(NSMutableArray *)WorkOrders withNoonBreakStartTime:(NSTimeInterval)aStartTime andNoonBreakEndTime:(NSTimeInterval)aEndTime
{
    for (NSInteger i = 0 ; i < [WorkOrders count] ; i++)
    {
        AMWorkOrder *aWorkOrder0 = [WorkOrders objectAtIndex:(i+1)];
        AMEvent *event0 = [[AMLogicCore sharedInstance] getSelfEventByWOID:aWorkOrder0.woID];
        
        NSTimeInterval startTime0 = [AMUtilities timeBySecondWithDate:event0.estimatedTimeStart];
        NSTimeInterval endTime0 = [AMUtilities timeBySecondWithDate:event0.estimatedTimeEnd];
        
//        AMWorkOrder *aWorkOrder = [WorkOrders objectAtIndex:i];
//        AMEvent *event = [[AMLogicCore sharedInstance] getSelfEventByWOID:aWorkOrder.woID];
//        NSTimeInterval startTime = [AMUtilities timeBySecondWithDate:event.estimatedTimeStart];
//        NSTimeInterval endTime = [AMUtilities timeBySecondWithDate:event.estimatedTimeEnd];
        
        if (endTime0 < aStartTime) {
            continue;
        }
        else
        {
            startTime0 += (aStartTime - aEndTime);
            endTime0 += (aStartTime - aEndTime);
            
            event0.estimatedTimeStart = [AMUtilities dateWithTimeSecond:startTime0];
            event0.estimatedTimeEnd = [AMUtilities dateWithTimeSecond:endTime0];
            
            aWorkOrder0.estimatedTimeStart = [AMUtilities dateWithTimeSecond:startTime0];
            aWorkOrder0.estimatedTimeEnd = [AMUtilities dateWithTimeSecond:endTime0];
            
            [[AMLogicCore sharedInstance] updateEvent:event0 completionBlock:nil];
            
            for (NSInteger j = i + 2; j < [WorkOrders count]; j ++)
            {
                AMWorkOrder *aWorkOrder1 = [WorkOrders objectAtIndex:j];
                [self updateEstimatedTimeFor:aWorkOrder1 withStartTime:endTime0];
            }
            
            break;
        }
        
//        NSTimeZone *aZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
        
//        DLog(@"result time : %@ - %@",[aWorkOrder.estimatedTimeStart formattedDateWithFormat:@"HH:mm:ss" timeZone:aZone],[aWorkOrder.estimatedTimeEnd formattedDateWithFormat:@"HH:mm:ss" timeZone:aZone]);
    }
}

@end
