//
//  AMProtocolManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/6/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMProtocolManager.h"
#import "AMSFRequest.h"
#import "AMMutableURLRequest.h"
#import "SFRestAPI.h"
#import "SFNetworkEngine.h"
#import "SFOAuthCoordinator.h"
#import "SFOAuthCredentials.h"
#import "SFRestAPI+Blocks.h"
#import "AMProtocolParser.h"
#import "AMProtocolAssembler.h"
#import "AMDBNewCase+AddOn.h"
#import "AMDBNewWorkOrder.h"
//#import "SFAccountManager.h"
#import "SFAuthenticationManager.h"
#import "SFIdentityData.h"
#import "AMDBNewLead+Addition.h"

@implementation AMProtocolManager

#pragma mark - Internal Methods
- (NSDictionary *)transferJsonResponseToDictionary:(id)jsonResponse
{
    NSError *parseError = nil;
    NSDictionary *dic = nil;
    
    if ([jsonResponse isKindOfClass:[NSDictionary class]]) {
        dic = jsonResponse;
    }
    else {
        dic = [NSJSONSerialization JSONObjectWithData:jsonResponse  options:NSJSONReadingAllowFragments error:&parseError];
    }
    
    DLog(@"%@",[dic description]);
    if (parseError) {
        DLog(@"transferJsonResponseToDictionary parseError=%@",[parseError description]);
    }
    return dic;
}

- (NSString *)getHttpParamsString:(NSDictionary *)paramDict
{
    NSMutableString * paramString = [NSMutableString string];
    NSArray * paramKeys = [paramDict allKeys];
    
    if (paramKeys.count) {
        [paramString appendString:@"?"];
        for (NSString * key in paramKeys) {
            [paramString appendString:[NSString stringWithFormat:@"%@=%@&",key,[paramDict objectForKey:key]]];
        }
        paramString = [[paramString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]] mutableCopy];
    }
    return paramString;
}

#pragma mark - Methods

+ (AMProtocolManager *)sharedInstance
{
    static AMProtocolManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMProtocolManager alloc] init];
    });
    
    return sharedInstance;
}

//- (NSDate *)getTZTimeByLocalTime:(NSDate *)localDate
//{
//    return [[AMProtocolParser sharedInstance] getTZTimeByLocalTime:localDate];
//}

- (void)getSelfUserInfo:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.method = SFRestMethodGET;
    request.path = @"/User";
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETUSERINFO;
    request.completionBlock = completionBlock;
    
    SFRestAPI * restApi = [SFRestAPI sharedInstance] ;
    SFOAuthCoordinator * coordinator = restApi.coordinator;
    SFOAuthCredentials * credential = coordinator.credentials;
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:credential.userId forKey:@"uid"];
    request.queryParams = param;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getSelfUserInfo error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getSelfUserInfo response");
        
        AMUser * parsedUser = nil;
        NSDictionary * parsedDict = nil;
        NSMutableDictionary * finalRetDict = [NSMutableDictionary dictionary];
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseUserInfoList:dict];
        if ([[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            NSArray * retArray = [parsedDict objectForKey:NWRESPDATA];
            if (retArray && retArray.count) {
                parsedUser = [retArray objectAtIndex:0];
            }
        }
        
        if ([parsedDict objectForKey:NWRESPRESULT]) {
            [finalRetDict setObject:[parsedDict objectForKey:NWRESPRESULT] forKey:NWRESPRESULT];
        }
        if ([parsedDict objectForKey:NWTIMESTAMP]) {
            [finalRetDict setObject:[parsedDict objectForKey:NWTIMESTAMP] forKey:NWTIMESTAMP];
        }
        
        if (parsedUser) { //Setup Application Language by User Profile Language - changed on 10/24/2014
            if ([parsedDict objectForKey:USER_LANGUAGE]) {
                if ([@"fr" isEqualToString:[parsedDict objectForKey:USER_LANGUAGE]]) {
                    if ([LanguageConfig applicationLanguageChanged:LanguageType_French]){
                        [LanguageConfig setLanguage:LanguageType_French];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_SWITCH_LANGUAGE object:nil];
                    }
                } else {
                    if ([LanguageConfig applicationLanguageChanged:LanguageType_English]){
                        [LanguageConfig setLanguage:LanguageType_English];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_SWITCH_LANGUAGE object:nil];
                    }
                    
                }
            }
            if ([parsedDict objectForKey:NWMARKETCENTEREMAIL]) {
                parsedUser.marketCenterEmail = [parsedDict objectForKey:NWMARKETCENTEREMAIL];
            }
            [finalRetDict setObject:parsedUser forKey:NWRESPDATA];
        }
        
        NSError * retError = nil;
        if (![[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            if ([parsedDict objectForKey:NWERRORMSG]) {
                retError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@",[parsedDict objectForKey:NWERRORMSG]]}];
            }
        }
        
        request.completionBlock(request.type,retError,request.userData,finalRetDict);
    }];

}

- (void)getUserList:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.method = SFRestMethodGET;
    request.path = @"/User";
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETUSERLIST;
    request.completionBlock = completionBlock;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getUserList error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getUserList response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseUserInfoList:dict];
        NSError * retError = nil;
        if (![[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            if ([parsedDict objectForKey:NWERRORMSG]) {
                retError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@",[parsedDict objectForKey:NWERRORMSG]]}];
            }
        }

        request.completionBlock(request.type,retError, request.userData,parsedDict);
    }];
    
}

- (void)getOwnRecentWorkOrderList:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.method = SFRestMethodGET;
    request.path = @"/WorkOrder";
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETWOLST;
    request.completionBlock = completionBlock;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getOwnRecentWorkOrderList error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getOwnRecentWorkOrderList response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseWorkOrderInfoList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];

}

- (void)getWorkOrderListByType:(AM_NWWOLIST_Type)type timeStamp:(NSDate *)timeStamp withIDList:(NSArray *)idList completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETWOLST;
    request.completionBlock = completionBlock;
    
    NSMutableDictionary * userData = [[NSMutableDictionary alloc] init];
    NSString * woType = @"";
    SFRestMethod method = SFRestMethodPOST;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * urlParamDict = [NSMutableDictionary dictionary];
    NSString * pathStr = nil;
    
    switch (type) {
        case AM_NWWOLIST_RECENT:
            woType = @"past5";
            break;
         case AM_NWWOLIST_BYACCOUNT:
            woType = @"account";
            break;
         case AM_NWWOLIST_BYASSET:
            woType = @"asset";
            break;
         case AM_NWWOLIST_BYCASE:
            woType = @"case";
            break;
         case AM_NWWOLIST_BYPOS28:
            woType = @"pos28";
            break;
         case AM_NWWOLIST_BYPOS:
            woType = @"pos";
        default:
            break;
    }
    
    if (idList) {
        [paramDict setObject:idList forKey:@"idList"];
    } else {
        [paramDict setObject:@[] forKey:@"idList"];
    }
    [paramDict setObject:woType forKey:@"act"];
    
    if (type == AM_NWWOLIST_RECENT) {
        [urlParamDict setObject:@"14" forKey:@"past"];
    }
    
    [userData setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    if (timeStamp) {
        [userData setObject:timeStamp forKey:@"timeStamp"];
    }
    request.userData = userData;
    request.method = method;
    request.queryParams = paramDict;
    
    
    if (timeStamp) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
        [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        [urlParamDict setObject:[dateFormat stringFromDate:timeStamp] forKey:@"stamp"];
    }
    pathStr = [NSString stringWithFormat:@"/WorkOrder%@",[self getHttpParamsString:urlParamDict]];
    request.path = pathStr;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getWorkOrderListByType %@ error info %@",woType,[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getWorkOrderListByType %@ response",woType);
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseWorkOrderInfoList:dict];
        NSError * retError = nil;
        if (![[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            if ([parsedDict objectForKey:NWERRORMSG]) {
                retError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@",[parsedDict objectForKey:NWERRORMSG]]}];
            }
        }

        request.completionBlock(request.type,retError, request.userData,parsedDict);
    }];

}

- (void)getAccountsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETACCOUNTLST;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPOST;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * urlParamDict = [NSMutableDictionary dictionary];
    NSString * pathStr = nil;
    
    if (idList) {
        [paramDict setObject:idList forKey:@"accountIDList"];
    }
    
    if (timeStamp) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
        [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        [urlParamDict setObject:[dateFormat stringFromDate:timeStamp] forKey:@"stamp"];
    }
    request.method = method;
    request.queryParams = paramDict;
    
    pathStr = [NSString stringWithFormat:@"/Account%@",[self getHttpParamsString:urlParamDict]];
    request.path = pathStr;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getAccountsWithIDList %@ error info %@",[timeStamp description],[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getAccountsWithIDList %@ response",[timeStamp description]);
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseAccountList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
    

}

- (void)getAssetsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETASSETLST;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPOST;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * urlParamDict = [NSMutableDictionary dictionary];
    NSString * pathStr = nil;
    
    if (idList) {
        [paramDict setObject:idList forKey:@"assetIDList"];
    }
    
    if (timeStamp) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
        [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        [urlParamDict setObject:[dateFormat stringFromDate:timeStamp] forKey:@"stamp"];
    }
    request.method = method;
    request.queryParams = paramDict;
    
    pathStr = [NSString stringWithFormat:@"/Asset%@",[self getHttpParamsString:urlParamDict]];
    request.path = pathStr;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getAssetsWithIDList %@ error info %@",[timeStamp description],[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getAssetsWithIDList %@ response",[timeStamp description]);
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseAssetList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
    
    
}

- (void)getLocationsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETLOCATIONLST;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPOST;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * urlParamDict = [NSMutableDictionary dictionary];
    NSString * pathStr = nil;
    
    if (idList) {
        [paramDict setObject:idList forKey:@"accountIDList"];
    }
    
    if (timeStamp) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
        [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        [urlParamDict setObject:[dateFormat stringFromDate:timeStamp] forKey:@"stamp"];
    }
    request.method = method;
    request.queryParams = paramDict;
    
    pathStr = [NSString stringWithFormat:@"/Location%@",[self getHttpParamsString:urlParamDict]];
    request.path = pathStr;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getLocationsWithIDList %@ error info %@",[timeStamp description],[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getLocationsWithIDList %@ response",[timeStamp description]);
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseLocationList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
}

- (void)getInvoicesWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETINVOICELST;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPOST;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * urlParamDict = [NSMutableDictionary dictionary];
    NSString * pathStr = nil;
    
    if (idList) {
        [paramDict setObject:idList forKey:@"workerorderIDList"];
    }
    
    if (timeStamp) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
        [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        [urlParamDict setObject:[dateFormat stringFromDate:timeStamp] forKey:@"stamp"];
    }
    request.method = method;
    request.queryParams = paramDict;
    
    pathStr = [NSString stringWithFormat:@"/Invoice%@",[self getHttpParamsString:urlParamDict]];
    request.path = pathStr;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getInvoicesWithIDList %@ error info %@",[timeStamp description],[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getInvoicesWithIDList %@ response",[timeStamp description]);
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseInvoiceList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];

}

- (void)getPoSsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETPOSLST;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPOST;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * urlParamDict = [NSMutableDictionary dictionary];
    NSString * pathStr = nil;
    
    if (idList) {
        [paramDict setObject:idList forKey:@"posIDList"];
    }
    
    if (timeStamp) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
        [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        [urlParamDict setObject:[dateFormat stringFromDate:timeStamp] forKey:@"stamp"];
    }
    request.method = method;
    request.queryParams = paramDict;
    
    pathStr = [NSString stringWithFormat:@"/PoS%@",[self getHttpParamsString:urlParamDict]];
    request.path = pathStr;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getPoSsWithIDList %@ error info %@",[timeStamp description],[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getPoSsWithIDList %@ response",[timeStamp description]);
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parsePoSList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];

}

- (void)getPoSContactsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETCONTACTLST;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPOST;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * urlParamDict = [NSMutableDictionary dictionary];
    NSString * pathStr = nil;
    
    if (idList) {
        [paramDict setObject:idList forKey:@"posIDList"];
    }
    
    if (timeStamp) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
        [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        [urlParamDict setObject:[dateFormat stringFromDate:timeStamp] forKey:@"stamp"];
    }
    request.method = method;
    request.queryParams = paramDict;
    
    pathStr = [NSString stringWithFormat:@"/PoSContact%@",[self getHttpParamsString:urlParamDict]];
    request.path = pathStr;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getPoSContactsWithIDList %@ error info %@",[timeStamp description],[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getPoSContactsWithIDList %@ response",[timeStamp description]);
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parsePoSContactList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
}

- (void)getPartsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETPARTLST;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPOST;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * urlParamDict = [NSMutableDictionary dictionary];
    NSString * pathStr = nil;
    
    if (idList) {
        [paramDict setObject:idList forKey:@"assetIDList"];
    }
    
    if (timeStamp) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
        [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        [urlParamDict setObject:[dateFormat stringFromDate:timeStamp] forKey:@"stamp"];
    }
    request.method = method;
    request.queryParams = paramDict;
    
    pathStr = [NSString stringWithFormat:@"/Part%@",[self getHttpParamsString:urlParamDict]];
    request.path = pathStr;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getPartsWithIDList %@ error info %@",[timeStamp description],[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getPartsWithIDList %@ response",[timeStamp description]);
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parsePartsList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];

}

- (void)getFiltersWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock
{
    
}

- (void)getCasesWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETCASELST;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPOST;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * urlParamDict = [NSMutableDictionary dictionary];
    NSString * pathStr = nil;
    
    if (idList) {
        [paramDict setObject:idList forKey:@"postIDList"];
    }
    
    if (timeStamp) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
        [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        [urlParamDict setObject:[dateFormat stringFromDate:timeStamp] forKey:@"stamp"];
    }
    request.method = method;
    request.queryParams = paramDict;
    
    pathStr = [NSString stringWithFormat:@"/Case%@",[self getHttpParamsString:urlParamDict]];
    request.path = pathStr;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getCasesWithIDList %@ error info %@",[timeStamp description],[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getCasesWithIDList %@ response",[timeStamp description]);
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseCaseList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
}

- (void)downloadPhotoWithUrl:(NSString *)urlString completion:(AMSFRestCompletionBlock)completionBlock
{
    NSURL * url = nil;
    url = [[NSURL alloc] initWithString:urlString];
    AMMutableURLRequest * request = [[AMMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    SFOAuthCoordinator *coordinator=[SFRestAPI sharedInstance].coordinator;
    SFOAuthCredentials *credentials= coordinator.credentials;
    [request addValue:[NSString stringWithFormat:@"OAuth %@", credentials.accessToken] forHTTPHeaderField:@"Authorization"];
    
    request.type = AM_REQUEST_GETPHOTO;
    NSMutableDictionary * userData = [[NSMutableDictionary alloc] init];
    [userData setObject:urlString forKey:@"urlString"];
    request.userData = userData;
    request.completionBlock = completionBlock;
    
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
        if (error) {
            DLog(@"downloadPhotoWithUrl error %@",urlString);
            request.completionBlock(request.type,error,request.userData,nil);
        }else{
            DLog(@"downloadPhotoWithUrl success %@",urlString);
            NSMutableDictionary * parsedDict = [NSMutableDictionary dictionary];
            
            [parsedDict setObject:[NSNumber numberWithInt:YES] forKey:NWRESPRESULT];
            [parsedDict setObject:data forKey:NWRESPDATA];
            
            request.completionBlock(request.type,nil,request.userData,parsedDict);
        }
    }];
    
}

- (void)uploadPhotos:(NSArray *)photoArray completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_UPLOADSIGNATURE;
    request.completionBlock = completionBlock;
    request.method = SFRestMethodPUT;
    request.path = @"/Signature";
    
    NSMutableDictionary * userDict = [NSMutableDictionary dictionary];
    if (photoArray) {
        [userDict setObject:photoArray forKey:@"photoArray"];
    }
    request.userData = userDict;
    
    request.queryParams = [[AMProtocolAssembler sharedInstance] uploadSignatureWithData:photoArray];
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"uploadPhotos error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"uploadPhotos response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseUploadPhoto:dict];
        NSError * retError = nil;
        if (![[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            if ([parsedDict objectForKey:NWERRORMSG]) {
                retError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@",[parsedDict objectForKey:NWERRORMSG]]}];
            }
        }

        request.completionBlock(request.type,retError, request.userData,parsedDict);
    }];

    
    /*NSMutableString *hostUrl=[NSMutableString string];
    SFNetworkEngine *engine=[SFNetworkEngine sharedInstance];
    NSString *portNumber=@"";
    portNumber=engine.coordinator.sslPortNumber?[NSString stringWithFormat:@":%d",[engine.coordinator.sslPortNumber intValue]]:@"";
    [hostUrl appendString:[NSString stringWithFormat:@"https://%@%@/services/apexrest/Signature",engine.coordinator.host,portNumber]];
    DLog(@"upload photo url :%@",hostUrl);
    NSURL *url=nil;
    url=[[NSURL alloc]initWithString:hostUrl];
    AMMutableURLRequest * request = [[AMMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"PUT"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    SFOAuthCoordinator *coordinator=[SFRestAPI sharedInstance].coordinator;
    SFOAuthCredentials *credentials= coordinator.credentials;
    [request addValue:[NSString stringWithFormat:@"OAuth %@", credentials.accessToken] forHTTPHeaderField:@"Authorization"];
    
    request.type = AM_REQUEST_GETPHOTO;
    request.completionBlock = completionBlock;
    
    NSDictionary * jsonDict = [[AMProtocolAssembler sharedInstance] uploadSignatureWithData:photoArray];
    
    NSError *error=nil;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    
    [request setHTTPBody:postData];

    
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
        if (error) {
            DLog(@"uploadPhotos error info %@",error);
            request.completionBlock(request.type,error,request.userData,nil);
        }else{
            DLog(@"uploadPhotos response");
            NSDictionary * parsedDict = nil;
            NSDictionary * dict = [self transferJsonResponseToDictionary:data];
            
            parsedDict = [[AMProtocolParser sharedInstance] parseCaseList:dict];
            request.completionBlock(request.type,nil, request.userData,parsedDict);
        }
    }];*/

}

- (void)uploadAttachments:(NSArray *)attachments completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_UPLOADSIGNATURE;
    request.completionBlock = completionBlock;
    request.method = SFRestMethodPUT;
    request.path = @"/Attachment";
    
    NSMutableDictionary * userDict = [NSMutableDictionary dictionary];
    if (attachments) {
        [userDict setObject:attachments forKey:@"attachments"];
    }
    request.userData = userDict;
    
    request.queryParams = [[AMProtocolAssembler sharedInstance] parameterDictionaryFromAttachments:attachments];
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"upload attachments error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"upload attachments response");
        
        NSDictionary * responseDict = [self transferJsonResponseToDictionary:jsonResponse];

        BOOL isSuccess = ((NSNumber *)[responseDict valueForKeyWithNullToNil:@"isSuccess"]).boolValue;
        if (!isSuccess) {
            // handle error
            
            for (AMDBAttachment *newAttachment in attachments)
            {
                newAttachment.dataStatus = @(EntityStatusSyncFail);
                newAttachment.errorMessage = responseDict[@"errorMessage"];
            }
            
        } else {
            
            NSDictionary *mapDict = [responseDict valueForKeyPathWithNullToNil:@"idMap.Attachment"];
            
            if ([mapDict isKindOfClass:[NSDictionary class]]) {
                for (AMDBAttachment *attachment in attachments) {
                    if ([[mapDict allKeys] containsObject:attachment.fakeID]) {
                        attachment.id = mapDict[attachment.fakeID];
                        attachment.dataStatus = @(EntityStatusSyncSuccess);
                    } else {
                        attachment.dataStatus = @(EntityStatusSyncFail);
                    }
                }
            }
        }
        
        [[AMLogicCore sharedInstance] saveManagedObject:attachments.firstObject completion:^(NSInteger type, NSError *error) {
            if (error) {
                DLog(@"save new case error: %@", error.localizedDescription);
            }
        }];
        
        request.completionBlock(request.type, nil, request.userData, responseDict);
    }];
}


- (void)getInitialLoad:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETINITIALLOAD;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodGET;
    request.method = method;
    
    request.path = @"/BusinessProcess";
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getInitialLoad error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getInitialLoad response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseInitialLoad:dict];
        NSError * retError = nil;
        if (![[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            if ([parsedDict objectForKey:NWERRORMSG]) {
                retError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@",[parsedDict objectForKey:NWERRORMSG]]}];
            }
        }

        request.completionBlock(request.type,retError, request.userData,parsedDict);
    }];

}

- (void)createObjectsWithData:(NSDictionary *)createObj oprationType:(NSInteger)oprType completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = oprType;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPUT;
    request.method = method;
    request.path = @"/BusinessProcess";
    
    NSDictionary * bodyDict = [[AMProtocolAssembler sharedInstance] createObjectWithData:createObj];
    
    request.queryParams = bodyDict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"createObjectsWithData error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"createObjectsWithData response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseCreateObjectList:dict];
        NSError * retError = nil;
        if (![[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            if ([parsedDict objectForKey:NWERRORMSG]) {
                retError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@",[parsedDict objectForKey:NWERRORMSG]]}];
            }
        }

        request.completionBlock(request.type,retError, request.userData,parsedDict);
    }];

}

- (void)deleteObjectWithData:(NSDictionary *)deleteObj completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_DELETECONTACTS;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPATCH;
    request.method = method;
    request.path = @"/Contact";
    request.userData = deleteObj;
    
    NSDictionary * bodyDict = [[AMProtocolAssembler sharedInstance] deleteObjectWithData:deleteObj];
    
    request.queryParams = bodyDict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"deleteObjectWithData error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"deleteObjectWithData response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseUpdateObjectList:dict];
        NSError * retError = nil;
        if (![[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            if ([parsedDict objectForKey:NWERRORMSG]) {
                retError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@",[parsedDict objectForKey:NWERRORMSG]]}];
            }
        }
        
        request.completionBlock(request.type,retError, request.userData,parsedDict);
    }];
}

- (void)updateObjectWithData:(NSDictionary *)updateObj completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_UPDATEOBJECTS;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPATCH;
    request.method = method;
    request.path = @"/BusinessProcess";
    request.userData = updateObj;
    
    NSDictionary * bodyDict = [[AMProtocolAssembler sharedInstance] updateObjectWithData:updateObj];
    
    request.queryParams = bodyDict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"updateObjectWithData error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"updateObjectWithData response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseUpdateObjectList:dict];
        NSError * retError = nil;
        if (![[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            if ([parsedDict objectForKey:NWERRORMSG]) {
                retError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@",[parsedDict objectForKey:NWERRORMSG]]}];
            }
        }

        request.completionBlock(request.type,retError, request.userData,parsedDict);
    }];
}

- (void)syncDataWithTimeStamp:(NSDate *)timeStamp completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_SYNCOBJECTS;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPOST;
    request.method = method;
    
    // 14/8/14 upload work order and event id for current use
    //         upload all ids for future use
//    request.path = @"/BusinessProcess";
//    NSDictionary *idDict = [[AMProtocolAssembler sharedInstance] dictionaryWithWorkOrderAndEventIDsForSync];

    request.path = @"/Sync";
    NSDictionary *idDict = [[AMProtocolAssembler sharedInstance] dictionaryWithAllEntityIDsForSync];

    NSMutableDictionary * bodyDictionary = [NSMutableDictionary dictionaryWithDictionary:idDict];

    if (timeStamp) {
        [bodyDictionary setObject:[[AMProtocolParser sharedInstance] dateStringForSalesforceFromDate: timeStamp] forKey:@"timeStamp"];
    } else {
        NSError *error = [NSError errorWithDomain:@"sync" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"Sync with no timestamp. Please logout and re-login.")}];
        request.completionBlock(request.type, error, nil, nil);
        return;
    }

#if DEBUG
    NSError * error = nil;
    NSData * postData = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:&error];
    DLog(@"sync obj: %@",[[NSString alloc]initWithData:postData encoding:NSUTF8StringEncoding]);
#endif
    request.queryParams = bodyDictionary;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"syncDataWithTimeStamp error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"syncDataWithTimeStamp response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseSyncObjectList:dict];
        NSError * retError = nil;
        if (![[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            if ([parsedDict objectForKey:NWERRORMSG]) {
                retError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@",[parsedDict objectForKey:NWERRORMSG]]}];
            }
        }

        request.completionBlock(request.type,retError, request.userData,parsedDict);
    }];
}

- (void)assignSelfWO:(NSString *)woID completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_ASSIGNSELFWO;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPATCH;
    request.method = method;
    
    request.path = @"/WorkOrder";
    
    NSMutableDictionary * bodyDict = [NSMutableDictionary dictionary];
    if (woID) {
        [bodyDict setObject:woID forKey:@"workorderID"];
    }
    request.queryParams = bodyDict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"assignSelfWO error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"assignSelfWO response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseInitialLoad:dict];
        
        NSError * retError = nil;
        if (![[parsedDict objectForKey:NWRESPRESULT] intValue]) {
            if ([parsedDict objectForKey:NWERRORMSG]) {
                retError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@",[parsedDict objectForKey:NWERRORMSG]]}];
            }
        }
        request.completionBlock(request.type,retError, request.userData,parsedDict);
    }];

}

- (void)setAssetPoS:(NSArray *)assetList completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_SETASSETPOS;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPATCH;
    request.method = method;
    
    NSMutableDictionary * userDict = [NSMutableDictionary dictionary];
    if (assetList) {
        [userDict setObject:assetList forKey:@"assetList"];
    }
    request.userData = userDict;
    
    request.path = @"/Asset";
    
    NSDictionary * bodyDict = [[AMProtocolAssembler sharedInstance] setPoSAsset:assetList];
    request.queryParams = bodyDict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"setAssetPoS error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"setAssetPoS response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseAssetToPoS:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];

}

- (void)getTestList:(AMSFRestCompletionBlock)completionBlock
{
    
    
    /*request.method = SFRestMethodPOST;
     request.path = @"/RESTONE";
     request.endpoint = @"/services/apexrest";
     request.type = AM_REQUEST_GETWOLST;
     request.completionBlock = completionBlock;
     
     [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
     DLog(@"getUserList error info %@",[error description]);
     request.completionBlock(request.type,error,request.userData,nil);
     } completeBlock:^(id jsonResponse){
     DLog(@"getUserList user info response");
     
     NSDictionary * parsedDict = nil;
     NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
     
     parsedDict = [[AMProtocolParser sharedInstance] parseWorkOrderInfoList:dict];
     request.completionBlock(request.type,nil, request.userData,parsedDict);
     }];*/
    
    NSMutableString *hostUrl=[NSMutableString string];
    SFNetworkEngine *engine=[SFNetworkEngine sharedInstance];
    NSString *portNumber=@"";
    portNumber=engine.coordinator.sslPortNumber?[NSString stringWithFormat:@":%d",[engine.coordinator.sslPortNumber intValue]]:@"";
    [hostUrl appendString:[NSString stringWithFormat:@"https://aramark--demo.cs16.my.salesforce.com%@/services/apexrest/WorkOrder",portNumber]];
    NSURL *url=nil;
    url=[[NSURL alloc]initWithString:hostUrl];
    AMMutableURLRequest * request = [[AMMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    SFOAuthCoordinator *coordinator=[SFRestAPI sharedInstance].coordinator;
    SFOAuthCredentials *credentials= coordinator.credentials;
    [request addValue:[NSString stringWithFormat:@"OAuth %@", credentials.accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSMutableArray *tempArr=[NSMutableArray array];
    NSMutableDictionary * jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:@"sf test" forKey:@"test"];
    [tempArr addObject:jsonDict];
    
    NSError *error=nil;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    
    [request setHTTPBody:postData];
    NSOperationQueue *queue=nil;
    queue=[[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount=1;
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
        if (error) {
            DLog(@"error");
        }else{
            DLog(@"success");
            DLog(@"a:%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
    
    
    
}

- (void)getTestPostList:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.method = SFRestMethodPOST;
    request.path = @"/WorkOrder";
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETWOLST;
    request.completionBlock = completionBlock;
    
    NSMutableDictionary * jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:@"sf test" forKey:@"test"];
    request.queryParams = jsonDict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getUserList error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getUserList user info response");
        DLog(@"a:%@",[[NSString alloc]initWithData:jsonResponse encoding:NSUTF8StringEncoding]);
    }];
}

#pragma mark - Create Contact, Case, Work Order, Lead
- (void)createObjectsWithManagedObjects:(NSArray *)managedObjects operationType:(NSInteger)oprType completion:(AMSFRestCompletionBlock)completionBlock
{
    if (![managedObjects count]) {
        return;
    }
    
    NSString *path = nil;
    NSString *topLevelKey = nil;
    id object = managedObjects.lastObject;
    if ([object isKindOfClass:[AMDBNewCase class]]) {
        path = @"/Case";
        topLevelKey = @"lstMapCreateCaseKeyValue";
    } else if ([object isKindOfClass:[AMDBNewWorkOrder class]]) {
        path = @"/WorkOrder";
        topLevelKey = @"lstMapCreateWorkOrderKeyValue";
    } else if ([object isKindOfClass:[AMDBNewContact class]]) {
        path = @"/Contact";
        topLevelKey = @"lstMapCreateContactKeyValue";
    }
    if (!path || !topLevelKey) {
        return;
    }
    
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = oprType;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPUT;
    request.method = method;
    request.path = path;
    
    NSMutableArray *array = [NSMutableArray array];
    for (id obj in managedObjects) {
        if ([obj respondsToSelector:@selector(dictionaryToCreateObject)]) {
            [array addObject:[obj dictionaryToCreateObject]];
        } else {
            NSError *error = [NSError errorWithDomain:@"com.pwc.AramarkFSP" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"Create Order Assembly Failed.")}];
            request.completionBlock(request.type, error, request.userData, nil);
        }
    }
    request.queryParams = @{topLevelKey: array};
    
    DLog(@" %@", [request.queryParams description]);
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request
                                      failBlock:^(NSError *error){
        DLog(@"createObjectsWithData error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"createObjectsWithData response");
        
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        request.completionBlock(request.type,nil, request.userData,dict);
    }];
    
}


-(void)uploadCreatedCasesWithCompletion:(AMSFRestCompletionBlock)completionBlock;
{
    DLog(@"start upload created cases");
    
    NSArray *createdCases = [[AMDBManager sharedInstance] getCreatedCases];
    if (!createdCases.count) {
        completionBlock(AM_REQUEST_ADDCASE, nil, nil,nil);
        return;
    }
    
    [[AMProtocolManager sharedInstance]
     createObjectsWithManagedObjects:createdCases
     operationType:AM_REQUEST_ADDCASE
     completion:^(NSInteger type, NSError *error, id userData, id responseData) {
         DLog(@"finish upload created cases");

         BOOL isSuccess = ((NSNumber *)[responseData valueForKeyWithNullToNil:@"isSuccess"]).boolValue;
         if (error || !isSuccess) {
             // handle error
             
             for (AMDBNewCase *newCase in createdCases)
             {
                 newCase.dataStatus = @(EntityStatusSyncFail);
                 newCase.errorMessage = responseData[@"errorMessage"];
             }
             
         } else {
             NSArray *newCases = [responseData valueForKeyPathWithNullToNil:@"dataListMap.Add.Case"];
             NSMutableArray *caseModels = [NSMutableArray array];
             for (NSDictionary *caseDict in newCases) {
                 AMCase *newCase = [[AMProtocolParser sharedInstance] parseCaseInfo:caseDict];
                 if (newCase) {
                     [caseModels addObject:newCase];
                 }
             }
             [[AMDBManager sharedInstance] saveAsyncCaseList:caseModels checkExist:YES completion:^(NSInteger type, NSError *error) {
                 if (!error) {
                     DLog(@"save new cases finished");
                 }
             }];
             
             NSDictionary *mapDict = [responseData valueForKeyPathWithNullToNil:@"idMap.Case"];
             
             if ([mapDict isKindOfClass:[NSDictionary class]]) {
                 for (AMDBNewCase *newCase in createdCases) {
                     if ([[mapDict allKeys] containsObject:newCase.fakeID]) {
                         newCase.id = mapDict[newCase.fakeID];
                         for (NSDictionary *caseDict in newCases) {
                             if ([newCase.id isEqualToString:caseDict[@"Id"]]) {
                                 newCase.caseNumber = caseDict[@"CaseNumber"];
                             }
                         }
                         
                         newCase.dataStatus = @(EntityStatusSyncSuccess);
                     } else {
                         newCase.dataStatus = @(EntityStatusSyncFail);
                     }
                 }
             }
         }
         
         NSDictionary *errorDict = [responseData valueForKeyPathWithNullToNil:@"idErrorMap"];
         
         if ([errorDict isKindOfClass:[NSDictionary class]]) {
             for (AMDBNewCase *newCase in createdCases) {
                 if ([[errorDict allKeys] containsObject:newCase.fakeID]) {
                     newCase.errorMessage = errorDict[newCase.fakeID];
                 }
             }
         }
         
         
         [[AMLogicCore sharedInstance] saveManagedObject:createdCases.firstObject completion:^(NSInteger type, NSError *error) {
             if (error) {
                 DLog(@"save new case error: %@", error.localizedDescription);
             }
         }];
         completionBlock(type, error, userData,responseData);
     }];
}

-(void)uploadCreatedContactsWithCompletion:(AMSFRestCompletionBlock)completionBlock {
    DLog(@"start upload created contacts");
    
    NSArray *createdContacts = [[AMDBManager sharedInstance] getCreatedContacts];
    if (!createdContacts.count) {
        completionBlock(AM_REQUEST_ADDCONTACTS, nil, nil,nil);
        return;
    }
    
    [[AMProtocolManager sharedInstance]
     createObjectsWithManagedObjects:createdContacts
     operationType:AM_REQUEST_ADDCONTACTS
     completion:^(NSInteger type, NSError *error, id userData, id responseData) {
         DLog(@"finish upload created contacts orders");
         
         BOOL isSuccess = ((NSNumber *)[responseData valueForKeyWithNullToNil:@"isSuccess"]).boolValue;
         if (error || !isSuccess) {
             // handle error
             for (AMDBNewContact *newContact in createdContacts)
             {
                 newContact.dataStatus = @(EntityStatusSyncFail);
                 newContact.errorMessage = responseData[@"errorMessage"];
             }
             
             
         } else {
             NSArray *newContacts = [responseData valueForKeyPathWithNullToNil:@"dataListMap.Add.Contact"];
             NSMutableArray *newContactModels = [NSMutableArray array];
             for (NSDictionary *contactDict in newContacts) {
                 AMContact *contact = [[AMProtocolParser sharedInstance] parseContactInfo:contactDict];
                 if (contact) {
                     [newContactModels addObject:contact];
                 }
             }
             
             [[AMDBManager sharedInstance] saveAsyncContactList:newContactModels checkExist:YES completion:^(NSInteger type, NSError *error) {
                 if (!error) {
                     DLog(@"save new contacts finished");
                     
                 }
             }];
             
             NSDictionary *mapDict = [responseData valueForKeyPathWithNullToNil:@"idMap.Work_Order__c"];
             
             if ([mapDict isKindOfClass:[NSDictionary class]]) {
                 for (AMDBNewContact *newContact in createdContacts) {
                     if ([[mapDict allKeys] containsObject:newContact.fakeID]) {
                         newContact.contactID = mapDict[newContact.fakeID];
                         newContact.dataStatus = @(EntityStatusSyncSuccess);
                     } else {
                         newContact.dataStatus = @(EntityStatusSyncFail);
                     }
                 }
             }
             [[AMDBManager sharedInstance] updateLocalModifiedObjectsToDone:@{ @"AMNewContact" : newContacts } completion:^(NSInteger type, NSError *error) {
                 
             }];
         }

         [[AMLogicCore sharedInstance] saveManagedObject:createdContacts.firstObject completion:^(NSInteger type, NSError *error) {
             if (error) {
                 DLog(@"save new contact error: %@", error.localizedDescription);
             }
         }];
         completionBlock(type, error, userData,responseData);
     }];
    
}

-(void)uploadCreatedWorkOrdersWithCompletion:(AMSFRestCompletionBlock)completionBlock
{
    DLog(@"start upload created work orders");

    NSArray *createdWorkOrders = [[AMDBManager sharedInstance] getCreatedWorkOrders];
    if (!createdWorkOrders.count) {
        completionBlock(AM_REQUEST_ADDWORKORDER, nil, nil,nil);
        return;
    }
    
    [[AMProtocolManager sharedInstance]
     createObjectsWithManagedObjects:createdWorkOrders
     operationType:AM_REQUEST_ADDWORKORDER
     completion:^(NSInteger type, NSError *error, id userData, id responseData) {
         DLog(@"finish upload created work orders");

         BOOL isSuccess = ((NSNumber *)[responseData valueForKeyWithNullToNil:@"isSuccess"]).boolValue;
         if (error || !isSuccess) {
             // handle error
             for (AMDBNewWorkOrder *newWorkOrder in createdWorkOrders)
             {
                 newWorkOrder.dataStatus = @(EntityStatusSyncFail);
                 newWorkOrder.errorMessage = responseData[@"errorMessage"];   
             }
             
             
         } else {
             NSArray *newWorkOrders = [responseData valueForKeyPathWithNullToNil:@"dataListMap.Add.Work_Order__c"];
             NSMutableArray *workOrderModels = [NSMutableArray array];
             for (NSDictionary *workOrderDict in newWorkOrders) {
                 AMWorkOrder *workOrder = [[AMProtocolParser sharedInstance] parseWorkOrderInfo:workOrderDict];
                 if (workOrder) {
                     [workOrderModels addObject:workOrder];
                 }
             }
             [[AMDBManager sharedInstance] saveAsyncWorkOrderList:workOrderModels checkExist:YES completion:^(NSInteger type, NSError *error) {
                 if (!error) {
                     DLog(@"save new work orders finished");
                 }
             }];
             
             NSDictionary *mapDict = [responseData valueForKeyPathWithNullToNil:@"idMap.Work_Order__c"];

             if ([mapDict isKindOfClass:[NSDictionary class]]) {
                 for (AMDBNewWorkOrder *newWorkOrder in createdWorkOrders) {
                     if ([[mapDict allKeys] containsObject:newWorkOrder.fakeID]) {
                         newWorkOrder.id = mapDict[newWorkOrder.fakeID];
                         newWorkOrder.dataStatus = @(EntityStatusSyncSuccess);
                     } else {
                         newWorkOrder.dataStatus = @(EntityStatusSyncFail);
                     }
                 }
             }
         }
         [[AMLogicCore sharedInstance] saveManagedObject:createdWorkOrders.firstObject completion:^(NSInteger type, NSError *error) {
             if (error) {
                 DLog(@"save new work order error: %@", error.localizedDescription);
             }
         }];
         completionBlock(type, error, userData,responseData);
     }];
}


- (void)getReportDataWithCompletion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETREPORTDATA;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodGET;
    request.method = method;
    request.path = @"/Report/WorkOrder";

    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"get report data error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"get report data response success");
        
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        request.completionBlock(request.type,nil, request.userData, dict);
    }];
}


-(NSURL *)getAttachmentEndpoint
{
    NSURL *pictureUrl = [SFUserAccountManager sharedInstance].currentUser.apiUrl;
    NSURL *endPoint = [[NSURL alloc] initWithScheme:pictureUrl.scheme host:pictureUrl.host path:@"/servlet/servlet.FileDownload?file="];
    return endPoint;
}

-(void)downloadUnfetchedAttachments
{
    
    NSArray *array = [[AMDBManager sharedInstance] getUnfetchedAttachments];
    
    DLog(@"start download %d attachments", array.count);

    if (array.count) {
        for (AMDBAttachment *attachment in array) {
            [self downloadAttachment:attachment];
        }
    }
}

-(void)downloadAttachment:(AMDBAttachment *)attachment
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = kSFDefaultRestEndpoint;
    request.type = AM_REQUEST_GETPHOTO;
//    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodGET;
    request.method = method;
    
    request.path = [attachment.remoteURL stringByAppendingString:@"/Body"];
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"get attachment error info %@",[error localizedDescription]);
//        request.completionBlock(request.type,error,request.userData,nil);
//        attachment.dataStatus = @(EntityStatusSyncFail);
//        [[AMDBManager sharedInstance] saveManagedObject:attachment completion:^(NSInteger type, NSError *error) {
//            
//        }];
        
    } completeBlock:^(id jsonResponse){
        DLog(@"get attachment response");
        
//        if ([attachment.contentType isEqualToString:@"image/jpg"]
//            || [attachment.contentType isEqualToString:@"image/jpeg"]) {
//            
//            UIImage *image = [UIImage imageWithData:jsonResponse];
//            if (image) {
//                [[AMFileCache sharedInstance] saveFile:jsonResponse WithFileName:attachment.id];
//                attachment.localURL = [[[AMFileCache sharedInstance] getDirectoryPath] stringByAppendingFormat:@"/%@", attachment.id];

//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ATTACHMENT_DOWNLOADED object:attachment];
//            }
//        }
        
        
        
        NSString *extension = nil;
        if ([attachment.contentType isEqualToString:@"image/jpg"]) {
            extension = @"jpg";
        } else if ([attachment.contentType isEqualToString:@"image/jpeg"]) {
            extension = @"jpeg";
        } else if ([attachment.contentType isEqualToString:@"image/png"]) {
            extension = @"png";
        } else if ([attachment.contentType isEqualToString:@"application/rtf"]) {
            extension = @"rtf";
        } else if ([attachment.contentType isEqualToString:@"application/msword"]) {
            extension = @"doc";
        } else if ([attachment.contentType isEqualToString:@"text/xml"]) {
            extension = @"xml";
        } else if ([attachment.contentType isEqualToString:@"application/vnd.ms-powerpoint"]) {
            extension = @"ppt";
        } else if ([attachment.contentType isEqualToString:@"application/pdf"]) {
            extension = @"pdf";
        }
        
        NSString *fileName = attachment.id;
        if (extension) {
            fileName = [fileName stringByAppendingFormat:@".%@", extension];
        }
//        NSString *fileName = attachment.name;
//        if (!attachment.name) {
//            fileName = attachment.id;
//        }
//        if (extension && ![fileName hasSuffix:extension]) {
//            fileName = [fileName stringByAppendingFormat:@".%@", extension];
//        }

        [[AMFileCache sharedInstance] saveFile:jsonResponse WithFileName:fileName];
        
        [[AMDBManager sharedInstance] updateAttachmentWithID:attachment.id
                                                  setupBlock:^(AMDBAttachment *attachment) {
                                                      attachment.localURL = [[[AMFileCache sharedInstance] getDirectoryPath] stringByAppendingFormat:@"/%@", fileName];

                                                  } completion:^(NSInteger type, NSError *error) {
                                                      if (error) {
                                                          DLog(@"save attachment error: %@", error.localizedDescription);
                                                      } else {
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ATTACHMENT_DOWNLOADED object:attachment];
                                                      }
                                                  }];        
        
//        attachment.localURL = [[[AMFileCache sharedInstance] getDirectoryPath] stringByAppendingFormat:@"/%@", attachment.id];
//        [[AMLogicCore sharedInstance] saveManagedObject:attachment completion:^(NSInteger type, NSError *error) {
//            if (error) {
//                DLog(@"save attachment error: %@", error.localizedDescription);
//            }
//        }];
        
    }];
}


-(UIImage *)imageWithJpegData:(NSData *)imgData
{
    CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef) imgData);
    CGImageRef imgRef = nil;
    
    imgRef = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    
    UIImage* image = [UIImage imageWithCGImage:imgRef];
    
    CGImageRelease(imgRef);
    CGDataProviderRelease(imgDataProvider);
    
    return image;
}


- (void)uploadNewLeads:(NSArray *)newLeads operationType:(NSInteger)oprType completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = oprType;
    request.completionBlock = completionBlock;
    SFRestMethod method = SFRestMethodPUT;
    request.method = method;
    request.path = @"/BusinessProcess";
    
    NSMutableArray *leadsForUpload = [NSMutableArray array];
    for (AMDBNewLead *newLead in newLeads) {
        NSDictionary *leadDict = [newLead dictionaryToUploadSalesforce];
        if (leadDict) {
            [leadsForUpload addObject:leadDict];
        }
    }
    
    NSDictionary * bodyDict = @{@"objectListMap":@{@"Lead": leadsForUpload}};
    
    request.queryParams = bodyDict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"create new leads error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"finish upload created new leads");
        
        NSDictionary * responseDict = [self transferJsonResponseToDictionary:jsonResponse];

        BOOL isSuccess = ((NSNumber *)[responseDict valueForKeyWithNullToNil:@"isSuccess"]).boolValue;
        if (!isSuccess) {
            // handle error
            
            for (AMDBNewLead *newLead in newLeads)
            {
                newLead.dataStatus = @(EntityStatusSyncFail);
                newLead.errorMessage = responseDict[@"errorMessage"];
            }
            
        } else {
            
            NSDictionary *mapDict = [responseDict valueForKeyPathWithNullToNil:@"idMap.Lead"];
            
            if ([mapDict isKindOfClass:[NSDictionary class]]) {
                for (AMDBNewLead *newLead in newLeads) {
                    if ([[mapDict allKeys] containsObject:newLead.fakeID]) {
                        newLead.salesforceId = mapDict[newLead.fakeID];
                        newLead.dataStatus = @(EntityStatusSyncSuccess);
                    } else {
                        newLead.dataStatus = @(EntityStatusSyncFail);
                    }
                }
            }
        }
     
        [[AMLogicCore sharedInstance] saveManagedObject:newLeads.firstObject completion:^(NSInteger type, NSError *error) {
            if (error) {
                DLog(@"save new case error: %@", error.localizedDescription);
            }
        }];
        completionBlock(AM_REQUEST_UPDATEOBJECTS, nil, newLeads,responseDict);
    }];
    
}


-(void)deleteAttachmentsOnSalesforce:(NSArray *)attachments completion:(AMSFRestCompletionBlock)completionBlock
{
    if (!attachments.count) {
        NSError *error = [NSError errorWithDomain:@"salesforce" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"delete attachment empty")}];
        completionBlock(AM_REQUEST_DELETE, error, attachments, nil);
        return;
    }
    
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_DELETE;
    request.completionBlock = completionBlock;
    request.method = SFRestMethodDELETE;
    NSArray *ids = [attachments valueForKey:@"id"];
    request.path = [@"/Attachment?attachmentids=" stringByAppendingString:[ids componentsJoinedByString:@","]];
    
    NSMutableDictionary * userDict = [NSMutableDictionary dictionary];
    if (attachments) {
        [userDict setObject:attachments forKey:@"attachments"];
    }
    request.userData = userDict;
    
    
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"delete attachments error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"delete attachments response");
        
        NSDictionary * responseDict = [self transferJsonResponseToDictionary:jsonResponse];
        
        BOOL isSuccess = ((NSNumber *)[responseDict valueForKeyWithNullToNil:@"isSuccess"]).boolValue;
        if (!isSuccess) {
            // handle error
            
            for (AMDBAttachment *newAttachment in attachments)
            {
                newAttachment.dataStatus = @(EntityStatusSyncFail);
                newAttachment.errorMessage = responseDict[@"errorMessage"];
            }
            
            [[AMLogicCore sharedInstance] saveManagedObject:attachments.firstObject completion:^(NSInteger type, NSError *error) {
                if (error) {
                    DLog(@"save new case error: %@", error.localizedDescription);
                }
            }];
            
        } else {
            
            [[AMDBManager sharedInstance] deleteAttachmentsByIDs:ids completion:^(NSInteger type, NSError *error) {
                
            }];

        }
        
        request.completionBlock(request.type, nil, request.userData, responseDict);
    }];
}


-(void)checkReadinessForInitializationWithCompletion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GET_INIT_CODE;
    request.completionBlock = completionBlock;
    request.method = SFRestMethodGET;
    request.path = @"/InitSignal";
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"get init code error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        NSDictionary * responseDict = [self transferJsonResponseToDictionary:jsonResponse];
        NSNumber *initCode = [responseDict valueForKeyPathWithNullToNil:@"initCode"];
        DLog(@"get init code response: %i", [initCode intValue]);
        request.completionBlock(request.type,nil,request.userData,initCode);
    }];
}

- (void)searchNearByWOs:(CLLocationCoordinate2D)coordinate distance:(float)radius withCompletion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_NEARBY;
    request.completionBlock = completionBlock;
    request.method = SFRestMethodPOST;
    request.path = @"/NearBy";
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];

    [paramDict setValue:@(coordinate.latitude) forKey:@"decUserLat"];
    [paramDict setValue:@(coordinate.longitude) forKey:@"decUserLng"];
    [paramDict setValue:@(radius) forKey:@"decRadius"];
    request.queryParams = paramDict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"get near by rest request failed %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"get near by rest request succeed");
        
        NSDictionary * responseDict = [self transferJsonResponseToDictionary:jsonResponse];
        NSMutableArray *WOArr = nil;
        BOOL isSuccess = ((NSNumber *)[responseDict valueForKeyWithNullToNil:@"isSuccess"]).boolValue;
        if (isSuccess) {
            WOArr = [NSMutableArray array];
            NSArray *newWorkOrders = [responseDict valueForKeyPathWithNullToNil:@"dataListMap.Add.Work_Order__c"];
            for (NSDictionary *workOrderDict in newWorkOrders) {
                AMWorkOrder *workOrder = [[AMProtocolParser sharedInstance] parseWorkOrderInfo:workOrderDict];
                if (workOrder) {
                    [WOArr addObject:workOrder];
                }
            }
        }
        request.completionBlock(request.type,nil,request.userData,WOArr);
    }];
}

- (void)getWorkOrderRequiredInfo:(NSArray *)woIds withCompletionBlock:(AMSFRestCompletionBlock)completionBlock
{
    if (![woIds count]) {
        completionBlock(AM_REQUEST_WORKORDERDETAIL, nil, nil,nil);
        return;
    }
    
    AMSFRequest * request = [[AMSFRequest alloc] init];
    
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_WORKORDERDETAIL;
    request.completionBlock = completionBlock;
    request.method = SFRestMethodPOST;
    request.path = @"/WorkOrderDetail";
    
    request.queryParams = @{@"idList": woIds};
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error) {
        DLog(@"get WorkOrderDetail rest request failed %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse) {
        DLog(@"get WorkOrderDetail rest request succeed");
        
        NSDictionary * responseDict = [self transferJsonResponseToDictionary:jsonResponse];
        BOOL isSuccess = ((NSNumber *)[responseDict valueForKeyWithNullToNil:@"isSuccess"]).boolValue;
        NSError *error = nil;
        if (!isSuccess) {
            // handle error
            error = [NSError errorWithDomain:@"Get Work Order Related Info" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"Failed to get work order related information")}];
        }
        completionBlock(request.type, error, request.userData, responseDict);
    }];
}

#pragma mark - Bench Tech Related
- (void)setBenchWOCheckout:(NSDictionary *)checkoutDict completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest *request = [[AMSFRequest alloc] init];
    
    request.method = SFRestMethodPATCH;
    request.path = @"/Bench/Checkout";
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_SETBTWOACTIVE;
    request.completionBlock = completionBlock;
    
    request.queryParams = checkoutDict;// benchWODict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"setBenchWOCheckout error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"setBenchWOCheckout response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = dict;//@{@"Status" : @"Success" };
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
    
}

- (void)setBenchWOActive:(NSString *)woID completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest *request = [[AMSFRequest alloc] init];
    
    request.method = SFRestMethodPATCH;
    request.path = @"/Bench/Queue";
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_SETBTWOACTIVE;
    request.completionBlock = completionBlock;
    
    request.queryParams = @{@"workOrderId" : woID};// benchWODict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"setBenchWOActive error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"setBenchWOActive response");
        
        NSDictionary * parsedDict = nil;
        
        parsedDict = @{@"Status" : @"Success" };
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
    
}
- (void)getBenchTechWOList:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest *request = [[AMSFRequest alloc] init];
    
    request.method = SFRestMethodGET;
    request.path = @"/Bench/Queue";
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETBTWOLST;
    request.completionBlock = completionBlock;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getBenchTechWOList error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getBenchTechWOList response");
        
        NSDictionary * parsedDict = nil;
        NSArray * array = (NSArray *)[self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseBTWorkOrderInfoList:array];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
}

- (void)getActiveBenchTechWOList:(AMSFRestCompletionBlock)completionBlock {
    AMSFRequest *request = [[AMSFRequest alloc] init];
    
    request.method = SFRestMethodGET;
    request.path = @"/Bench/Active";
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_GETBTWOLST;
    request.completionBlock = completionBlock;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getActiveBenchTechWOList error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getActiveBenchTechWOList response");
        
        NSDictionary * parsedDict = nil;
        NSArray * array = (NSArray *)[self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = [[AMProtocolParser sharedInstance] parseBTActiveWorkOrderInfoList:array];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
}

- (void)toggleTimerForAssetStop:(NSString *)assetID completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest *request = [[AMSFRequest alloc] init];
    
    request.method = SFRestMethodPATCH;
    request.path = @"/Bench/Active";
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_SETBTACTTIMER;
    request.completionBlock = completionBlock;
    NSDictionary * bodyDict = @{@"assetId": assetID};
    
    request.queryParams = bodyDict;

    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getActiveBenchTechWOList error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getActiveBenchTechWOList response");
        
        NSDictionary *parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = dict;//[[AMProtocolParser sharedInstance] parseWorkOrderInfoList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
}

- (void)toggleTimerForAssetStart:(NSString *)assetID completion:(AMSFRestCompletionBlock)completionBlock
{
    AMSFRequest *request = [[AMSFRequest alloc] init];
    
    request.method = SFRestMethodPOST;
    request.path = @"/Bench/Active";
    request.endpoint = @"/services/apexrest";
    request.type = AM_REQUEST_SETBTACTTIMER;
    request.completionBlock = completionBlock;
    NSDictionary * bodyDict = @{@"assetId": assetID};
    
    request.queryParams = bodyDict;
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
        DLog(@"getActiveBenchTechWOList error info %@",[error localizedDescription]);
        request.completionBlock(request.type,error,request.userData,nil);
    } completeBlock:^(id jsonResponse){
        DLog(@"getActiveBenchTechWOList response");
        
        NSDictionary * parsedDict = nil;
        NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
        
        parsedDict = dict;//[[AMProtocolParser sharedInstance] parseWorkOrderInfoList:dict];
        request.completionBlock(request.type,nil, request.userData,parsedDict);
    }];
}

- (void)scrapBenchAsset:(NSString *)assetID completion:(AMSFRestCompletionBlock)completionBlock
{
    if (assetID != nil)
    {
        AMSFRequest *request = [[AMSFRequest alloc] init];
        
        request.method = SFRestMethodPOST;
        request.path = @"/Bench/Scrap";
        request.endpoint = @"/services/apexrest";
        request.type = AM_REQUEST_SCRAPBTASSET;
        request.completionBlock = completionBlock;
        NSDictionary * bodyDict = @{@"assetId": assetID};
        
        request.queryParams = bodyDict;
        
        [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *error){
            DLog(@"getActiveBenchTechWOList error info %@",[error localizedDescription]);
            request.completionBlock(request.type,error,request.userData,nil);
        } completeBlock:^(id jsonResponse){
            DLog(@"getActiveBenchTechWOList response");
            
            NSDictionary *parsedDict = nil;
            NSDictionary * dict = [self transferJsonResponseToDictionary:jsonResponse];
            
            parsedDict = dict;//[[AMProtocolParser sharedInstance] parseWorkOrderInfoList:dict];
            request.completionBlock(request.type,nil, request.userData,parsedDict);
        }];
    }
}

@end









