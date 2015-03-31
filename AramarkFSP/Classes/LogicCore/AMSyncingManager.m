//
//  AMSyncingManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMSyncingManager.h"
#import "AMProtocolManager.h"
#import "AMDBManager.h"
#import "AMFileCache.h"
#import "AMWorkOrder.h"
#import "AMAsset.h"
#import "AMFileCache.h"
#import "AMWOTypeManager.h"
#import "SFNetworkEngine.h"
#import "AMUser.h"
#import "AMInitailManager.h"


/************************************************************************************************
 
 Sync order:
 1. startSyncing (checkReadinessForInitializationWithCompletion)
 2. startUpdatingLocalAddedStep1 (createObjectsWithData: createdLocation, createdInvoice)
 3. startUpdatingLocalAddedStep2 (createObjectsWithData: createdAssetReq)
 4. actionsAfterAddObjectStep2 (uploadCreatedCasesWithCompletion -> uploadCreatedWorkOrdersWithCompletion)
 5. startCheckingFromSFDC (syncDataWithTimeStamp)
 6. actionsAfterUpdateFromeSalesforce (updateLocalModifiedData, uploadAttachments, uploadNewLeads, deleteAttachments)
 7. updateLocalModifiedData (updateObjectWithData)
 8. updateReport
 
 Please Note: Suppose run step 5 at the end of the process if need upload local modified data firstly then merge SF data to local
 
************************************************************************************************/


typedef enum AM_Update_Step_t {
    AM_Update_Step_SFDCLatest = 0,
    AM_Update_Step_OtherWO,
    AM_Update_Step_Report,
    AM_Update_Step_ADDCREATE,
    AM_Update_Step_ADDCREATE2,
    AM_Update_Step_UpdateLocal,
//    AM_Update_Step_UploadSignature,
    AM_Update_Step_UploadAttachments,
    AM_Update_Step_DeleteAttachments,
    AM_Update_Step_UploadNewLeads,
    AM_Update_Step_Total
    
}AM_Update_Step_Type;

#define CHECKSYNCTIMEINTERVAL 60.0 * 10

@interface AMSyncingManager ()
{
    NSString * _selfUId;
    NSInteger _updateSteps;
    BOOL _isUpdating;
    BOOL _hasUpdateNetError;
    NSError * _updateNetError;
    NSDate * _timeStamp;
    NSDate * _tempTimeStamp;
    BOOL _netStatus;
    
    NSTimer * _syncCheckTimer;
    AMWOTypeManager * _woTypeManager;
    
    NSNumber * _curLongitude;
    NSNumber * _curLatitude;
    NSDate *_positionTimestamp;
}

@property (nonatomic, copy) AMDBOperationCompletionBlock updateComplteHandler;

@end

@implementation AMSyncingManager

@synthesize selfUId = _selfUId;
@synthesize timeStamp = _timeStamp;

#pragma mark - Internal Methods

- (void)handleUpdateDBProcess:(NSInteger) type
{
    if (!_isUpdating) {
        return;
    }
    _updateSteps ++;
    DLog(@"handleUpdateDBProcess steps %d of total %d, cur %d, error %d", _updateSteps,AM_Update_Step_Total,type,_hasUpdateNetError);
    if (_updateSteps >= AM_Update_Step_Total || _hasUpdateNetError) {
        if (!_hasUpdateNetError && _tempTimeStamp) {
            _timeStamp = _tempTimeStamp;
            _tempTimeStamp = nil;
            [[AMDBManager sharedInstance] setTimeStamp:_timeStamp];
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:_timeStamp forKey:USRLASTSYNCTIMESTAMP];
            [userDefaults synchronize];
            //[[AMDBManager sharedInstance] updateUser:_selfUId timeStamp:_timeStamp];
        }
        
        if (self.updateComplteHandler) {
            [self sendRefreshNotification];
            [[AMProtocolManager sharedInstance] downloadUnfetchedAttachments];
            self.updateComplteHandler(AM_DBOPR_SAVESFDCLATEST,_updateNetError);
        }
        
        _updateSteps = 0;
        _isUpdating = NO;
        _hasUpdateNetError = NO;
        _updateNetError = nil;
    }

}

- (NSDictionary *)fakeSuccessRetDict
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[NSNumber numberWithInt:1] forKey:NWRESPRESULT];
    return dict;
}

//- (void)uploadSignature
//{
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"self BEGINSWITH[cd] %@",SIGNATUREFILEPREFIX];
//    NSArray * signFiles = [[AMFileCache sharedInstance] getFilesListByFilter:filter];
//    NSMutableArray * signDictList = [NSMutableArray array];
//    
//    for (NSString * fileName in signFiles) {
//        NSData * fileData = [[AMFileCache sharedInstance] getFile:fileName];
//        NSString * caseID = [fileName stringByReplacingOccurrencesOfString:SIGNATUREFILEPREFIX withString:@""];
//        NSMutableDictionary * signDict = [NSMutableDictionary dictionary];
//        
//        if (fileData && caseID) {
//            [signDict setObject:fileData forKey:@"Data"];
//            [signDict setObject:caseID forKey:@"Name"];
//            
//            [signDictList addObject:signDict];
//        }
//    }
//
//    if (signDictList && signDictList.count) {
//        [[AMProtocolManager sharedInstance] uploadPhotos:signDictList completion:^(NSInteger type, NSError * error, id userData, id responseData){
//            [self protocolHandlerWithType:AM_REQUEST_UPLOADSIGNATURE retErro:error userData:userData responseData:responseData];
//        }];
//    }
//    else {
//        [self protocolHandlerWithType:AM_REQUEST_UPLOADSIGNATURE retErro:nil userData:nil responseData:[self fakeSuccessRetDict]];
//    }
//    
//}

- (void)deleteLocalSignature:(NSArray *)signArray
{
    for (NSDictionary * dict in signArray) {
        NSString * woID = [dict objectForKey:@"Name"];
        NSString * fileName = [NSString stringWithFormat:@"%@%@",SIGNATUREFILEPREFIX,woID];
        
        [[AMFileCache sharedInstance] removeFile:fileName];
    }
}

//update local modified data to SFDC
- (void)updateLocalModifiedData
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSArray * woList = [[AMDBManager sharedInstance] getModifiedWorkOrder];
    NSArray * assetList = [[AMDBManager sharedInstance] getModifiedAsset];
    NSArray * locationList = [[AMDBManager sharedInstance] getModifiedLocation];
    NSArray * contactList = [[AMDBManager sharedInstance] getModifiedContacts];
    if ([locationList count]) {
        DLog(@"modified location: %@", locationList);
    }
    //NSArray * invoiceList = [[AMDBManager sharedInstance] getModifiedInvoice];
//    NSArray * posList = [[AMDBManager sharedInstance] getModifiedInvoice];
    NSArray * caseList = [[AMDBManager sharedInstance] getModifiedCase];
    NSMutableArray * userList = [NSMutableArray array];
    AMUser * selfUser = [[AMUser alloc] init];
    
    if (_curLongitude && _curLatitude && [AMInitailManager sharedInstance].selfUId) {
        selfUser.longitude = _curLongitude;
        selfUser.latitude = _curLatitude;
        selfUser.userID = [AMInitailManager sharedInstance].selfUId;
        selfUser.positionTimestamp = _positionTimestamp;
        [userList addObject:selfUser];
        
        [dict setObject:userList forKey:@"AMUser"];
    }
    if (woList && woList.count) {
        [dict setObject:woList forKey:@"AMWorkOrder"];
    }
    if (assetList && assetList.count) {
        [dict setObject:assetList forKey:@"AMAsset"];
    }
    if (locationList && locationList.count) {
        [dict setObject:locationList forKey:@"AMLocation"];
    }
//    if (invoiceList && invoiceList.count) {
//        [dict setObject:invoiceList forKey:@"AMInvoice"];
//    }
//    if (posList && posList.count) {
//        [dict setObject:posList forKey:@"AMPoS"];
//    }
    if (caseList && caseList.count) {
        [dict setObject:caseList forKey:@"AMCase"];
    }
    
    if (contactList && contactList.count) {
        [dict setObject:contactList forKey:@"AMContact"];
    }
    
    if ([[dict allKeys] count]) {
        [[AMProtocolManager sharedInstance] updateObjectWithData:dict completion:^(NSInteger type, NSError * error, id userData, id responseData){
            [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
        }];
    }
    else {
        [self protocolHandlerWithType:AM_REQUEST_UPDATEOBJECTS retErro:nil userData:nil responseData:[self fakeSuccessRetDict]];
    }
}

//Handel Add/Edit/Delete records, If syncing have data return,
- (void)handleSyncingResul:(NSDictionary *)syncingData completion:(AMDBOperationCompletionBlock)completionBlock
{
    NSDictionary * addObjects = [syncingData objectForKey:@"Add"];
    NSDictionary * editObjects = [syncingData objectForKey:@"Edit"];
    NSDictionary * deleteObjects = [syncingData objectForKey:@"Delete"];
    
    //[self handleSaveAddEditData:addObjects];//handle new added records
    [[AMDBManager sharedInstance] saveAsyncInitialSyncLoadList:addObjects checkExist:YES completion:^(NSInteger type, NSError * error)
    {
        //[self handleSaveAddEditData:editObjects];//handel edited records
        [[AMDBManager sharedInstance] saveAsyncInitialSyncLoadList:editObjects checkExist:YES completion:^(NSInteger type, NSError * error)
        {

            [[AMDBManager sharedInstance] deleteLocalObjects:deleteObjects completion:^(NSInteger type, NSError * error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //start updating local added records after handling add/edit/delete records from SFDC
                    [self handleUpdateDBProcess:AM_Update_Step_SFDCLatest];//This step is the last step of Add/Edit/Del save
                    
                });
                if ((addObjects && [addObjects objectForKey:@"AMWorkOrder"]) ||
                    (deleteObjects && ([deleteObjects objectForKey:@"AMWorkOrder"] || [deleteObjects objectForKey:@"AMEvent"]))) {
                    //            [self sendRefreshNotification];
                }
                completionBlock(AM_DBOPR_SAVE, error);
            }];
        }];
    }];
    if (addObjects && [addObjects objectForKey:@"AMWorkOrder"]) {//handle new added wos, request other related data
        //[self requestOtherTypeWOList:[addObjects objectForKey:@"AMWorkOrder"]];
        if (!_woTypeManager) {
            _woTypeManager = [[AMWOTypeManager alloc] init];
        }
        NSArray * woList = [addObjects objectForKey:@"AMWorkOrder"];
        [_woTypeManager getWOListByType: woList completion:^(NSInteger type, NSError * error){
            [self handleUpdateDBProcess:AM_Update_Step_OtherWO];
        }];
    }
    else
    {
        [self handleUpdateDBProcess:AM_Update_Step_OtherWO];
    }



}

-(void)sendRefreshNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{//notify ui to refresh today's wo list
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        
        [userInfo setObject:TYPE_OF_REFRESH_WORKORDERLIST forKey:KEY_OF_TYPE];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_LOGICCORE object:userInfo];
    });
}

/**
 * Start Updating
 */
- (void)startUpdatingLocalAddedStep1
{
    
    NSArray * createdLocation = [[AMDBManager sharedInstance] getCreatedLocation];
    if (createdLocation.count) {
        DLog(@"created location: %@", createdLocation);
    }
    NSArray * createdInvoice = [[AMDBManager sharedInstance] getCreatedInvoices];
    //NSArray * createdFilterUsed = [[AMDBManager sharedInstance] getCreatedFilterUsed];
    //NSArray * createdPartsUsed = [[AMDBManager sharedInstance] getCreatedPartsUsed];
//    NSArray *createdWorkOrders = [[AMDBManager sharedInstance] getCreatedWorkOrder];
//    NSArray *createdCases = [[AMDBManager sharedInstance] getCreatedCase];
    NSMutableDictionary * createDict = [NSMutableDictionary dictionary];
    
    if (createdLocation && createdLocation.count) {
        [createDict setObject:createdLocation forKey:@"AMLocation"];
    }
    if (createdInvoice && createdInvoice.count) {
        [createDict setObject:createdInvoice forKey:@"AMInvoice"];
    }
//    if ([createdWorkOrders count]) {
//        [createDict setObject:createdWorkOrders forKey:@"AMWorkOrder"];
//    }
//    if ([createdCases count]) {
//        [createDict setObject:createdCases forKey:@"AMCase"];
//    }
    
    if ([createDict allKeys].count) {
        [[AMProtocolManager sharedInstance] createObjectsWithData:createDict oprationType:AM_REQUEST_ADDOBJECTSSTEP1 completion:^(NSInteger type, NSError * error, id userData, id responseData){
            [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
        }];
    }
    else
    {
        [self protocolHandlerWithType:AM_REQUEST_ADDOBJECTSSTEP1 retErro:nil userData:nil responseData:[self fakeSuccessRetDict]];
    }
    
}

- (void)startUpdatingLocalAddedStep2
{
    
    NSArray * createdAssetReq = [[AMDBManager sharedInstance] getCreatedAssetRequests];
    NSMutableDictionary * createDict = [NSMutableDictionary dictionary];
    
    if (createdAssetReq && createdAssetReq.count) {
        [createDict setObject:createdAssetReq forKey:@"AMAssetRequest"];
    }
    
    if ([createDict allKeys].count) {
        [[AMProtocolManager sharedInstance] createObjectsWithData:createDict oprationType:AM_REQUEST_ADDOBJECTSSTEP2 completion:^(NSInteger type, NSError * error, id userData, id responseData){
            [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
        }];
    }
    else
    {
        [self protocolHandlerWithType:AM_REQUEST_ADDOBJECTSSTEP2 retErro:nil userData:nil responseData:[self fakeSuccessRetDict]];
    }
    
}

-(void)updateReport
{
    [[AMProtocolManager sharedInstance] getReportDataWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
        if (!error && [responseData isKindOfClass:[NSDictionary class]]) {
            [[AMDBManager sharedInstance] saveAsyncReportDictionaryFromSalesforce:responseData completion:^(NSInteger type, NSError *error) {
                if (error) {
                    _updateNetError = error;
                    DLog(@"save report error: %@", error.localizedDescription);
                }
            }];
            [self handleUpdateDBProcess:AM_Update_Step_Report];
        } else {
            _updateNetError = error;
            DLog(@"get report error: %@", error.localizedDescription);
            [self handleUpdateDBProcess:AM_Update_Step_Report];
        }
    }];
}

-(void)uploadNewLeads
{
    [[AMLogicCore sharedInstance] uploadCreatedNewLeadsWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
        if (error) {
            DLog(@"save report error: %@", error.localizedDescription);
            _updateNetError = error;
        }
        [self handleUpdateDBProcess:AM_Update_Step_UploadNewLeads];
    }];
}

-(void)uploadAttachments
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *attachments = [[AMDBManager sharedInstance] getAttachmentsForUpload];
        if (attachments.count) {
            [[AMProtocolManager sharedInstance] uploadAttachments:attachments completion:^(NSInteger type, NSError *error, id userData, id responseData) {
                if (error) {
                    DLog(@"save report error: %@", error.localizedDescription);
                    _updateNetError = error;
                }
                [self handleUpdateDBProcess:AM_Update_Step_UploadAttachments];
            }];
        } else {
            [self handleUpdateDBProcess:AM_Update_Step_UploadAttachments];
        }
//    });
}

-(void)deleteAttachments
{
    NSArray *attachments = [[AMDBManager sharedInstance] getAttachmentsForDeletion];
    if (attachments.count) {
        [[AMProtocolManager sharedInstance] deleteAttachmentsOnSalesforce:attachments completion:^(NSInteger type, NSError *error, id userData, id responseData) {
            if (error) {
                _updateNetError = error;
            }
            [self handleUpdateDBProcess:AM_Update_Step_DeleteAttachments];
        }];
    } else {
        [self handleUpdateDBProcess:AM_Update_Step_DeleteAttachments];
    }
}

- (void)startCheckingFromSFDC
{
    DLog(@"will fetch data with timestamp: %@", _timeStamp);
    
    [[AMProtocolManager sharedInstance] syncDataWithTimeStamp:_timeStamp completion:^(NSInteger type, NSError * error, id userData, id responseData){
        [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
    }];
    
}

-(void)actionsAfterAddObjectStep2
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AMProtocolManager sharedInstance] uploadCreatedCasesWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
            [[AMProtocolManager sharedInstance] uploadCreatedWorkOrdersWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData)
            {
                
//                [[AMDBManager sharedInstance] updateCaseTotalInvoicePriceWithCompletion:^(NSInteger type, NSError *error) {
                //bkk sync the created contacts!
                [[AMProtocolManager sharedInstance] uploadCreatedContactsWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
                    
                    //if !error, blow away all of the added contacts
                    if (!error) {
                        
                    }
                    [self startCheckingFromSFDC];
                }];

//                }];

                [self handleUpdateDBProcess:AM_Update_Step_ADDCREATE2];
            }];
        }];
    });
}

-(void)actionsAfterUpdateFromeSalesforce
{
    [self updateLocalModifiedData];
    [self uploadAttachments];
    [self uploadNewLeads];
    [self deleteAttachments];
}

- (void)protocolHandlerWithType:(NSInteger)type retErro:(NSError *)error userData:(id)userData responseData:(id)responseData
{
    NSDictionary * userDict = (NSDictionary *)userData;
    NSDictionary * retDict = (NSDictionary *)responseData;
    NSNumber * isSuccess = [retDict objectForKey:NWRESPRESULT];
    
    if (error) {
        _hasUpdateNetError = YES;
        _updateNetError = error;
    }
    else if ([isSuccess intValue] == 0){
        _hasUpdateNetError = YES;
        NSError * localError = [[NSError alloc] initWithDomain:@"SFDC error" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"Syncing : server logic error")}];
        _updateNetError = localError;
    }

    
    switch (type) {
        case AM_REQUEST_ADDOBJECTSSTEP1:
        {
            if (!error && [isSuccess intValue]) {
                if ([retDict objectForKey:NWTIMESTAMP]) {
                    _tempTimeStamp = [retDict objectForKey:NWTIMESTAMP];
                }
                NSDictionary * mapDict = [retDict objectForKey:NWRESPDATA];

                [[AMDBManager sharedInstance] updateAddObjectsWithIdMap:mapDict completion:^(NSInteger type, NSError * error){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startUpdatingLocalAddedStep2];
                        [self handleUpdateDBProcess:AM_Update_Step_ADDCREATE];

                    });
                }];
            }
            else {
                //If failed, not preceed
                //[self updateLocalModifiedData];
                //[self uploadSignature];
                [self startUpdatingLocalAddedStep2];
                [self handleUpdateDBProcess:AM_Update_Step_ADDCREATE];
            }
        }
            break;
        case AM_REQUEST_ADDOBJECTSSTEP2:
        {
            if (!error && [isSuccess intValue]) {
                if ([retDict objectForKey:NWTIMESTAMP]) {
                    _tempTimeStamp = [retDict objectForKey:NWTIMESTAMP];
                }
                NSDictionary * mapDict = [retDict objectForKey:NWRESPDATA];
                
                [[AMDBManager sharedInstance] updateAddObjectsWithIdMap:mapDict completion:^(NSInteger type, NSError * error){
                    [self actionsAfterAddObjectStep2];
                }];
            }
            else {
                //If failed, not preceed
                //[self updateLocalModifiedData];
                //[self uploadSignature];
                [self actionsAfterAddObjectStep2];
            }
        }
            break;
        case AM_REQUEST_UPDATEOBJECTS:
        {
            [self updateReport];

            if (!error && [isSuccess intValue]) {
                if ([retDict objectForKey:NWTIMESTAMP]) {
                    _tempTimeStamp = [retDict objectForKey:NWTIMESTAMP];
                    DLog(@"timestamp after upload data to salesforce: %@", _tempTimeStamp);
                }

                [[AMDBManager sharedInstance] updateLocalModifiedObjectsToDone:userDict completion:^(NSInteger type, NSError * error){
                    [self handleUpdateDBProcess:AM_Update_Step_UpdateLocal];
                }];
            }
            else
            {
                [self handleUpdateDBProcess:AM_Update_Step_UpdateLocal];
            }
        }
            break;
        case AM_REQUEST_SYNCOBJECTS:
        {
            if (!error && [isSuccess intValue]) {
                if ([retDict objectForKey:NWTIMESTAMP]) {
                    _tempTimeStamp = [retDict objectForKey:NWTIMESTAMP];
                    DLog(@"timestamp after download data from salesforce: %@", _tempTimeStamp);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleSyncingResul:[retDict objectForKey:NWRESPDATA] completion:^(NSInteger type, NSError *error) {
                        [self actionsAfterUpdateFromeSalesforce];
//                        [self handleUpdateDBProcess:AM_Update_Step_SFDCLatest];
                    }];
                });
                
            }
            else
            {
                [self actionsAfterUpdateFromeSalesforce];
                
                //If failed, not preceed
                //[self startUpdatingLocalAdded];
                [self handleUpdateDBProcess:AM_Update_Step_SFDCLatest];
            }
        }
            break;
//        case AM_REQUEST_UPLOADSIGNATURE:
//        {
//            NSArray * signList = (NSArray *)[userDict objectForKey:@"photoArray"];
//            
//            if (signList && signList.count && !error && [isSuccess intValue]) {//success
//                [self deleteLocalSignature:signList];
//            }
//            [self handleUpdateDBProcess:AM_Update_Step_UploadSignature];
//        }
//            break;
        case AM_REQUEST_SETASSETPOS:
        {
            /*
            if (!error) {

            }
            else
            {
                
            }
            [self startCheckingFromSFDC];*/
        }
            break;
        default:
            break;
    }
}

#pragma mark - Methods
+ (AMSyncingManager *)sharedInstance
{
    static AMSyncingManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMSyncingManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkReachabilityChanged:) name:SFNetworkOperationReachabilityChangedNotification object:nil];
    
    SFNetworkEngine *engine = [SFNetworkEngine sharedInstance];
    _netStatus = [engine isReachable];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 * Start Syncing
 */
- (void)startSyncing:(AMDBOperationCompletionBlock)syncCompletionHandler
{
    if (_isUpdating) {
        if (syncCompletionHandler) {
            NSError *error = [NSError errorWithDomain:@"Sync" code:0 userInfo:@{NSLocalizedDescriptionKey: kAM_MESSAGE_SYNC_IN_PROCESS}];
            syncCompletionHandler(AM_REQUEST_SYNCOBJECTS,error);
//            _isUpdating = NO;
        }
        return;
    }
    
    DLog(@"access token: %@", [AMUtilities getToken]);
    
    [self activeAutoSyncing:nil];
    
    DLog(@"post notification to start sync");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SYNCING_START object:nil];
    
    if (syncCompletionHandler) {
        self.updateComplteHandler = syncCompletionHandler;
    }
    _updateSteps = 0;
    _isUpdating = YES;
    _hasUpdateNetError = NO;
    
    /*NSArray * addedAssets = [[AMDBManager sharedInstance] getNewAddedAsset];
    if (addedAssets && addedAssets.count) {
        [[AMProtocolManager sharedInstance] setAssetPoS:addedAssets completion:^(NSInteger type, NSError * error, id userData, id responseData){
            [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
        }];
    }
    else
    {
        [self protocolHandlerWithType:AM_REQUEST_SETASSETPOS retErro:nil userData:nil responseData:[self fakeSuccessRetDict]];
    }*/
    
    [[AMProtocolManager sharedInstance] checkReadinessForInitializationWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
        if (responseData != nil) {
            NSNumber *initCode = (NSNumber *)responseData;
            if (initCode.intValue == 1) {
                [self startUpdatingLocalAddedStep1];
            } else {
                _isUpdating = NO;
                NSError *error = [NSError errorWithDomain:@"sync" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"No Work Order are assigned at this time. Please try later.")}];
                syncCompletionHandler(AM_DBOPR_SAVE, error);
            }
        } else {
            _isUpdating = NO;
            syncCompletionHandler(AM_DBOPR_SAVE, nil);
        }

    }];
}

- (void)checkFire
{
    if (_netStatus) {
        DLog(@"start sync from automatic sync");
        [self startSyncing:self.updateComplteHandler];
    } 
}

- (void)netWorkReachabilityChanged:(NSNotification *)notif
{
    NSNumber * status = (NSNumber *)[notif object];
    BOOL inInit = [[[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULT_IN_INITIALIZATION] boolValue];
    
    if (!inInit && _netStatus == NO && [status intValue] != SFNotReachable) {
        DLog(@"start sync from network change");
        [self startSyncing:^(NSInteger type, NSError *error) {
            if (!error ||
                [error.localizedDescription rangeOfString:kAM_MESSAGE_SYNC_IN_PROCESS].location == NSNotFound) {
                [[AMLogicCore sharedInstance] syncingCompletion:error];
            }
        }];
    }
    
    _netStatus = [status boolValue];
    DLog(@"Network Reachability Changed as: %i", _netStatus);
}

- (void)activeAutoSyncing:(AMDBOperationCompletionBlock)syncCompletionHandler
{
    if (_syncCheckTimer) {
        [_syncCheckTimer invalidate];
        _syncCheckTimer = nil;
    }
    self.updateComplteHandler = syncCompletionHandler;
    
    _syncCheckTimer = [NSTimer scheduledTimerWithTimeInterval:CHECKSYNCTIMEINTERVAL target:self selector:@selector(checkFire) userInfo:nil repeats:YES];
}

- (void)cancelAutoSyncing
{
    if (_syncCheckTimer) {
        [_syncCheckTimer invalidate];
        _syncCheckTimer = nil;
    }
}

- (void)updateCurrentLongitude:(NSNumber *)longitude andLatitude:(NSNumber *)latitude
{
    if (longitude && latitude) {
        _curLatitude = latitude;
        _curLongitude = longitude;
        _positionTimestamp = [NSDate date];
    }
}

-(BOOL)isSyncing
{
    return _isUpdating;
}

@end
