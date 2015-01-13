//
//  AMInitailManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/25/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMInitailManager.h"
#import "AMProtocolManager.h"
#import "AMDBManager.h"
#import "AMFileCache.h"
#import "AMWorkOrder.h"
#import "AMAsset.h"
#import "AMWOTypeManager.h"

typedef enum AM_Initial_Step_t {
    AM_Initial_Step_InitialWO = 0,
    AM_Initial_Step_RecentWO,
    AM_Initial_Step_OtherWO,
    //AM_Initial_Step_AccountWO,
    //AM_Initial_Step_PoSWO,
    //AM_Initial_Step_PoS28WO,
    //AM_Initial_Step_CaseWO,
    //AM_Initial_Step_AssetWO,
//    AM_Initial_Step_UserList,
    AM_Initial_Step_Report,
    //AM_Initial_Step_AccountList,
    //AM_Initial_Step_PoSList,
    //AM_Initial_Step_AssetList,
    //AM_Initial_Step_CaseList,
    //AM_Initial_Step_LocationList,
    //AM_Initial_Step_ContactList,
    //AM_Initial_Step_PartsList,
    //AM_Initial_Step_FilterList,
    //AM_Initial_Step_InvoiceList,
    AM_Initial_Step_Total
    
}AM_Initial_Step_Type;

@interface AMInitailManager ()
{
    NSString * _selfUId;
    NSInteger _initialSteps;
    BOOL _isInitializing;
    BOOL _hasInitialNetError;
    NSDate * _timeStamp;
    NSError * _initialError;
    AMWOTypeManager * _woTypeManager;
}

@property (nonatomic, copy) AMDBOperationCompletionBlock initialComplteHandler;

@end

@implementation AMInitailManager

@synthesize selfUId = _selfUId;
@synthesize timeStamp = _timeStamp;

#pragma mark - Internal Methods

- (void)handleInitialDBProcess:(NSInteger) type
{
    _initialSteps ++;
    DLog(@"handleInitialDBProcess steps %d of total %d, cur %d, hasError %d", _initialSteps,AM_Initial_Step_Total,type,_hasInitialNetError);
    if (_initialSteps >= AM_Initial_Step_Total || _hasInitialNetError) {
//        if (!_hasInitialNetError) {
//            [[AMDBManager sharedInstance] updateUser:_selfUId timeStamp:_timeStamp];
//        }
        
        if (self.initialComplteHandler) {
            [[AMProtocolManager sharedInstance] downloadUnfetchedAttachments];
            self.initialComplteHandler(AM_DBOPR_CLEARALL,_initialError);
        }
        _isInitializing = NO;
        _hasInitialNetError = NO;
        _initialError = nil;
    }
}

- (void)requestOtherTypeWOList:(NSArray *)woList
{
    //Get User list, Don't need to call getUserList anymore
//    [[AMProtocolManager sharedInstance] getUserList:^(NSInteger type, NSError * error, id userData, id responseData){
//        [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
//    }];

    //Get WO list past5
    [[AMProtocolManager sharedInstance] getWorkOrderListByType:AM_NWWOLIST_RECENT timeStamp:nil withIDList:nil completion:^(NSInteger type, NSError * error, id userData, id responseData){
        [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
    }];
    
    //Get Report
    [[AMProtocolManager sharedInstance] getReportDataWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
        if (!error && [responseData isKindOfClass:[NSDictionary class]]) {
            [[AMDBManager sharedInstance] saveAsyncReportDictionaryFromSalesforce:responseData completion:^(NSInteger type, NSError *error) {
                if (error) {
                    DLog(@"save report error: %@", error.localizedDescription);
                    _initialError = error;
                }
            }];
            [self handleInitialDBProcess:AM_Initial_Step_Report];
        } else {
            DLog(@"get report error: %@", error.localizedDescription);
            _initialError = error;
            [self handleInitialDBProcess:AM_Initial_Step_Report];

        }
    }];
    
    if (!_woTypeManager) {
        _woTypeManager = [[AMWOTypeManager alloc] init];
    }
    [_woTypeManager getWOListByType:woList completion:^(NSInteger type, NSError * error){
        [self handleInitialDBProcess:AM_Initial_Step_OtherWO];
    }];

}

- (void)protocolHandlerWithType:(NSInteger)type retErro:(NSError *)error userData:(id)userData responseData:(id)responseData
{
    //NSDictionary * userDict = (NSDictionary *)userData;
    NSDictionary * retDict = (NSDictionary *)responseData;
    NSNumber * isSuccess = [retDict objectForKey:NWRESPRESULT];
      
    if (error) {
        _hasInitialNetError = YES;
        _initialError = error;
    }
    else if ([isSuccess intValue] == 0){
        _hasInitialNetError = YES;
        NSError * localError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"Server logic error")}];
        _initialError = localError;
    }
    
    switch (type) {
        case AM_REQUEST_GETACCOUNTLST:
        {
            
        }
            break;
        case AM_REQUEST_GETASSETLST:
        {
            
        }
            break;
        case AM_REQUEST_GETCASELST:
        {
            
        }
            break;
        case AM_REQUEST_GETCONTACTLST:
        {
            
        }
            break;
        case AM_REQUEST_GETWOLST:
        {
            NSArray * woList = (NSArray *)[retDict objectForKey:NWRESPDATA];
            //AM_NWWOLIST_Type eType = [[userDict objectForKey:@"type"] intValue];
            BOOL checkExist = YES;
            
            if (woList && woList.count) {//success
                [[AMDBManager sharedInstance] saveAsyncWorkOrderList:woList checkExist:checkExist completion:^(NSInteger type, NSError * error){
                    
                    [self handleInitialDBProcess:AM_Initial_Step_RecentWO];
                }];
            }
            else {
                
                [self handleInitialDBProcess:AM_Initial_Step_RecentWO];
            }
        }
            break;
        case AM_REQUEST_GETLOCATIONLST:
        {
            
        }
            break;
        case AM_REQUEST_GETPOSLST:
        {
            
        }
            break;
        case AM_REQUEST_GETPARTLST:
        {
            
        }
            break;
        case AM_REQUEST_GETFILTERLST:
        {
            
        }
            break;
        case AM_REQUEST_GETINVOICELST:
        {
            
        }
            break;
        case AM_REQUEST_GETUSERLIST:
        {
//            NSArray * userList = (NSArray *)[retDict objectForKey:NWRESPDATA];
//            NSNumber * hourRate = [retDict objectForKey:NWHOURRATE];
//            
//            if (hourRate) {
//                NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
//                
//                [userDefaults setObject:hourRate forKey:USRDFTHOURRATE];
//                [userDefaults synchronize];
//            }
//            
//            if (userList && userList.count) {
//                [[AMDBManager sharedInstance] saveAsyncUserList:userList checkExist:YES completion:^(NSInteger type, NSError * error){
//
//                    [self handleInitialDBProcess:AM_Initial_Step_UserList];
//                }];
//            }
//            else {
//                [self handleInitialDBProcess:AM_Initial_Step_UserList];
//            }
            
        }
            break;
        case AM_REQUEST_GETINITIALLOAD:
        {
            NSDictionary * dataDict = (NSDictionary *)[retDict objectForKey:NWRESPDATA];
            NSArray * woList = [dataDict objectForKey:@"AMWorkOrder"];
            
            if (!error && [isSuccess intValue]) {
                if ([retDict objectForKey:NWTIMESTAMP]) {
                    _timeStamp = [retDict objectForKey:NWTIMESTAMP];
                }
                
                [self requestOtherTypeWOList:woList];//wo
                
                [[AMDBManager sharedInstance] saveAsyncInitialSyncLoadList:dataDict checkExist:YES completion:^(NSInteger type, NSError * error){
                    [self handleInitialDBProcess:AM_Initial_Step_InitialWO];
                }];
            }
            else {
                [self handleInitialDBProcess:AM_Initial_Step_InitialWO];
            }
            
        }
            break;
        case AM_REQUEST_GETREPORTDATA:
        {
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - Methods
+ (AMInitailManager *)sharedInstance
{
    static AMInitailManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMInitailManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)startInitialization:(AMDBOperationCompletionBlock)initCompletionHandler
{
    if (_isInitializing) {
        return;
    }
    
    self.initialComplteHandler = initCompletionHandler;
    _initialSteps = 0;
    _isInitializing = YES;
    _hasInitialNetError = NO;
    _initialError = nil;
    
    /*[[AMProtocolManager sharedInstance] getWorkOrderListByType:AM_NWWOLIST_RECENT timeStamp:nil withIDList:nil completion:^(NSInteger type, NSError * error, id userData, id responseData){
        [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
    }];*/
    
    [[AMProtocolManager sharedInstance] getInitialLoad:^(NSInteger type, NSError * error, id userData, id responseData){
     [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
     }];
}

@end




