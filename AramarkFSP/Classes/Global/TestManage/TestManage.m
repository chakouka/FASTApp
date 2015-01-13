//
//  TestManage.m
//  AramarkFSP
//
//  Created by PwC on 5/6/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "TestManage.h"
#import "AnnotationInfo.h"
#import "AMWorkOrder.h"
//#import "MapTool.h"

@implementation TestManage
@synthesize localorderList;
@synthesize localTestTages;
@synthesize localTestList1;
@synthesize localTestList2;
@synthesize localTestList3;

+ (TestManage *)sharedInstance {
    static TestManage *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TestManage alloc] init];
        sharedManager.localTestList1 = [NSMutableArray array];
        sharedManager.localTestList2 = [NSMutableArray array];
        sharedManager.localTestList3 = [NSMutableArray array];
    });
    
    return sharedManager;
}

#pragma mark -

//+ (NSTimeInterval)currentTime {
//	return [[self class] timeBySecondWithDate:[NSDate date]];
//}
//
//+ (NSTimeInterval)daysLater:(NSInteger)aDays {
//	return [self daysLater:aDays after:[[self class] currentTime]];
//}
//
//+ (NSTimeInterval)daysLater:(NSInteger)aDays after:(NSTimeInterval)aDay {
//	return (aDay + aDays * 24 * 60 * 60);
//}
//
//+ (NSTimeInterval)daysBefore:(NSInteger)aDays from:(NSTimeInterval)aDay {
//	return (aDay - aDays * 24 * 60 * 60);
//}
//
//+ (NSTimeInterval)timeBySecondWithDate:(NSDate *)aDate {
//	return (int)([aDate timeIntervalSince1970] + 0.5);
//}
//
//+ (NSDate *)dateWithTimeSecond:(NSTimeInterval)aTimeInterval {
//	return [NSDate dateWithTimeIntervalSince1970:aTimeInterval];
//}

#pragma mark -

- (AnnotationInfo *)randomAnnotationInfo {
    AnnotationInfo *info = [[AnnotationInfo alloc] init];
    
    NSInteger iTag = arc4random() % 1000;
    info.partType = MapLocationType_TargetPoint;
    info.title = [NSString stringWithFormat:@"Title_%d", iTag];
    info.subtitle = [NSString stringWithFormat:@"SubTitle_%d", iTag];
    
    float ilant = (((arc4random() % 100) >= 50) ? (INITLatitude + ((arc4random() % 1000) / 1000.0)) : (INITLatitude - ((arc4random() % 1000) / 1000.0)));
    float ilong = (((arc4random() % 100) >= 50) ? (INITLongitude + ((arc4random() % 1000) / 1000.0)) : (INITLongitude - ((arc4random() % 1000) / 1000.0)));
    
    info.location = [[CLLocation alloc] initWithLatitude:ilant longitude:ilong];
    
    return info;
}

-(NSString *)strWithCharacterNumbers:(NSInteger)iCount
{
    NSString *strInit = @"S";
    
    if (iCount < 1) {
        return strInit;
    }
    
    for (NSInteger i = 0 ; i < iCount; i ++) {
        strInit = [strInit stringByAppendingString:@"S"];
    }
    
    return strInit;
}

- (NSMutableArray *)arrLocalList
{
    NSMutableArray *arrInfos = [NSMutableArray array];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self class] pathWithName:@"LOCALTESTDATA"]]) {
        self.localTestTages = [NSMutableArray arrayWithContentsOfFile:[[self class] pathWithName:@"LOCALTESTDATA"]];
    }
    
    if (localTestTages && [localTestTages count] > 0) {
        for (NSMutableDictionary *dicInfo in localTestTages) {
            [arrInfos addObject:[self createWorkOrderWithTag:dicInfo]];
        }
        
        return arrInfos;
    }
    else
    {
        localTestTages  = [NSMutableArray array];
        for (NSInteger i = 0; i < 10; i ++) {
            [localTestTages addObject:[self creatTagsDicInfo]];
        }
        
        [localTestTages writeToFile:[[self class] pathWithName:@"LOCALTESTDATA"] atomically:YES];
        
        return [self arrLocalList];
    }
}

- (NSMutableDictionary *)creatTagsDicInfo
{
    NSInteger iTag = arc4random() % 1000000;
    float ilant = (((arc4random() % 100) >= 50) ? (INITLatitude + ((arc4random() % 1000) / 1000.0)) : (INITLatitude - ((arc4random() % 1000) / 1000.0)));
    float ilong = (((arc4random() % 100) >= 50) ? (INITLongitude + ((arc4random() % 1000) / 1000.0)) : (INITLongitude - ((arc4random() % 1000) / 1000.0)));
    
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    [dicInfo setObject:[NSNumber numberWithInteger:iTag] forKey:@"TAG"];
    [dicInfo setObject:[NSNumber numberWithFloat:ilant] forKey:@"LANT"];
    [dicInfo setObject:[NSNumber numberWithFloat:ilong] forKey:@"LONG"];
    
    return dicInfo;
}

- (AMWorkOrder *)createWorkOrderWithTag:(NSMutableDictionary *)dicInfo
{
    NSInteger iTag = [[dicInfo objectForKey:@"TAG"] integerValue];
    float ilant = [[dicInfo objectForKey:@"LANT"] floatValue];
    float ilong = [[dicInfo objectForKey:@"LONG"] floatValue];
    
    NSDate *createDate = [AMUtilities dateWithTimeSecond:[AMUtilities daysBefore:(arc4random() % 20) from:[AMUtilities currentTime]]];
    NSDate *modifiedDate = [AMUtilities dateWithTimeSecond:[AMUtilities daysBefore:(arc4random() % 5) from:[AMUtilities timeBySecondWithDate:createDate]]];
    /*NSDate *preferrTimeFrom = [AMUtilities dateWithTimeSecond:[AMUtilities daysBefore:(arc4random() % 15) from:[AMUtilities timeBySecondWithDate:createDate]]];
     NSDate *preferrTimeTo = [AMUtilities dateWithTimeSecond:[AMUtilities daysBefore:(arc4random() % 5) from:[AMUtilities timeBySecondWithDate:createDate]]];
     */
    NSDate *estimatedTimeEnd = [AMUtilities dateWithTimeSecond:[AMUtilities daysBefore:(arc4random() % 15) from:[AMUtilities timeBySecondWithDate:createDate]]];
    NSDate *estimatedTimeStart = [AMUtilities dateWithTimeSecond:[AMUtilities daysBefore:(arc4random() % 5) from:[AMUtilities timeBySecondWithDate:createDate]]];
    
    AMWorkOrder *order = [[AMWorkOrder alloc] init];
    order.accessoriesRequired = [NSString stringWithFormat:@"accessoriesRequired_%d", iTag];
    order.assetID = [NSString stringWithFormat:@"assetID_%d", iTag];
    order.callAhead = [NSNumber numberWithInt:(arc4random() % 10)];
    order.caseID = [NSString stringWithFormat:@"caseID_%d", iTag];
    order.complaintCode = [NSString stringWithFormat:@"complaintCode_%d", iTag];
    order.contact = [NSString stringWithFormat:@"contact_%d", iTag];
    order.createdBy = [NSString stringWithFormat:@"createdBy_%d", iTag];
    order.createdDate = createDate;
    order.estimatedTimeEnd = estimatedTimeEnd;
    order.estimatedTimeStart = estimatedTimeStart;
    order.filterCount = [NSNumber numberWithInt:(arc4random() % 10)];
    order.filterType = [NSString stringWithFormat:@"filterType_%d", iTag];
    order.fromLocation = [NSString stringWithFormat:@"fromLocation_%d", iTag];
    order.lastModifiedBy = [NSString stringWithFormat:@"lastModifiedBy_%d", iTag];
    order.lastModifiedDate = modifiedDate;
    order.latitude = [NSNumber numberWithFloat:ilant];
    order.longitude = [NSNumber numberWithFloat:ilong];
    order.machineType = [NSString stringWithFormat:@"machineType_%d", iTag];
    order.notes = [NSString stringWithFormat:@"notes_%d", iTag];
    order.parkingDetail = [NSString stringWithFormat:@"parkingDetail_%d", iTag];
    order.posID = [NSString stringWithFormat:@"aposID_%d", iTag];
    order.preferrTimeFrom = [NSString stringWithFormat:@"%d:00", iTag];
    order.preferrTimeTo = [NSString stringWithFormat:@"%d:00", iTag];
    order.priority = [NSString stringWithFormat:@"priority_%d", iTag];
    order.repairCode = [NSString stringWithFormat:@"repairCode_%d", iTag];
    order.status = [NSString stringWithFormat:@"status_%d", iTag];
    order.toLocationID = [NSString stringWithFormat:@"toLocation_%d", iTag];
    order.vendKey = [NSString stringWithFormat:@"vendKey_%d", iTag];
    order.warranty = [NSNumber numberWithInt:(arc4random() % 10)];
    order.woID = [NSString stringWithFormat:@"woID_%d", iTag];
    order.woNumber = [NSString stringWithFormat:@"woNumber_%d", iTag];
    order.workLocation = [NSString stringWithFormat:@"workLocation_%d", iTag];
    order.woType = [NSString stringWithFormat:@"woType_%d", iTag];
    order.ownerID = [NSString stringWithFormat:@"ownerID_%d", iTag];
    order.status = @"Scheduled";
    order.actualTimeStart = order.estimatedTimeStart;
    order.actualTimeEnd = order.estimatedTimeEnd;
    
    NSInteger shortTag = arc4random() % 100;
    //	order.accountName = [self strWithCharacterNumbers:shortTag];
    order.accountName = [NSString stringWithFormat:@"wo_%d", shortTag];
    order.woType = [NSString stringWithFormat:@"woType_%d", shortTag];
    
    
    return order;
}

- (AMWorkOrder *)randomLocalWorkOrder {
    NSInteger iTag = arc4random() % 1000000;
    //	float ilant = (((arc4random() % 100) >= 50) ? (INITLatitude + ((arc4random() % 1000) / 1000.0)) : (INITLatitude - ((arc4random() % 1000) / 1000.0)));
    //	float ilong = (((arc4random() % 100) >= 50) ? (INITLongitude + ((arc4random() % 1000) / 1000.0)) : (INITLongitude - ((arc4random() % 1000) / 1000.0)));
    
    float ilant = INITLatitude;
    float ilong = INITLongitude;
    
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    [dicInfo setObject:[NSNumber numberWithInteger:iTag] forKey:@"TAG"];
    [dicInfo setObject:[NSNumber numberWithFloat:ilant] forKey:@"LANT"];
    [dicInfo setObject:[NSNumber numberWithFloat:ilong] forKey:@"LONG"];
    
    NSDate *estimatedTimeEnd = [AMUtilities dateWithTimeSecond:[AMUtilities daysBefore:(arc4random() % 5) from:[AMUtilities currentTime]]];
    NSDate *estimatedTimeStart = [AMUtilities dateWithTimeSecond:[AMUtilities daysBefore:(0) from:[AMUtilities timeBySecondWithDate:estimatedTimeEnd]] - (arc4random()%(60*60*10))];
    
    NSDate *createDate = [AMUtilities dateWithTimeSecond:[AMUtilities daysBefore:(arc4random() % 3) from:[AMUtilities timeBySecondWithDate:estimatedTimeStart]]];
    NSDate *modifiedDate = [AMUtilities dateWithTimeSecond:[AMUtilities daysLater:(arc4random() % 5) after:[AMUtilities timeBySecondWithDate:estimatedTimeEnd]]];
    
    AMWorkOrder *order = [[AMWorkOrder alloc] init];
    order.accessoriesRequired = [NSString stringWithFormat:@"accessoriesRequired_%d", iTag];
    order.assetID = [NSString stringWithFormat:@"assetID_%d", iTag];
    order.callAhead = [NSNumber numberWithInt:(arc4random() % 10)];
    order.caseID = [NSString stringWithFormat:@"caseID_%d", iTag];
    order.complaintCode = [NSString stringWithFormat:@"complaintCode_%d", iTag];
    order.contact = [NSString stringWithFormat:@"contact_%d", iTag];
    order.createdBy = [NSString stringWithFormat:@"createdBy_%d", iTag];
    order.createdDate = createDate;
    order.estimatedTimeEnd = estimatedTimeEnd;
    order.estimatedTimeStart = estimatedTimeStart;
    order.filterCount = [NSNumber numberWithInt:(arc4random() % 10)];
    order.filterType = [NSString stringWithFormat:@"filterType_%d", iTag];
    order.fromLocation = [NSString stringWithFormat:@"fromLocation_%d", iTag];
    order.lastModifiedBy = [NSString stringWithFormat:@"lastModifiedBy_%d", iTag];
    order.lastModifiedDate = modifiedDate;
    order.latitude = [NSNumber numberWithFloat:ilant];
    order.longitude = [NSNumber numberWithFloat:ilong];
    order.machineType = [NSString stringWithFormat:@"machineType_%d", iTag];
    order.notes = [NSString stringWithFormat:@"notes_%d", iTag];
    order.parkingDetail = [NSString stringWithFormat:@"parkingDetail_%d", iTag];
    order.posID = [NSString stringWithFormat:@"aposID_%d", iTag];
    order.preferrTimeFrom = [NSString stringWithFormat:@"%d:00", iTag];
    order.preferrTimeTo = [NSString stringWithFormat:@"%d:00", iTag];;
    order.priority = [NSString stringWithFormat:@"priority_%d", iTag];
    order.repairCode = [NSString stringWithFormat:@"repairCode_%d", iTag];
    order.status = [NSString stringWithFormat:@"status_%d", iTag];
    order.toLocationID = [NSString stringWithFormat:@"toLocation_%d", iTag];
    order.vendKey = [NSString stringWithFormat:@"vendKey_%d", iTag];
    order.warranty = [NSNumber numberWithInt:(arc4random() % 10)];
    order.woID = [NSString stringWithFormat:@"woID_%d", iTag];
    order.woNumber = [NSString stringWithFormat:@"woNumber_%d", iTag];
    order.workLocation = [NSString stringWithFormat:@"workLocation_%d", iTag];
    order.woType = [NSString stringWithFormat:@"woType_%d", iTag];
    order.ownerID = [NSString stringWithFormat:@"ownerID_%d", iTag];
    order.actualTimeStart = order.estimatedTimeStart;
    order.actualTimeEnd = order.estimatedTimeEnd;
    
    NSInteger shortTag = arc4random() % 100;
    //	order.accountName = [self strWithCharacterNumbers:shortTag];
    order.accountName = [NSString stringWithFormat:@"wo_%d", shortTag];
    
    order.woType = [NSString stringWithFormat:@"woType_%d", shortTag];
    
    
    return order;
}

+ (NSString *)pathWithName:(NSString *)aName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:aName];
}

- (NSMutableArray *)localorderList {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self class] pathWithName:@"LOCALTESTDATA"]]) {
        self.localorderList = [NSMutableArray arrayWithContentsOfFile:[[self class] pathWithName:@"LOCALTESTDATA"]];
    }
    
    if (localorderList && [localorderList count] > 0) {
        return localorderList;
    }
    
    localorderList = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        AMWorkOrder *workOrder = [self randomLocalWorkOrder];
        [localorderList addObject:workOrder];
    }
    
    DLog(@"%@",[[self class] pathWithName:@"LOCALTESTDATA"]);
    
    if (localorderList && [localorderList count] > 0) {
        [localorderList writeToFile:[[self class] pathWithName:@"LOCALTESTDATA"] atomically:YES];
    }
    
    return localorderList;
}

- (NSMutableArray *)refreshLocalOrderList {
    if (localorderList && [localorderList count] > 0) {
        [localorderList removeAllObjects];
    }
    
    return [self localorderList];
}

- (NSMutableArray *)listWithCenter:(CLLocation *)center WorkOrder:(AMWorkOrder *)aWorkOrder andRadius:(CGFloat)aRadius
{
    if (aRadius == 3000) {
        if ([self.localTestList1 count] > 0) {
            return self.localTestList1;
        }
    }
    else if (aRadius == 5000) {
        if ([self.localTestList2 count] > 0) {
            return self.localTestList2;
        }
    }
    else
    {
        if ([self.localTestList3 count] > 0) {
            return self.localTestList3;
        }
    }
    
    NSMutableArray *arrReuslt = [NSMutableArray array];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:INITLatitude longitude:INITLongitude];
    
    for (NSInteger i = 0; i < (NSInteger)aRadius/1000; i ++) {
        CLLocationCoordinate2D coor = [self coordinateFromCoord:location.coordinate atDistanceKm:random()%(NSInteger)aRadius/1000.0 atBearingDegrees:random()%360];
        AMWorkOrder *workOrder = [aWorkOrder mutableCopy];
        workOrder.woID = [NSString stringWithFormat:@"woID_%d",i];
        workOrder.longitude = [NSNumber numberWithFloat:coor.longitude];
        workOrder.latitude = [NSNumber numberWithFloat:coor.latitude];
        
        if (aRadius == 3000) {
            [self.localTestList1 addObject:workOrder];
        }
        else if (aRadius == 5000) {
            [self.localTestList2 addObject:workOrder];
        }
        else
        {
            [self.localTestList3 addObject:workOrder];
        }
    }
    
    if (aRadius == 3000) {
        arrReuslt = localTestList1;
    }
    else if (aRadius == 5000) {
        arrReuslt = localTestList2;
    }
    else
    {
        arrReuslt = localTestList3;
    }
    
    return arrReuslt;
}

- (double)radiansFromDegrees:(double)degrees
{
    return degrees * (M_PI/180.0);
}

- (double)degreesFromRadians:(double)radians
{
    return radians * (180.0/M_PI);
}

- (CLLocationCoordinate2D)coordinateFromCoord:(CLLocationCoordinate2D)fromCoord
                                 atDistanceKm:(double)distanceKm
                             atBearingDegrees:(double)bearingDegrees
{
    double distanceRadians = distanceKm / 6371.0;
    //6,371 = Earth's radius in km
    double bearingRadians = [self radiansFromDegrees:bearingDegrees];
    double fromLatRadians = [self radiansFromDegrees:fromCoord.latitude];
    double fromLonRadians = [self radiansFromDegrees:fromCoord.longitude];
    
    double toLatRadians = asin( sin(fromLatRadians) * cos(distanceRadians) + cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians) );
    double toLonRadians = fromLonRadians + atan2(sin(bearingRadians) * sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians) - sin(fromLatRadians) * sin(toLatRadians));
    
    // adjust toLonRadians to be in the range -180 to +180...
    toLonRadians = fmod((toLonRadians + 3*M_PI), (2*M_PI)) - M_PI;
    
    CLLocationCoordinate2D result;
    result.latitude = [self degreesFromRadians:toLatRadians];
    result.longitude = [self degreesFromRadians:toLonRadians];
    return result;
}

@end
