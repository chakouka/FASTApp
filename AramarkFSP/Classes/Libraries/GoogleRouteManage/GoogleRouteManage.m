//
//  GoogleRouteManage.m
//  Todo
//
//  Created by PwC on 4/14/14.
//  Copyright (c) 2014 viktyz. All rights reserved.
//

#import "GoogleRouteManage.h"

#define MAX_OF_POINTS   8.0

@implementation GoogleRouteManage
@synthesize requestQueue;
@synthesize markerSession;

+(GoogleRouteManage *)sharedInstance
{
    static GoogleRouteManage *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[GoogleRouteManage alloc] init];
        
        sharedManager.requestQueue = [[NSOperationQueue alloc] init];
        [sharedManager.requestQueue setMaxConcurrentOperationCount:1];
        
        NSURLSessionConfiguration *config =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 5.0;
        config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                                        diskCapacity:10 * 1024 * 1024
                                                            diskPath:@"MarkerData"];
        
        sharedManager.markerSession = [NSURLSession sessionWithConfiguration:config];
    });
    
    return sharedManager;
}

#pragma mark -

- (void)fetchRoutes:(NSMutableArray *)routes
         completion:(GoogleOperationCompletionBlock)completion
{
    BACK(^{
        
        [requestQueue cancelAllOperations];
        
        for (GoogleRouteInfo *route in routes) {
            
            NSInvocationOperation *theOp = [[NSInvocationOperation alloc]
                                            initWithTarget:self
                                            selector:@selector(requestRoutesTaskMethod:)
                                            object:@{ @"INFO":route}];
            
            [requestQueue addOperation:theOp];
        }
        
        [requestQueue waitUntilAllOperationsAreFinished];
        
        completion(1,routes,nil);
    });
}

- (void)fetchPoints:(NSMutableArray *)points
           optimize:(BOOL)isOptimize
         completion:(GoogleOperationCompletionBlock)completion
{
    //Get Start Point
    GooglePointInfo *startPoint = nil;
    
    __block NSMutableArray *arrResult = [points mutableCopy];
    
    BOOL existStart = NO;
    
    for (GooglePointInfo *info in points) {
        if (info.gType == PointType_Start) {
            startPoint = info;
            existStart = YES;
            [arrResult removeObject:info];
            break;
        }
    }
    
    if (!existStart) {
        startPoint = [arrResult firstObject];
        [arrResult removeObjectAtIndex:0];
    }
    
    //Remove duplicates
    NSMutableArray *arrTemp = [NSMutableArray array];
    NSMutableArray *arrDuplicates = [NSMutableArray array];
    
    if (isOptimize) {
        for (GooglePointInfo *info in arrResult) {
            
            if ([arrTemp count] == 0)
            {
                [arrTemp addObject:info];
            }
            else
            {
                BOOL exist = NO;
                
                for (GooglePointInfo *existInfo in arrTemp) {
                    
                    if ([info.gLocation distanceFromLocation:existInfo.gLocation] < 0.000001) {
                        
                        exist = YES;
                        [arrDuplicates addObject:info];
                        break;
                    }
                }
                
                if (!exist) {
                    [arrTemp addObject:info];
                }
            }
        }
        
        arrResult = arrTemp;
    }
    else
    {
        if ([arrResult count] > 1)
        {
            for (NSInteger i = 1; i < [arrResult count]; i++) {
                GooglePointInfo *infoPre = [arrResult objectAtIndex:(i - 1)];
                GooglePointInfo *info = [arrResult objectAtIndex:i];
                
                if ([arrTemp count] == 0){
                    [arrTemp addObject:infoPre];
                }
                
                if ([info.gLocation distanceFromLocation:infoPre.gLocation] < 0.000001) {
                    continue;
                }
                else
                {
                    [arrTemp addObject:info];
                }
            }
            
            arrResult = arrTemp;
        }
    }
    
    //Request result
    if ([arrResult count] == 0)
    {
        completion(0,nil,nil);
        return;
    }
    else if ([arrResult count] == 1)
    {
        GooglePointInfo *endPoint = [arrResult firstObject];
        
        NSString *saddr = [NSString stringWithFormat:@"%f,%f", startPoint.gLocation.coordinate.latitude, startPoint.gLocation.coordinate.longitude];
        NSString *daddr = [NSString stringWithFormat:@"%f,%f", endPoint.gLocation.coordinate.latitude, endPoint.gLocation.coordinate.longitude];
        
        NSString *strGoogleRouteAPI = [NSString stringWithFormat:@"/maps/api/directions/json?origin=%@&destination=%@&sensor=true&channel=fast_app", saddr, daddr];
        
        NSString *encodedValue = [strGoogleRouteAPI stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *urlGoogleRouteAPI = [NSURL URLWithString:encodedValue];
        
        [self dataWithURL:urlGoogleRouteAPI completion:^(NSInteger type, id data, NSError *error) {
            if(!data)
            {
                completion(0,nil,nil);//TODO::Need add error check
                return;
            }
            
            id resultInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            GoogleRouteResult *result = [[GoogleRouteResult alloc] initWithInfo:resultInfo fromPoint:startPoint.gLocation.coordinate toPoint:endPoint.gLocation.coordinate];
            
            if (result.routes && [result.routes count] > 0) {
                if(![GoogleUtility isExistDataForURL:urlGoogleRouteAPI]){
                    [GoogleUtility saveData:data withURL:urlGoogleRouteAPI];//保存本地
                }
            }
            
            if (!result) {
                completion(0,nil,nil);//TODO::Need add error check
                return;
            }
            
            GoogleRoute *route = [result.routes firstObject];
            GoogleRouteLeg *leg = [route.legs firstObject];
            
            endPoint.gPolyLine = route.overview_polyLinePoints;
            endPoint.gDuration = leg.duration;
            endPoint.gDistance = leg.distance;
            
            [self assembleResult:arrResult withDuplicateList:arrDuplicates startPoint:startPoint completion:completion];
        }];
    }
    else
    {
        NSString *saddr = [NSString stringWithFormat:@"%f,%f", startPoint.gLocation.coordinate.latitude, startPoint.gLocation.coordinate.longitude];
        NSString *strWayPoints = @"";
        
        for (NSInteger i = 0; i < [arrResult count]; i++) {
            GooglePointInfo *info = [arrResult objectAtIndex:i];
            NSString *strItem = [NSString stringWithFormat:@"%f,%f",info.gLocation.coordinate.latitude, info.gLocation.coordinate.longitude];
            strWayPoints = [strWayPoints stringByAppendingString:[NSString stringWithFormat:@"|%@", strItem]];
        }
        
        NSString *strOpti = isOptimize ? @"true" : @"false";
        NSString *strGoogleRouteAPI = [NSString stringWithFormat:@"/maps/api/directions/json?origin=%@&destination=%@&waypoints=optimize:%@%@&sensor=true&channel=fast_app", saddr,saddr,strOpti, strWayPoints];
        strGoogleRouteAPI = [strGoogleRouteAPI stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *urlGoogleRouteAPI = [NSURL URLWithString:strGoogleRouteAPI];
        
        [self dataWithURL:urlGoogleRouteAPI completion:^(NSInteger type, id data, NSError *error) {
            if(!data)
            {
                completion(0,nil,nil);//TODO::Need add error check
                return;
            }
            
            id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            GoogleRouteResult *routeResult = [[GoogleRouteResult alloc] initWithInfo:result fromPoint:startPoint.gLocation.coordinate toPoint:startPoint.gLocation.coordinate];
            
            if (routeResult.routes && [routeResult.routes count] > 0) {
                if(![GoogleUtility isExistDataForURL:urlGoogleRouteAPI]){
                    [GoogleUtility saveData:data withURL:urlGoogleRouteAPI];//保存本地
                }
            }
            
            GoogleRoute *route = [routeResult.routes firstObject];
            
            if (isOptimize)
            {
                //Resorting
                NSMutableArray *arrOrderTemp = [NSMutableArray array];
                
                NSMutableArray *arrOrder = route.waypoint_order;
                
                [route.legs removeLastObject];
                for (GoogleRouteLeg *leg in route.legs) {
                    
                    NSInteger index = [route.legs indexOfObject:leg];
                    
                    if (index < [arrOrder count]) {
                        index = [[arrOrder objectAtIndex:index] intValue];
                    }
                    
                    GooglePointInfo *info = [arrResult objectAtIndex:index];
                    
                    info.gPolyLine = leg.via_waypoint;
                    info.gDuration = leg.duration;
                    info.gDistance = leg.distance;
                    
                    [arrOrderTemp addObject:info];
                }
                
                arrResult = arrOrderTemp;
                
                [self assembleResult:arrResult withDuplicateList:arrDuplicates startPoint:startPoint completion:completion];
            }
            else
            {
                [route.legs removeLastObject];
                for (GoogleRouteLeg *leg in route.legs) {
                    GooglePointInfo *info = [arrResult objectAtIndex:[route.legs indexOfObject:leg]];
                    
                    info.gPolyLine = leg.via_waypoint;
                    info.gDuration = leg.duration;
                    info.gDistance = leg.distance;
                }
                
                [self mergeResult:arrResult withPoints:points completion:completion];
            }
        }];
    }
}

#pragma mark -

- (void)fetchRouteFromLocation:(CLLocation *)origin
                    toLocation:(CLLocation *)destination
                          mode:(NaviMode)mode
                    completion:(GoogleOperationCompletionBlock)completion
{
    NSString *saddr = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString *daddr = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
    
    //组装路段请求链接
    NSString *strGoogleRouteAPI = [NSString stringWithFormat:@"/maps/api/directions/json?origin=%@&destination=%@&sensor=true&channel=fast_app", saddr, daddr];
    
    if (!strGoogleRouteAPI) {
        completion(0,nil,nil);
        return;
    }
    
    NSString *encodedValue = [strGoogleRouteAPI stringByAddingPercentEncodingWithAllowedCharacters :[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *urlGoogleRouteAPI = [NSURL URLWithString:encodedValue];
    
    [self dataWithURL:urlGoogleRouteAPI completion:^(NSInteger type, id data, NSError *error) {
        if(!data){
            completion(0,nil,nil);
            return ;
        }
        
        //解析数据
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        GoogleRouteResult *routeResult = [[GoogleRouteResult alloc] initWithInfo:result fromPoint:origin.coordinate toPoint:destination.coordinate];
        
        if (routeResult.routes && [routeResult.routes count] > 0){
            if(![GoogleUtility isExistDataForURL:urlGoogleRouteAPI]){
                [GoogleUtility saveData:data withURL:urlGoogleRouteAPI];//保存本地
            }
        }
        
        completion(1,routeResult,nil);
    }];
}

#pragma mark -

- (void)requestRoutesTaskMethod:(id)Info {
    
    GoogleRouteInfo *aRoute = [Info objectForKey:@"INFO"];
    
    //请求路段信息
    [self fetchRouteFromLocation:aRoute.gFrom
                      toLocation:aRoute.gTo
                            mode:kModeDriving
                      completion:^(NSInteger type, id result, NSError *error) {
                          
                          //完善路段信息
                          if (result) {
                              GoogleRoute *route = [((GoogleRouteResult *)result).routes firstObject];
                              GoogleRouteLeg *leg = [route.legs firstObject];
                              aRoute.gPolyLine = route.overview_polyLinePoints;
                              aRoute.gDuration = leg.duration;
                              aRoute.gDistance = leg.distance;
                          }
                      }];
}

#pragma mark -

-(void)mergeResult:(NSMutableArray *)arrResult
        withPoints:(NSMutableArray *)arrPoints
        completion:(GoogleOperationCompletionBlock)completion
{
    for (GooglePointInfo *point in arrPoints) {
        for (GooglePointInfo *info in arrResult) {
            if ([point.gId isEqualToString:info.gId]) {
                point.gPolyLine = info.gPolyLine;
                point.gDuration = info.gDuration ;
                point.gDistance = info.gDistance;
                break;
            }
        }
    }
    
    completion(1,[arrPoints copy],nil);
}

-(void)assembleResult:(NSMutableArray *)arrResult
    withDuplicateList:(NSMutableArray *)arrDuplicates
           startPoint:(GooglePointInfo *)startPoint
           completion:(GoogleOperationCompletionBlock)completion
{
    //assemble result
    [arrResult insertObject:startPoint atIndex:0];
    
    NSMutableArray *arrTempResult = [NSMutableArray arrayWithArray:arrResult];
    
    for (GooglePointInfo *info in arrResult) {
        
        NSMutableArray *arrExist = [NSMutableArray array];
        
        for (GooglePointInfo *dupInfo in arrDuplicates) {
            if ([dupInfo.gLocation distanceFromLocation:info.gLocation] < 0.000001) {
                [arrExist addObject:dupInfo];
            }
        }
        
        if ([arrExist count] > 0) {
            NSInteger index = [arrTempResult indexOfObject:info];
            for (GooglePointInfo *existInfo in arrExist) {
                
                BOOL existInList = NO;
                
                for (GooglePointInfo *exist in arrTempResult) {
                    if ([exist.gId isEqualToString:existInfo.gId]) {
                        existInList = YES;
                        break;
                    }
                }
                
                if (!existInList) {
                    [arrTempResult insertObject:existInfo atIndex:(index + 1)];
                }
            }
        }
    }
    
    arrResult = arrTempResult;
    
    completion(1,[arrResult copy],nil);
}

- (void)dataWithURL:(NSURL *)aURL
         completion:(GoogleOperationCompletionBlock)completion
{
    if ([GoogleUtility isExistDataForURL:aURL]) {
        NSData *data = [GoogleUtility dataWithURL:aURL];
        completion(1,data,nil);
    }
    else {
        
        NSString *strURL = [GoogleUtility finalDirectionURL:[aURL absoluteString]];
        
        NSLog(@"Route Data Request From Net ... : %@",strURL);
        
        BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable];
        if (!isNetworkReachable) {
            NSLog(@"Google Server disconnected ... : %@",strURL);
            completion(0,nil,nil);
            return;
        }
        
        NSURLSessionDataTask *directionsTask = [self.markerSession dataTaskWithURL:[NSURL URLWithString:strURL]
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *e) {
                                                                     if (!e) {
                                                                         NSLog(@"Route Data Request Finished Success");
                                                                         completion(1,data,nil);
                                                                     }
                                                                     else
                                                                     {
                                                                         NSLog(@"Route Data Request Finished Failed : %@",[e localizedDescription]);
                                                                         completion(0,nil,nil);
                                                                     }
                                                                 }];
        [directionsTask resume];
    }
}

@end
