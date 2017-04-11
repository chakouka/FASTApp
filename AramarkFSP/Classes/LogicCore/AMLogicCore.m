//
//  AMLogicCore.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/5/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMLogicCore.h"
#import "SFRestAPI.h"
#import "SFNetworkEngine.h"
#import "SFOAuthCoordinator.h"
#import "SFOAuthCredentials.h"
#import "AMDBManager.h"
#import "AMProtocolManager.h"
#import "AMConstants.h"
#import "AMInitailManager.h"
#import "AMSyncingManager.h"
#import "AMOnlineOprManager.h"
#import "AMProtocolParser.h"
#import "SFOAuthCoordinator.h"


#define TIMEBOUNDARYHOUR            6
//#define InitialTestMode             1

@interface AMLogicCore()
{
//    NSString * _selfUId;
    AMWorkOrder * _checkInWO;
    NSNumber * _hourRate;
    NSDate * _timeStamp;
    AMWorkOrder * _curDisplayWO;
}

@property (nonatomic, copy) AMDBOperationCompletionBlock initialComplteHandler;

@end

@implementation AMLogicCore

#pragma mark - Internal Methods

- (void)syncingCompletion:(NSError *)error
{
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
            
            [userInfo setObject:TYPE_OF_SHOW_ALERT forKey:KEY_OF_TYPE];
            if (error.localizedDescription) {
                [userInfo setObject:error.localizedDescription forKey:KEY_OF_INFO];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_LOGICCORE object:userInfo];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SYNCING_DONE object:nil];
    });
}

//clear db data and userDefaults data
- (void)clearHistoryData:(AMDBOperationCompletionBlock)completionBlock
{
    [USER_DEFAULT setObject:nil forKey:USRLOGINTIMESTAMP];
    [USER_DEFAULT setObject:nil forKey:USRDFTSELFUID];
    [USER_DEFAULT setObject:nil forKey:kAMLoggedUserNameKey];
    [USER_DEFAULT setObject:nil forKey:USRLASTSYNCTIMESTAMP];
    [USER_DEFAULT setObject:nil forKey:USRDFTHOURRATE];
    [USER_DEFAULT synchronize];
    [self clearHistoryDBData:completionBlock];
}

//only clear db data
- (void)clearHistoryDBData:(AMDBOperationCompletionBlock)completionBlock
{
    [[AMDBManager sharedInstance] clearAllData:completionBlock];
}

- (void)handleInitialWith:(AMUser *)selfUser TimeStamp:(NSDate *)timeStamp
{
    NSDate * lastInitDate = [USER_DEFAULT objectForKey:USRLOGINTIMESTAMP];
    __block BOOL needInitial = NO;
    
    self.selfUser = selfUser;
    _selfUId = selfUser.userID;
    [USER_DEFAULT setObject:selfUser.userID forKey:USRDFTSELFUID];
    [USER_DEFAULT setObject:selfUser.displayName forKey:kAMLoggedUserNameKey];
    [USER_DEFAULT synchronize];
    [AMDBManager sharedInstance].selfId = selfUser.userID;
    [AMInitailManager sharedInstance].selfUId = selfUser.userID;
    //DBManager need a timestamp to read today's wo list in next steps...
    [AMDBManager sharedInstance].timeStamp = timeStamp;
    [AMSyncingManager sharedInstance].timeStamp = timeStamp;
    [USER_DEFAULT setObject:selfUser.userID forKey:USRDFTSELFUID];
    [USER_DEFAULT synchronize];

    if (selfUser.photoUrl) {
        [[AMProtocolManager sharedInstance] downloadPhotoWithUrl:selfUser.photoUrl completion:
         ^(NSInteger type, NSError * error, id userData, id responseData){
             [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
         }];
    }
    
#ifdef InitialTestMode
    needInitial = YES;//for test
#endif
    
    if (!lastInitDate) {
        needInitial = YES;
        [self processInitialProcess:needInitial];
        
    } else if ([lastInitDate compare:[AMUtilities todayBeginningDate]] == NSOrderedAscending) {
        
        [[AMProtocolManager sharedInstance] checkReadinessForInitializationWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
            NSNumber *initCode = (NSNumber *)responseData;
            if (initCode.intValue == 1) {
                needInitial = YES;
            }
            [self processInitialProcess:needInitial];
        }];
        
    } else {
        [self processInitialProcess:needInitial];
    }

    

}

-(void)processInitialProcess:(BOOL)needInitial
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate * lastInitDate = [userDefaults objectForKey:USRLOGINTIMESTAMP];
    NSDate *timeStamp = [AMDBManager sharedInstance].timeStamp;
    
    if (needInitial) {
        [self clearHistoryDBData:^(NSInteger type, NSError * error){
            if (self.selfUser) {
                [[AMDBManager sharedInstance] saveAsyncUserList:@[self.selfUser] checkExist:YES completion:^(NSInteger type, NSError *error) {
                    DLog(@"Save User Profile %@", error ? @"Failed" : @"Succeed");
                }];
            }
            [[AMInitailManager sharedInstance] startInitialization:^(NSInteger type, NSError * error){
                dispatch_async(dispatch_get_main_queue(), ^(){//read wo list and timer should be schedueled on main queue
                    NSArray * woList = [self getTodayWorkOrderList];
                    if (!error && woList.count) {//save latest timestamp only after get today's wo list
                        DLog(@"initial timestamp %@",[[AMInitailManager sharedInstance].timeStamp description]);
                        [userDefaults setObject:[AMInitailManager sharedInstance].timeStamp forKey:USRLOGINTIMESTAMP];
                        [userDefaults setObject:[AMInitailManager sharedInstance].timeStamp forKey:USRLASTSYNCTIMESTAMP];
                        [userDefaults synchronize];
                        [AMDBManager sharedInstance].timeStamp = [AMInitailManager sharedInstance].timeStamp;
                        [AMSyncingManager sharedInstance].timeStamp = [AMInitailManager sharedInstance].timeStamp;
                    }
                    else {//or, use timestamp of get userinfo as time stamp
                        [AMDBManager sharedInstance].timeStamp = timeStamp;
                        [AMSyncingManager sharedInstance].timeStamp = timeStamp;
                    }
                    self.initialComplteHandler(AM_REQUEST_GETUSERINFO,error);
                    
                    [[AMSyncingManager sharedInstance] activeAutoSyncing:^(NSInteger type, NSError * error){
                        [self syncingCompletion:error];
                    }];
                });
            }];
        }];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{//timer should be schedueled on main queue
            NSDate * lastSyncDate = [userDefaults objectForKey:USRLASTSYNCTIMESTAMP];
            if (!lastSyncDate) {
                lastSyncDate = lastInitDate;
            }
            [AMSyncingManager sharedInstance].timeStamp = lastSyncDate;
            [AMInitailManager sharedInstance].timeStamp = lastSyncDate;
            
            self.initialComplteHandler(AM_REQUEST_GETUSERINFO,nil);
            [[AMSyncingManager sharedInstance] activeAutoSyncing:^(NSInteger type, NSError * error){
                [self syncingCompletion:error];
            }];
        });
    }
}


-(NSArray *)arrangeArray:(NSArray *)array byDayKey:(NSString *)dayKey inPastDays:(int)numberOfPastDays andFutureDays:(int)numberOfFutureDays
{    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:dayKey ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray * sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    
    NSMutableArray * arrangedArray = [NSMutableArray array];
    
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSDate *date = [calendar dateFromComponents:components];
    NSDate *startDate = [date dateByAddingTimeInterval:-(numberOfPastDays-1)*24*60*60];
    
    // put first array to be ready
    NSMutableArray *subArray = [NSMutableArray array];
    [arrangedArray addObject:@{startDate: subArray}];
    
    if (sortedArray && sortedArray.count)
    {
        for (id object in sortedArray)
        {
            NSDateComponents* components = [calendar components:NSDayCalendarUnit fromDate:startDate toDate:[object valueForKey:dayKey] options:0];
            if (components.day > 0) {
                for (int i=0; i<components.day; i++) {
                    startDate = [startDate dateByAddingTimeInterval: 24*60*60];
                    NSMutableArray *subArray = [NSMutableArray array];
                    [arrangedArray addObject: @{startDate: subArray}];
                }
            } else if (components.day < 0) {
                break;
            }
            NSDictionary *subDict = [arrangedArray lastObject];
            NSMutableArray *subArray = subDict.allValues.firstObject;
            [subArray addObject:object];
        }
    }
    
    if (arrangedArray.count < numberOfPastDays+numberOfFutureDays) {
        int lack = numberOfPastDays + numberOfFutureDays - arrangedArray.count;
        for (int i=0; i<lack; i++) {
            startDate = [startDate dateByAddingTimeInterval: 24*60*60];
            NSMutableArray *array = [NSMutableArray array];
            [arrangedArray addObject:@{startDate: array}];
        }
    }
    
    return arrangedArray;
    
}

-(NSArray *)arrangeArrayInArray:(NSArray *)array byDayKey:(NSString *)dayKey inPastDays:(int)numberOfPastDays andFutureDays:(int)numberOfFutureDays
{
    NSDate *filterStartDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:-(numberOfPastDays-1)*24*60*60];
    NSDate *filterEndDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:(numberOfFutureDays+1)*24*60*60];
    NSPredicate * filter = [NSPredicate predicateWithFormat:
                            @"(%K >= %@) AND (%K < %@)", dayKey, filterStartDate, dayKey, filterEndDate];
    NSArray *filteredArray = [array filteredArrayUsingPredicate:filter];

    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:dayKey ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray * sortedArray = [filteredArray sortedArrayUsingDescriptors:sortDescriptors];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    
    NSMutableArray * arrangedArray = [NSMutableArray array];
    
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSDate *date = [calendar dateFromComponents:components];
    NSDate *startDate = [date dateByAddingTimeInterval:-(numberOfPastDays-1)*24*60*60];
    
    // put first array to be ready
    NSMutableArray *subArray = [NSMutableArray array];
    [arrangedArray addObject:subArray];
    
    if (sortedArray && sortedArray.count)
    {
        for (id object in sortedArray)
        {
            NSDateComponents* components = [calendar components:NSDayCalendarUnit fromDate:startDate toDate:[object valueForKey:dayKey] options:0];
            if (components.day > 0) {
                for (int i=0; i<components.day; i++) {
                    startDate = [startDate dateByAddingTimeInterval: 24*60*60];
                    NSMutableArray *subArray = [NSMutableArray array];
                    [arrangedArray addObject: subArray];
                }
            } else if (components.day < 0) {
                break;
            }
            NSMutableArray *subArray = [arrangedArray lastObject];
            [subArray addObject:object];
        }
    }
    
    if (arrangedArray.count < numberOfPastDays+numberOfFutureDays) {
        int lack = numberOfPastDays + numberOfFutureDays - arrangedArray.count;
        for (int i=0; i<lack; i++) {
            startDate = [startDate dateByAddingTimeInterval: 24*60*60];
            NSMutableArray *array = [NSMutableArray array];
            [arrangedArray addObject:array];
        }
    }
    
    return arrangedArray;
    
}

#pragma mark - Protocol Handler

- (void)protocolHandlerWithType:(NSInteger)type retErro:(NSError *)error userData:(id)userData responseData:(id)responseData
{
    NSDictionary * userDict = (NSDictionary *)userData;
    NSDictionary * retDict = (NSDictionary *)responseData;
    NSNumber * isSuccess = (NSNumber *)[retDict objectForKey:NWRESPRESULT];
    
    DLog(@"AMLogicCore protocolHandlerWithType type=%d",type);
    switch (type) {
        case AM_REQUEST_GETUSERINFO:
        {
            if (!error && [isSuccess intValue]) {//success
                AMUser * selfUser = (AMUser *)[retDict objectForKey:NWRESPDATA];
                NSDate * timeStamp = [retDict objectForKey:NWTIMESTAMP];
                
                if (![_selfUId isEqualToString:selfUser.userID]) {//not same user, clear history data
                    [self clearHistoryData:^(NSInteger type, NSError * error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self handleInitialWith:selfUser TimeStamp:timeStamp];
                        });
                        
                    }];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self handleInitialWith:selfUser TimeStamp:timeStamp];
                    });

                }
                
            }
            else {
                if (!error) {
                     error = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"GetSelfUserInfo : server logic error")}];
                }
                self.initialComplteHandler(AM_REQUEST_GETUSERINFO,error);
            }
        }
            break;
        case AM_REQUEST_GETPHOTO:
        {
            if (!error && [isSuccess intValue]) {
                NSString * urlString = [userDict objectForKey:@"urlString"];
                NSData * photoData = [retDict objectForKey:NWRESPDATA];
                
                [AMFileCache sharedInstance].directoryName = _selfUId;
                [[AMFileCache sharedInstance] saveFile:photoData WithFileName:[AMFileCache delegateSpecialCharacters:urlString]];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Methods

+ (AMLogicCore *)sharedInstance
{
    static AMLogicCore *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMLogicCore alloc] init];
    });
    
    return sharedInstance;
}

- (void)startInitialization:(AMDBOperationCompletionBlock)initCompletionHandler
{
    _selfUId = [[NSUserDefaults standardUserDefaults] objectForKey:USRDFTSELFUID];

    self.initialComplteHandler = initCompletionHandler;
    
    [[AMProtocolManager sharedInstance] getSelfUserInfo:^(NSInteger type, NSError * error, id userData, id responseData){
        [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
    }];
    
    /*[self logOut:^(NSInteger type, NSError * error){
        dispatch_async(dispatch_get_main_queue(), ^{
            AMUser * selfUserInfo = [[AMDBManager sharedInstance] getUserInfoByUserID:_selfUId];
            
            if (selfUserInfo) {
                [AMDBManager sharedInstance].selfId = selfUserInfo.userID;
                [AMInitailManager sharedInstance].selfUId = selfUserInfo.userID;
            }
            
            if (!selfUserInfo || !selfUserInfo.timeStamp) {
                //Need Initialization
                [[AMProtocolManager sharedInstance] getSelfUserInfo:^(NSInteger type, NSError * error, id userData, id responseData){
                    [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
                }];

            }
            else {
                //TODO: need Syncing
            }

        });
    }];*/
    

}

- (void)startSyncing
{
//    BOOL isNetworkAvailable = [[AMLogicCore sharedInstance] isNetWorkReachable];
//    if (isNetworkAvailable && ![AMSyncingManager sharedInstance].timeStamp) {
//        
//    }
    [[AMSyncingManager sharedInstance] startSyncing:^(NSInteger type, NSError * error){
        if (!error ||
            [error.localizedDescription rangeOfString:kAM_MESSAGE_SYNC_IN_PROCESS].location == NSNotFound) {
            [self syncingCompletion:error];
        }
    }];
}

- (void)logOut:(AMDBOperationCompletionBlock)completionBlock
{
//    [self clearHistoryData:completionBlock];
    [[AMSyncingManager sharedInstance] cancelAutoSyncing];
    completionBlock(AM_DBOPR_DEL, nil);
}

- (BOOL)isNetWorkReachable
{
    if ([SFRestAPI sharedInstance].coordinator) {
        return [[SFNetworkEngine sharedInstance] isReachable];
    }
    return NO;
}

- (AMUser *)getSelfUserInfo
{
    return [[AMDBManager sharedInstance] getUserInfoByUserID:_selfUId];
}

- (NSData *)getPhotoDataByName:(NSString *)photoName
{
    return [[AMFileCache sharedInstance] getFile:[AMFileCache delegateSpecialCharacters:photoName]];
}

- (void)saveSignatureData:(NSData *)signatureData byCaseID:(NSString *)caseID completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSString *fileName = [NSString stringWithFormat:@"%@%@",SIGNATUREFILEPREFIX,caseID];
    BOOL success = [[AMFileCache sharedInstance] saveFile:signatureData WithFileName: fileName];
    NSError * error = nil;
    if (!success)
    {
        error = [[NSError alloc] initWithDomain:@"save error" code:0 userInfo:nil];
        completionBlock(0, error);
    }
    else {
        
        [[AMDBManager sharedInstance] createNewAttachmentInDBWithSetupBlock:^(AMDBAttachment *newAttachment) {
            newAttachment.parentId = caseID;
            newAttachment.name = caseID;
            newAttachment.contentType = @"image/png";
            newAttachment.localURL = [[[AMFileCache sharedInstance] getDirectoryPath] stringByAppendingPathComponent:fileName];
            
        } completion:^(NSInteger type, NSError *error) {
            completionBlock(0,error);
            
        }];
        
    }
}

- (NSData *)getSignatureDataByCaseID:(NSString *)caseID
{
    return [[AMFileCache sharedInstance] getFile:[AMFileCache delegateSpecialCharacters:[NSString stringWithFormat:@"%@%@",SIGNATUREFILEPREFIX,caseID]]];
}

- (NSArray *)getTodayWorkOrderList
{
    NSArray * todayList = [[AMDBManager sharedInstance] getTodayWorkOrder];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"estimatedTimeEnd" ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray * sortedArray = [todayList sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

- (NSArray *)getEventListByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getEventListByWOID:woID];
}

-(AMEvent *)getSelfEventByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getSelfEventByWOID:woID];
}

- (NSArray *)getSummaryWorkOrderList
{
    NSArray * summaryList = [[AMDBManager sharedInstance] getSelfWorkOrderListInPastDaysIncludeToday:14];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"actualTimeEnd" ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray * sortedArray = [summaryList sortedArrayUsingDescriptors:sortDescriptors];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];

    NSMutableArray * summaryHistory = [NSMutableArray array];
    int numberOfDays = 14;

    if (sortedArray && sortedArray.count)
    {
        NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
        components.hour = 0;
        components.minute = 0;
        components.second = 0;
        NSDate *date = [calendar dateFromComponents:components];
        NSDate *startDate = [date dateByAddingTimeInterval:-(numberOfDays-1)*24*60*60];
        
        // put first array to be ready
        NSMutableArray *subArray = [NSMutableArray array];
        [summaryHistory addObject:subArray];
        
        for (AMWorkOrder * wo in sortedArray)
        {
            NSDateComponents* components = [calendar components:NSDayCalendarUnit fromDate:startDate toDate:wo.actualTimeEnd options:0];
            if (components.day > 0) {
                for (int i=0; i<components.day; i++) {
                    NSMutableArray *subArray = [NSMutableArray array];
                    [summaryHistory addObject:subArray];
                }
                startDate = [startDate dateByAddingTimeInterval: components.day * 24*60*60];
            } else if (components.day < 0) {
                break;
            }
            NSMutableArray *subArray = [summaryHistory lastObject];
            [subArray addObject:wo];
        }
    }
    
    if (summaryHistory.count < numberOfDays) {
        int lack = numberOfDays - summaryHistory.count;
        for (int i=0; i<lack; i++) {
            NSMutableArray *array = [NSMutableArray array];
            [summaryHistory addObject:array];
        }
    }
    
    return summaryHistory;
}


- (NSArray *)getSummaryWorkOrderListInPastDaysIncludeToday:(int)numberOfPastDays
{
    NSArray * summaryList = [[AMDBManager sharedInstance] getSelfWorkOrderListInPastDaysIncludeToday:numberOfPastDays];
    NSArray *arrangedArray = [self arrangeArray:summaryList byDayKey:@"actualTimeEnd" inPastDays:numberOfPastDays andFutureDays:0];
    return arrangedArray;
}

- (NSArray *)getSummaryWorkOrderListInFutureDaysExcludeToday:(int)numberOfFutureDays
{
    NSArray * summaryList = [[AMDBManager sharedInstance] getSelfWorkOrderListInFutureDaysExcludeToday:numberOfFutureDays];
    NSArray *arrangedArray = [self arrangeArray:summaryList byDayKey:@"estimatedTimeStart" inPastDays:0 andFutureDays:numberOfFutureDays];
    return arrangedArray;
}


- (NSArray *)getAccountPendingWorkOrderList:(NSString *)accountID
{
    return [[AMDBManager sharedInstance] getAccountPendingWorkOrderList:accountID];
}

- (NSArray *)getPoSPendingWorkOrderList:(NSString *)posID
{
    return [[AMDBManager sharedInstance] getPoSPendingWorkOrderList:posID];
}

- (NSArray *)getCaseWorkOrderList:(NSString *)caseID
{
    return [[AMDBManager sharedInstance] getCaseWorkOrderList:caseID];
}

- (NSArray *)getCaseOpenWorkOrderList:(NSString *)caseID
{
    return [[AMDBManager sharedInstance] getCaseOpenWorkOrderList:caseID];
}

- (NSArray *)getOpenFilterExchangeWorkOrdersByCaseId:(NSString *)caseID
{
    return [[AMDBManager sharedInstance] getOpenFilterExchangeWorkOrdersByCaseId:caseID];
}

- (NSArray *)getAssetPast6MonthsRepairWorkOrderList:(NSString *)assetID
{
    return [[AMDBManager sharedInstance] getAssetPast6MonthsRepairWorkOrderList:assetID];
}

- (NSNumber *)getPoSPast28DaysRepairWorkOrderNumber:(NSString *)posID
{
    return [[AMDBManager sharedInstance] getPoSPast28DaysRepairWorkOrderNumber:posID];
}

- (NSArray *)getInvoiceListByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getInvoiceListByWOID:woID];
}

- (AMWorkOrder *)getWorkOrderInfoByID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getWorkOrderByWOID:woID];
}

- (AMWorkOrder *)getFullWorkOrderInfoByID:(NSString *)woID
{
    AMWorkOrder * wo = [self getWorkOrderInfoByID:woID];
    
    wo.woPoS = [self getPoSInfoByID:wo.posID];
    wo.woAsset = [self getAssetInfoByID:wo.assetID];
    wo.woAccount = [self getAccountInfoByID:wo.accountID];
    wo.woCase = [self getCaseInfoByID:wo.caseID];
    wo.woPoS.pendingWOList = [self getPoSPendingWorkOrderList:wo.posID];
    wo.woPoS.past28WOCount = [self getPoSPast28DaysRepairWorkOrderNumber:wo.posID];
    wo.woPoS.contactList = [self getContactListByPoSID:wo.posID];
    wo.woAsset.repairWOHistory = [self getAssetPast6MonthsRepairWorkOrderList:wo.assetID];
    wo.woAccount.pendingWOList = [self getAccountPendingWorkOrderList:wo.accountID];
    wo.woCase.woList = [self getCaseWorkOrderList:wo.caseID];
    wo.woAccount.locationList = [self getLocationListByAccountID:wo.accountID];
//    wo.machineType = wo.woAsset.machineType;
    //wo.caseDescription = wo.woCase.caseDescription;
    wo.parkingDetail = wo.woPoS.parkingDetail;
//    wo.woAccount.nam = wo.woPoS.nam;
//    wo.woAccount.kam = wo.woPoS.kam;
    
    _curDisplayWO = wo;
    return wo;
}

- (AMAccount *)getAccountInfoByID:(NSString *)accountID
{
    AMAccount * account = [[AMDBManager sharedInstance] getAccountInfoByID:accountID];
    
    return account;
}

- (AMPoS *)getPoSInfoByID:(NSString *)posID
{
    return [[AMDBManager sharedInstance] getPoSInfoByID:posID];
}

- (AMCase *)getCaseInfoByID:(NSString *)caseID
{
    return [[AMDBManager sharedInstance] getCaseInfoByID:caseID];
}

- (AMAsset *)getAssetInfoByID:(NSString *)assetID
{
    AMAsset * asset = [[AMDBManager sharedInstance] getAssetInfoByID:assetID];
    
    if (asset) {
        asset.assetLocation = [[AMDBManager sharedInstance] getLocationInfoByID:asset.locationID];
    }
    
    return asset;
}

- (NSArray *)getLocationListByAccountID:(NSString *)accountID
{
    return [[AMDBManager sharedInstance] getLocationListByAccountID:accountID];
}

- (AMLocation *)getLocationByID:(NSString *)locationID
{
    return [[AMDBManager sharedInstance] getLocationInfoByID:locationID];
}

- (NSArray *)getContactListByPoSID:(NSString *)posID
{
    return [[AMDBManager sharedInstance] getContactListByPoSID:posID];
}

//- (NSArray *)getFilterListByPoSID:(NSString *)posID
//{
//    return [[AMDBManager sharedInstance] getFilterListByPoSID:posID];
//}

- (NSArray *)getPartsListByProductID:(NSString *)productID
{
    return [[AMDBManager sharedInstance] getPartsListByProductID:productID];
}

- (NSArray *)getInvoicesListByWOIDList:(NSArray *)woIDList
{
    return [[AMDBManager sharedInstance] getInvoiceListByWOIDList:woIDList];
}

- (NSArray *)getCaseInvoicesListByWO:(AMWorkOrder *)wo
{
    NSArray * woList = [self getCaseWorkOrderList:wo.caseID];
    NSMutableArray * woIDs = [NSMutableArray array];
    
    for (AMWorkOrder * wod in woList) {
        if (wod.woID) {
            [woIDs addObject:wo.woID];
        }
    }
    return [self getInvoicesListByWOIDList:woIDs];
}

- (NSArray *)getAssetListByPoSID:(NSString *)posID AccountID:(NSString *)accountID
{
    NSArray * assetList = [[AMDBManager sharedInstance] getAssetListByPoSID:posID];
    
    if (assetList && assetList.count) {
        NSArray * locationList = [[AMDBManager sharedInstance] getLocationListByAccountID:accountID];
        for (AMAsset * asset in assetList) {
            for (AMLocation * location in locationList) {
                if (asset.locationID && [asset.locationID isEqualToString:location.locationID]) {
                    asset.assetLocation = location;
                    break;
                }
            }
        }
    }
    return assetList;
}

- (NSArray *)getAssetRequestListByPoSID:(NSString *)posID
{
    return  [[AMDBManager sharedInstance] getAssetRequestListByPoSID:posID];
}


- (void)checkInWorkOrder:(AMWorkOrder *)wo completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    if (![wo.ownerID isEqualToString:_selfUId]) {
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"You are not the owner of this work order.")}];
        completionBlock(AM_DBOPR_SAVE, error);
        return;
    }
    
    NSArray *todayCheckInWOList = [[AMDBManager sharedInstance] getSelfOwnedTodayCheckInWorkOrders];
    if (todayCheckInWOList.count > 0) {
        AMWorkOrder *currentWO = [todayCheckInWOList firstObject];
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Please complete check out.\n WO# : %@ \n Account Name : %@", currentWO.woNumber, currentWO.accountName]}];
        completionBlock(0, error);
    } else {
        _checkInWO = wo;
        wo.status = @"In Progress";
        wo.actualTimeStart = [NSDate date];
        
        for (AMEvent * event in wo.eventList) {
            if ([event.ownerID isEqualToString:_selfUId]) {
                event.actualTimeStart = wo.actualTimeStart;
                break;
            }
        }
        
        [self updateWorkOrder:wo completionBlock:^(NSInteger type, NSError *error) {
            [[AMOnlineOprManager sharedInstance] updateSingleWO:wo completion:^(NSInteger type, NSError *error) {
                if (error) {
                    DLog(@"update single WO failed: %@", error.localizedDescription);
                } else {
                    DLog(@"update single WO success");
                }
            }];
            completionBlock(type,error);
        }];
    }
}

- (void)cancelCheckInWorkOrder:(AMWorkOrder *)wo completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    if (![wo.ownerID isEqualToString:_selfUId]) {
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"You are not the owner of this work order.")}];
        completionBlock(AM_DBOPR_SAVE, error);
        return;
    }
    
    if ([wo.status isEqualToLocalizedString:@"In Progress"] || [wo.status isEqualToLocalizedString:@"Checked Out"])
    {
        if ([_checkInWO.woID isEqualToString: wo.woID]) {
            _checkInWO = nil;
        }
        
        wo.status = @"Scheduled";
        wo.actualTimeStart = nil;
        wo.actualTimeEnd = nil;
        for (AMEvent * event in wo.eventList) {
            if ([event.ownerID isEqualToString:_selfUId]) {
                event.actualTimeStart = wo.actualTimeStart;
                event.actualTimeEnd = wo.actualTimeEnd;
                break;
            }
        }
        [self updateWorkOrder:wo completionBlock:^(NSInteger type, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WORK_ORDER_STATUS_CHANGED object:nil];
                [[AMOnlineOprManager sharedInstance] updateSingleWO:wo completion:^(NSInteger type, NSError *error) {
                    if (error) {
                        DLog(@"update single WO failed: %@", error.localizedDescription);
                    } else {
                        DLog(@"update single WO success");
                    }
                }];
            }
            completionBlock(type,error);
        }];
    } else {
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"work order not in progress, cancel operation not proceed")}];
        completionBlock(AM_DBOPR_SAVE, error);
    }
}

/*
- (BOOL)checkOutWorkOrder:(AMWorkOrder *)wo
{
    BOOL success = NO;
//    if (_checkInWO && [_checkInWO.woID isEqualToString:wo.woID]) {
//        _checkInWO.actualTimeEnd = [NSDate date];
//        _checkInWO.status = @"Closed";
//        
//        for (AMEvent * event in _checkInWO.eventList) {
//            if ([event.ownerID isEqualToString:_selfUId]) {
//                event.actualTimeEnd = _checkInWO.actualTimeEnd;
//                break;
//            }
//        }
//
//        success = YES;
//        
//        [self updateWorkOrder:_checkInWO completionBlock:^(NSInteger type, NSError *error) {
//            
//        }];
//    }
    _checkInWO = wo;
    wo.actualTimeEnd = [NSDate date];
    wo.status = @"Closed";
    
    for (AMEvent * event in wo.eventList) {
        if ([event.ownerID isEqualToString:_selfUId]) {
            event.actualTimeEnd = wo.actualTimeEnd;
            break;
        }
    }
    
    if ([wo.ownerID isEqualToString:_selfUId]) {
        wo.workOrderCheckinTime = wo.actualTimeStart;
        wo.workOrderCheckoutTime = wo.actualTimeEnd;
    }
    
    success = YES;
    
    [self updateWorkOrder:wo completionBlock:^(NSInteger type, NSError *error) {
        
    }];
    
    return success;
}
*/
//- (AMWorkOrder *)getCheckingWorkOrder
//{
//    return _checkInWO;
//}

- (void)finishCheckOutWorkOrder:(AMWorkOrder *)wo completion:(AMDBOperationCompletionBlock)completionBlock
{
    if (![wo.ownerID isEqualToString:_selfUId]) {
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"You are not the owner of this work order.")}];
        completionBlock(AM_DBOPR_SAVE, error);
        return;
    }
    
    _checkInWO = wo;
    wo.actualTimeEnd = [NSDate date];
    wo.status = @"Closed";
    
    for (AMEvent * event in wo.eventList) {
        if ([event.ownerID isEqualToString:_selfUId]) {
            event.actualTimeEnd = wo.actualTimeEnd;
            break;
        }
    }
    
    if ([wo.ownerID isEqualToString:_selfUId]) {
        wo.workOrderCheckinTime = wo.actualTimeStart;
        wo.workOrderCheckoutTime = wo.actualTimeEnd;
    }

//    // 8/19 don't calculate total price locally, server will calculate
//    if ([self shouldShowSignaturePage:wo]) {
//        [[AMDBManager sharedInstance] updateCaseTotalInvoicePriceByCaseID:wo.caseID withCompletion:^(NSInteger type, NSError *error) {
//            
//        }];
//    }
    
    [self updateWorkOrder:wo completionBlock:^(NSInteger type, NSError *error) {
        if (!error) {
            // add time and count to report
            NSDate *reportDate = [AMUtilities todayBeginningDate];
            
            AMDBReport *report1 = [[AMDBManager sharedInstance] getReportByDate:reportDate andRecordType:wo.recordTypeName];
            if (!report1) {
                report1 = [[AMDBManager sharedInstance] createNewReportInDB];
                report1.date = reportDate;
                report1.recordType = wo.recordTypeName;
            }
            
            AMDBReport *report2 = [[AMDBManager sharedInstance] getReportByDate:reportDate andRecordType:@"All"];
            if (!report2) {
                report2 = [[AMDBManager sharedInstance] createNewReportInDB];
                report2.date = reportDate;
                report2.recordType = @"All";
            }

            NSInteger addedMinutes = 0;
            if (wo.actualTimeStart && wo.actualTimeEnd) {
                addedMinutes = [wo.actualTimeEnd timeIntervalSinceDate:wo.actualTimeStart]/60;
            }
            
            for (AMDBReport *report in @[report1, report2]) {
                report.mcCompletedCount = @(report.mcCompletedCount.integerValue+1);
                report.myCompletedCount = @(report.myCompletedCount.integerValue+1);
                
                report.mcCompletedMinutes = @(report.mcCompletedMinutes.integerValue + addedMinutes);
                report.myCompletedMinutes = @(report.myCompletedMinutes.integerValue + addedMinutes);
            }
        }
        
        _checkInWO = nil;
        if (completionBlock) {
            completionBlock(type,error);
        }
        if (!error) {
            //when check out process finished, start syncing at once
            dispatch_async(dispatch_get_main_queue(), ^{
                DLog(@"start sync when check out finished");
                [self startSyncing];
            });
        }
    }];
}

- (void)updateWorkOrder:(AMWorkOrder *)workorder completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSMutableArray * woList = [NSMutableArray array];
    
    if (workorder) {
        [woList addObject:workorder];
        
        workorder.lastModifiedDate = [NSDate date];
        workorder.lastModifiedBy = _selfUId;
    }
    
    if (_checkInWO && [_checkInWO.woID isEqualToString:workorder.woID]) {//update to cached chekin wo
        _checkInWO.complaintCode = workorder.complaintCode;
        _checkInWO.notes = workorder.notes;
        _checkInWO.leftInOrderlyManner = workorder.leftInOrderlyManner;
        _checkInWO.testedAll = workorder.testedAll;
        _checkInWO.inspectedTubing = workorder.inspectedTubing;
    }
    
    [[AMDBManager sharedInstance] saveAsyncWorkOrderList:woList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}

- (void)updateCase:(AMCase *)amCase completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSMutableArray * caseList = [NSMutableArray array];
    
    if (amCase) {
        [caseList addObject:amCase];
        
        amCase.lastModifiedDate = [NSDate date];
        amCase.lastModifiedBy = _selfUId;
    }
    
    [[AMDBManager sharedInstance] saveAsyncCaseList:caseList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}

- (void)updateEvent:(AMEvent *)event completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSMutableArray * eventList = [NSMutableArray array];
    
    if (event) {
        [eventList addObject:event];
        
//        event.lastModifiedDate = [[AMProtocolManager sharedInstance] getTZTimeByLocalTime:[NSDate date]];
//        event.lastModifiedBy = _selfUId;
    }
    
    [[AMDBManager sharedInstance] saveAsyncEventList:eventList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}

- (void)assignWorkOrderToSelf:(AMWorkOrder *)workorder completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    workorder.ownerID = _selfUId;
    workorder.status = @"Scheduled";
    
    [[AMOnlineOprManager sharedInstance] assignWorkOrderToSelf:workorder completion:^(NSInteger type, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([workorder.woID isEqual:_curDisplayWO.woID]) {
                if (_curDisplayWO.woPoS) {
                    _curDisplayWO.woPoS.pendingWOList = [self getPoSPendingWorkOrderList:_curDisplayWO.woPoS.posID];
                }
                if (_curDisplayWO.woAccount) {
                    _curDisplayWO.woAccount.pendingWOList = [self getAccountPendingWorkOrderList:_curDisplayWO.woAccount.accountID];
                }
            }
            if (completionBlock) {
                completionBlock(type,error);
            }

        });
    }];
}

- (void)assignWorkOrderToSelfInNearMe:(NSString *)woId completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    [[AMOnlineOprManager sharedInstance] assignWorkOrderToSelfFromNearMe:woId completion:^(NSInteger type, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(type,error);
            }
        });
    }];
}

- (void)updatePoS:(AMPoS *)pos completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSMutableArray * posList = [NSMutableArray array];
    
    if (pos) {
        [posList addObject:pos];
        
        //pos.lastModifiedDate = [[AMProtocolManager sharedInstance] getTZTimeByLocalTime:[NSDate date]];
        pos.lastModifiedBy = _selfUId;
    }
    
    [[AMDBManager sharedInstance] saveAsyncPoSList:posList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}


- (void)addLocation:(AMLocation *)location completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSMutableArray * locationList = [NSMutableArray array];
    
    if (location) {
        [locationList addObject:location];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        location.fakeID = [NSString stringWithFormat:@"Create%@",[format stringFromDate:[NSDate date]]];
        location.locationID = location.fakeID;
        location.createdBy = _selfUId;
        location.dataStatus = @(EntityStatusCreated);
        if (!location.name && location.location) {
            location.name = location.location;
        }
    }
    
    [[AMDBManager sharedInstance] saveAsyncLocationList:locationList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}

- (void)updateLocation:(AMLocation *)location completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSMutableArray * locationList = [NSMutableArray array];
    
    if (location) {
        [locationList addObject:location];
        
        location.lastModifiedDate = [NSDate date];
        
//        if (!location.createdBy.length) {
            location.lastModifiedBy = _selfUId;
//        }
        if (![location.dataStatus isEqualToNumber:@(EntityStatusCreated)]) {
            location.dataStatus = @(EntityStatusModified);
        }
    }
    
    [[AMDBManager sharedInstance] saveAsyncLocationList:locationList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}

- (void)updateAsset:(AMAsset *)asset completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSMutableArray * assetList = [NSMutableArray array];
    
    if (asset) {
        [assetList addObject:asset];
        asset.lastModifiedDate = [NSDate date];
        asset.lastModifiedBy = _selfUId;
    }
    
    [[AMDBManager sharedInstance] saveAsyncAssetList:assetList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;

}

- (void)updateAssetList:(NSArray *)assetList completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    
    for (AMAsset * asset in assetList) {
        if (asset.assetID) {
            asset.lastModifiedDate = [NSDate date];
            asset.lastModifiedBy = _selfUId;
        }
    }
    
    [[AMDBManager sharedInstance] saveAsyncAssetList:assetList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}

- (void)updateContact:(AMContact *)contact shouldDelete:(BOOL)shouldDelete completionBlock:(AMDBOperationCompletionBlock)completionBlock {
    NSMutableArray * contactList = [NSMutableArray array];
    
    if (contact) {
        contact.lastModifiedBy = _selfUId;
        
        if (shouldDelete) {
            contact.shouldDelete = shouldDelete;
        }
        
        [contactList addObject:contact];
    }
    
    [[AMDBManager sharedInstance] saveAsyncContactList:contactList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}


//TODO: work order check out related interface

- (void)updateInvoice:(AMInvoice *)invoice completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSMutableArray * invoiceList = [NSMutableArray array];
    
    if (invoice) {
        [invoiceList addObject:invoice];
        invoice.lastModifiedDate = [NSDate date];
        invoice.lastModifiedBy = _selfUId;
    }
    
    [[AMDBManager sharedInstance] saveAsyncInvoiceList:invoiceList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}

- (void)saveInvoiceList:(NSArray *)invoiceList completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSInteger index = 0;
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    for (AMInvoice * invoice in invoiceList) {
        if (!invoice.invoiceID) {
            invoice.invoiceID = [NSString stringWithFormat:@"Create%d%@",index,[format stringFromDate:[NSDate date]]];
            invoice.createdBy = _selfUId;
        }
        index ++;
    }
    
    [[AMDBManager sharedInstance] saveAsyncInvoiceList:invoiceList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
}

- (void)saveAssetRequestList:(NSArray *)assetReqList completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSInteger index = 0;
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    for (AMAssetRequest * assetReq in assetReqList) {
        if (!assetReq.requestID) {
            assetReq.requestID = [NSString stringWithFormat:@"Create%d%@",index,[format stringFromDate:[NSDate date]]];
            assetReq.createdBy = _selfUId;
        }
        index ++;
    }
    
    [[AMDBManager sharedInstance] saveAsyncAssetRequestList:assetReqList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
}

- (void)saveFiltersUsed:(NSArray *)totalFilters completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSInteger index = 0;
    
    for (AMFilterUsed * filter in totalFilters) {
        if (!filter.fuID) {
            filter.fuID = [NSString stringWithFormat:@"Create%d%@",index,[format stringFromDate:[NSDate date]]];
            filter.createdBy = _selfUId;
            index ++;
        }
    }
    
    [[AMDBManager sharedInstance] saveAsyncFilterUsedList:totalFilters checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}

- (NSArray *)getFiltersUsedByInvoiceID:(NSString *)invoiceID
{
    return [[AMDBManager sharedInstance] getFilterUsedListByInvoiceID:invoiceID];
}

- (void)savePartsUsed:(NSArray *)totalParts completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSInteger index = 0;
    
    for (AMPartsUsed * parts in totalParts) {
        if (!parts.puID) {
            parts.puID = [NSString stringWithFormat:@"Create%d%@",index,[format stringFromDate:[NSDate date]]];
            parts.createdBy = _selfUId;
            index ++;
        }
    }

    [[AMDBManager sharedInstance] saveAsyncPartsUsedList:totalParts checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];
    return;
}

- (NSArray *)getPartsUsedListByInvoiceID:(NSString *)invoiceID
{
    return [[AMDBManager sharedInstance] getPartsUsedListByInvoiceID:invoiceID];
}

- (void)saveBestPoints:(AMBest *)bestPoint completionBlock:(AMDBOperationCompletionBlock)completionBlock
{
    NSMutableArray * bestList = [NSMutableArray array];
    
    if (bestPoint) {
        [bestList addObject:bestPoint];
    }
    
    [[AMDBManager sharedInstance] saveAsyncBestList:bestList checkExist:YES completion:^(NSInteger type, NSError *error) {
        if (completionBlock) {
            completionBlock(type,error);
        }
    }];

}

- (AMBest *)getBestPointsByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getBestPointByWOID:woID];
}

- (NSNumber *)getOwnHourRates
{
    if (!_hourRate) {
        _hourRate = [[NSUserDefaults standardUserDefaults] objectForKey:USRDFTHOURRATE];
    }
    return _hourRate;
}

- (BOOL)shouldShowSignaturePage:(AMWorkOrder *)wo
{
    NSArray * caseWOs = [self getCaseWorkOrderList:wo.caseID];
    BOOL shouldShow = YES;
    
    for (AMWorkOrder * wods in caseWOs) {
        if (![wods.status isEqualToLocalizedString:@"Closed"] && ![wods.woID isEqualToString:wo.woID]) {
            shouldShow = NO;
            break;
        }
    }
    return shouldShow;
}

//- (NSDate *)getCurrentServerTime
//{
//    return [[AMProtocolManager sharedInstance] getTZTimeByLocalTime:[NSDate date]];
//}

- (void)updateUserLocationWithLongitude:(NSNumber *)longitude andLatitude:(NSNumber *)latitude
{
    [[AMSyncingManager sharedInstance] updateCurrentLongitude:longitude andLatitude:latitude];
}

-(void)uploadCreatedCasesWithCompletion:(AMSFRestCompletionBlock)completionBlock;
{
    [[AMProtocolManager sharedInstance] uploadCreatedCasesWithCompletion:completionBlock];
}

-(void)uploadCreatedWorkOrdersWithCompletion:(AMSFRestCompletionBlock)completionBlock;
{
    [[AMProtocolManager sharedInstance] uploadCreatedWorkOrdersWithCompletion:completionBlock];
}


-(AMDBCustomerPrice *)getMaintainanceFeeByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getMaintainanceFeeByWOID:woID];
}

-(NSArray *)getFilterListByWOID:(NSString *)woID;
{
    return [[AMDBManager sharedInstance] getFilterListByWOID:woID];

}

-(NSArray *)getPMListByWOID:(NSString *)woID;
{
    return [[AMDBManager sharedInstance] getPMListByWOID:woID];
    
}
#pragma mark - Creation
-(AMDBNewCase *)createNewCaseInDB
{
    return [[AMDBManager sharedInstance] createNewCaseInDB];
}



- (NSArray *)getCreatedCasesHistoryByDayInRecentDays:(int)numberOfDays
{
    NSArray *cases = [[AMDBManager sharedInstance] getCreatedCasesHistoryInRecentDays:numberOfDays];
    NSArray *arrangedCases = [self arrangeArray:cases byDayKey:@"createdDate" inPastDays:numberOfDays andFutureDays:0];
    return arrangedCases;
}

//static int count = 0;

-(NSArray *)getReportDataArranged
{
//    count++;
//    DLog(@"start get report data %d", count);
    NSArray *array = [[AMDBManager sharedInstance] getAllReportData];
//    DLog(@"finish get report data %d", count);
    
//    return array;
    
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"recordType" ascending:YES];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];

    NSArray *sortedArray = [array sortedArrayUsingDescriptors:@[descriptor1, descriptor2]];

    NSMutableArray *arrangedArray = [NSMutableArray array];
    for (AMDBReport *report in sortedArray) {
        if ([report.recordType isEqualToString:[arrangedArray.lastObject allKeys].firstObject]) {
            NSMutableArray *subArray = [arrangedArray.lastObject allValues].firstObject;
            [subArray addObject:report];
        } else {
            NSMutableArray *subArray = [NSMutableArray array];
            [subArray addObject:report];
            [arrangedArray addObject:@{report.recordType: subArray}];
        }
    }
    
    return arrangedArray;
}

-(NSArray *)getReportDataRaw
{
    return [[AMDBManager sharedInstance] getAllReportData];
}


- (NSArray *)getArrangedSelfWorkOrderInPastDays:(int)numberOfDays
{
    NSArray *workOrders = [[AMDBManager sharedInstance] getSelfInvolvedWorkOrderInPastDays:numberOfDays];
    
    NSArray *closedWorkOrders = [workOrders filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status = 'Closed' AND actualTimeEnd != NULL"]];
    NSArray *array1 = [self arrangeArrayInArray:closedWorkOrders byDayKey:@"actualTimeEnd" inPastDays:numberOfDays andFutureDays:0];
    
    NSArray *unClosedWorkOrders = [workOrders filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status != 'Closed' AND status != 'Queued' AND estimatedTimeStart != NULL"]];
    NSArray *array2 = [self arrangeArrayInArray:unClosedWorkOrders byDayKey:@"estimatedTimeStart" inPastDays:numberOfDays andFutureDays:0];
    
    NSMutableArray *arrangedWorkOrders = [NSMutableArray array];
    for (int i=0; i<numberOfDays; i++) {
        NSMutableArray *subArray = [NSMutableArray arrayWithArray:array1[i]];
        [subArray addObjectsFromArray:array2[i]];
        [arrangedWorkOrders addObject:subArray];
    }
    
    return arrangedWorkOrders;
    
//    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"actualTimeEnd" ascending:YES];
//    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    NSArray * sortedArray = [closedWorkOrders sortedArrayUsingDescriptors:sortDescriptors];
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    calendar.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
//    
//    NSMutableArray * summaryHistory = [NSMutableArray array];
//    
//    if (sortedArray && sortedArray.count)
//    {
//        NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
//        components.hour = 0;
//        components.minute = 0;
//        components.second = 0;
//        NSDate *date = [calendar dateFromComponents:components];
//        NSDate *startDate = [date dateByAddingTimeInterval:-(numberOfDays-1)*24*60*60];
//        
//        // put first array to be ready
//        NSMutableArray *subArray = [NSMutableArray array];
//        [summaryHistory addObject:subArray];
//        
//        for (AMWorkOrder * wo in sortedArray)
//        {
//            NSDateComponents* components = [calendar components:NSDayCalendarUnit fromDate:startDate toDate:wo.estimatedTimeStart options:0];
//            if (components.day > 0) {
//                for (int i=0; i<components.day; i++) {
//                    NSMutableArray *subArray = [NSMutableArray array];
//                    [summaryHistory addObject:subArray];
//                }
//                startDate = [startDate dateByAddingTimeInterval: components.day * 24*60*60];
//            } else if (components.day < 0) {
//                break;
//            }
//            NSMutableArray *subArray = [summaryHistory lastObject];
//            [subArray addObject:wo];
//        }
//    }
//    
//    if (summaryHistory.count < numberOfDays) {
//        int lack = numberOfDays - summaryHistory.count;
//        for (int i=0; i<lack; i++) {
//            NSMutableArray *array = [NSMutableArray array];
//            [summaryHistory addObject:array];
//        }
//    }
    

}


-(NSString *)getRecordTypeNameById:(NSString *)id forObject:(NSString *)object;
{
    return [[AMDBManager sharedInstance] getRecordTypeNameById:id forObject:object];
}

-(NSString *)getRecordTypeIdByName:(NSString *)name forObject:(NSString *)object;
{
    return [[AMDBManager sharedInstance] getRecordTypeIdByName:name forObject:object];
}

-(NSArray *)getAttachmentsByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getAttachmentsByWOID:woID];
}

-(void)createNewAttachmentInDBWithSetupBlock:(void(^)(AMDBAttachment *newAttachment))block
                                  completion:(AMDBOperationCompletionBlock)completionBlock
{
    return [[AMDBManager sharedInstance] createNewAttachmentInDBWithSetupBlock:block completion:completionBlock];
}


-(NSTimeZone *)timeZoneOnSalesforce
{
    return [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
}

-(void)createNewWorkOrderInDBWithAMWorkOrder:(AMWorkOrder *)workOrder
                        additionalSetupBlock:(void(^)(AMDBNewWorkOrder *newAttachment))setupBlock
                                  completion:(AMDBOperationCompletionBlock)completionBlock
{
    [[AMDBManager sharedInstance] createNewWorkOrderInDBWithAMWorkOrder:workOrder
                                                   additionalSetupBlock:setupBlock
                                                             completion:completionBlock];
}

- (NSArray *)getInvoiceListByCaseID:(NSString *)caseID
{
    return [[AMDBManager sharedInstance] getInvoiceListByCaseID:caseID];
}

-(void)createNewCaseInDBWithSetupBlock:(void(^)(AMDBNewCase *newCase))setupBlock
                            completion:(AMDBOperationCompletionBlock)completionBlock
{
    [[AMDBManager sharedInstance] createNewCaseInDBWithSetupBlock:setupBlock completion:completionBlock];
}

-(void)createNewContactInDBWithSetupBlock:(void(^)(AMDBNewContact *newContact))setupBlock
                               completion:(AMDBOperationCompletionBlock)completionBlock
{
    [[AMDBManager sharedInstance] createNewContactInDBWithSetupBlock:setupBlock completion:completionBlock];
}

-(void)saveManagedObject:(NSManagedObject *)object completion:(AMDBOperationCompletionBlock)completionBlock
{
    [[AMDBManager sharedInstance] saveManagedObject:object completion:completionBlock];
}

- (AMContact *)getContactInfoByID:(NSString *)contactID
{
    return [[AMDBManager sharedInstance] getContactInfoByID:contactID];
}

- (void)deleteContactById:(NSString *)contactId completion:(AMDBOperationCompletionBlock)completionBlock
{
    
}

- (void)deleteInvoiceById:(NSString *)invoiceId completion:(AMDBOperationCompletionBlock)completionBlock
{
    [[AMDBManager sharedInstance] deleteInvoiceById:invoiceId completion:completionBlock];
}

-(void)createNewLeadInDBWithSetupBlock:(void(^)(AMDBNewLead *newLead))block
                            completion:(AMDBOperationCompletionBlock)completionBlock
{
    [[AMDBManager sharedInstance] createNewLeadInDBWithSetupBlock:block completion:completionBlock];
}

- (NSArray *)getCreatedLeadsForUpload
{
    return [[AMDBManager sharedInstance] getCreatedLeadsForUpload];
}

- (NSArray *)getCreatedLeadsHistoryByDayInRecentDays:(int)numberOfDays
{
    NSArray *leads = [[AMDBManager sharedInstance] getCreatedLeadsHistoryInRecentDays:numberOfDays];
    NSArray *arrangedLeads = [self arrangeArray:leads byDayKey:@"createdDate" inPastDays:numberOfDays andFutureDays:0];
    
    return arrangedLeads;
}

- (void)deleteAttachment:(AMDBAttachment *)attachment completion:(AMDBOperationCompletionBlock)completionBlock
{
    // do not allow delete during sync
    if ([[AMSyncingManager sharedInstance] isSyncing]) {
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"Sync in process. Please try later.")}];
        completionBlock(AM_DBOPR_DEL, error);
        return;
    }
    
    if (![attachment.createdById isEqualToString:_selfUId]) {
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"can not delete attachment not created by self")}];
        completionBlock(AM_DBOPR_DEL, error);
    }
    else if ([attachment.dataStatus isEqualToNumber: @(EntityStatusCreated)]) {
        [[AMDBManager sharedInstance] deleteAttachment:attachment completion:completionBlock];
    }
    else {
        [[AMDBManager sharedInstance] markDeleteAttachment:attachment completion:completionBlock];
    }
    
    
    /* delete logic changed to above
    if ([attachment.dataStatus isEqualToNumber: @(EntityStatusFromSalesforce)]) {
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: @"can not delete attachment download from salesforce"}];
        completionBlock(AM_DBOPR_DEL, error);
    }
    else if ([attachment.dataStatus isEqualToNumber: @(EntityStatusSyncSuccess)]) {
        [[AMDBManager sharedInstance] markDeleteAttachment:attachment completion:completionBlock];
    }
    else {
        [[AMDBManager sharedInstance] deleteAttachment:attachment completion:completionBlock];
    }
    */
}

-(void)uploadCreatedNewLeadsWithCompletion:(AMSFRestCompletionBlock)completionBlock
{
    NSArray *newLeads = [[AMDBManager sharedInstance] getCreatedLeadsForUpload];
    
    if (newLeads.count) {
        [[AMProtocolManager sharedInstance] uploadNewLeads:newLeads operationType:AM_REQUEST_UPDATEOBJECTS completion:completionBlock];
    } else {
//        NSError *error = [NSError errorWithDomain:@"network" code:0 userInfo:@{NSLocalizedDescriptionKey: @"no new leads for upload"}];
        completionBlock(AM_REQUEST_UPDATEOBJECTS, nil, nil, nil);
    }

}

-(NSArray *)getLocalAttachmentsByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getLocalAttachmentsByWOID:woID];
}

-(NSArray *)getRemoteAttachmentsByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getRemoteAttachmentsByWOID:woID];
}

-(NSArray *)getRecordTypeListForObjectType:(NSString *)objectType
{
    return [[AMDBManager sharedInstance] getRecordTypeListForObjectType:objectType];
}

- (void)clearCache {
    //step1. start sync process
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[AMSyncingManager sharedInstance] startSyncing:^(NSInteger type, NSError * error){
        if (error && [error.localizedDescription rangeOfString:kAM_MESSAGE_SYNC_IN_PROCESS].location != NSNotFound) {
            [AMUtilities showAlertWithInfo:MyLocal(@"Please try again after sync is done")];
            [SVProgressHUD dismiss];
            return;
        }
        if (error) {
            [self syncingCompletion:error];
            [SVProgressHUD dismiss];
            return;
        }
        //step2.
        [self resetToInitialization:^(NSInteger type, NSError *error) {
            [SVProgressHUD dismiss];
            [self syncingCompletion:error];
        }];
    }];
    
}

- (void)resetToInitialization:(AMDBOperationCompletionBlock)initCompletionHandler
{
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:USRDFTSELFUID];
    [self startInitialization:initCompletionHandler];
}

- (NSArray *)getTodayCheckInWorkOrders
{
    return [[AMDBManager sharedInstance] getTodayCheckInWorkOrders];
}

- (NSArray *)getInvoiceListByWOID:(NSString *)woID recordTypeName:(NSString *)recordTypeName
{
    return [[AMDBManager sharedInstance] getInvoiceListByWOID:woID recordTypeName:recordTypeName];
}

-(NSArray *)getInvoiceCodeListByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getInvoiceCodeListByWOID:woID];
}

-(void)moveWorkOrderToToday:(AMWorkOrder *)workOrder completion:(AMDBOperationCompletionBlock)completionBlock
{
    if ([workOrder.status isEqualToLocalizedString:@"Scheduled"]
        && [workOrder.ownerID isEqualToString:[AMDBManager sharedInstance].selfId]) {
        workOrder.lastModifiedBy = _selfUId;
        [[AMDBManager sharedInstance] moveWorkOrderToToday:workOrder completion:completionBlock];
    } else {
        NSError *error = [NSError errorWithDomain:@"database" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"Work order status is not \"Scheduled\" or you are not the work order owner.")}];
        completionBlock(AM_DBOPR_SAVE, error);
    }
}

-(NSArray *)getSelfCreatedAttachmentsByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getSelfCreatedAttachmentsByWOID:woID];
}

-(NSArray *)getOtherCreatedAttachmentsByWOID:(NSString *)woID
{
    return [[AMDBManager sharedInstance] getOtherCreatedAttachmentsByWOID:woID];
}

-(NSArray *)getPicklistOfComplaintCodeInWorkOrder
{
    return [[AMDBManager sharedInstance] getPicklistOfComplaintCodeInWorkOrder];
}

- (void)setupOfflineData
{
    [AMDBManager sharedInstance].selfId = [USER_DEFAULT objectForKey:USRDFTSELFUID];
    [AMLogicCore sharedInstance].selfUId = [USER_DEFAULT objectForKey:USRDFTSELFUID];
    [AMInitailManager sharedInstance].selfUId = [USER_DEFAULT objectForKey:USRDFTSELFUID];
    [AMSyncingManager sharedInstance].timeStamp = [USER_DEFAULT objectForKey:USRLASTSYNCTIMESTAMP];
    [AMDBManager sharedInstance].timeStamp = [USER_DEFAULT objectForKey:USRLASTSYNCTIMESTAMP];
}

-(void)searchNearByWorkOrders:(CLLocationCoordinate2D)coordinate distance:(float)radius withCompletion:(AMSFRestCompletionBlock)completionBlock
{
    [[AMProtocolManager sharedInstance] searchNearByWOs:coordinate distance:radius withCompletion:completionBlock];
}

- (void)getWorkOrderRequiredInfo:(NSArray *)woIds withCompletionBlock:(AMSFRestCompletionBlock)completionBlock
{
    [[AMProtocolManager sharedInstance] getWorkOrderRequiredInfo:woIds withCompletionBlock:completionBlock];
}

@end






