//
//  AMWOTypeManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 6/7/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMWOTypeManager.h"
#import "AMProtocolManager.h"
#import "AMDBManager.h"

typedef enum AM_WOType_Step_t {
    //AM_WOType_Step_RecentWO = 0,
    AM_WOType_Step_AccountWO = 0,
    AM_WOType_Step_PoS28WO,
    AM_WOType_Step_CaseWO,
    AM_WOType_Step_AssetWO,
    AM_WOType_Step_Total
    
}AM_WOType_Step_Type;

@interface AMWOTypeManager ()
{
    NSInteger _woTypeSteps;
    BOOL _isGetting;
    BOOL _hasNetError;
    NSError * _netError;
}

@property (nonatomic, copy) AMDBOperationCompletionBlock woTypeComplteHandler;

@end

@implementation AMWOTypeManager

- (void)handleWOTypeDBProcess:(NSInteger) type
{

        _woTypeSteps ++;
        DLog(@"handleWOTypeDBProcess steps %d of total %d, cur %d", _woTypeSteps,AM_WOType_Step_Total,type);
        if (_woTypeSteps >= AM_WOType_Step_Total) {
            
            //TODO:notify user the error, and logout
            if (self.woTypeComplteHandler) {
                self.woTypeComplteHandler(AM_DBOPR_SAVEWOLIST,_netError);
            }
            _isGetting = NO;
            _hasNetError = NO;
            _netError = nil;
            _woTypeSteps = 0;
        }
}

- (void)getWOListByType:(NSArray *)woList completion:(AMDBOperationCompletionBlock)completionBlock
{
    NSMutableArray * accountList = [NSMutableArray array];
    NSMutableArray * posList = [NSMutableArray array];
    NSMutableArray * assetList = [NSMutableArray array];
    NSMutableArray * caseList = [NSMutableArray array];
    
    if (_isGetting) {
        if (completionBlock) {
            completionBlock(0,nil);
        }
        return;
    }
    
    _isGetting = YES;
    _hasNetError = NO;
    _netError = nil;
    self.woTypeComplteHandler = completionBlock;
    
    for (AMWorkOrder * wo in woList) {
        if (wo.accountID && ![accountList containsObject:wo.accountID]) {
            [accountList addObject:wo.accountID];
        }
        if (wo.posID && ![posList containsObject:wo.posID]) {
            [posList addObject:wo.posID];
        }
        if (wo.assetID && ![assetList containsObject:wo.assetID]) {
            [assetList addObject:wo.assetID];
        }
        if (wo.caseID && ![caseList containsObject:wo.caseID]) {
            [caseList addObject:wo.caseID];
        }
    }

    //dispatch_async(dispatch_get_main_queue(), ^{
        //Get WO list by Account
        [[AMProtocolManager sharedInstance] getWorkOrderListByType:AM_NWWOLIST_BYACCOUNT timeStamp:nil withIDList:accountList completion:^(NSInteger type, NSError * error, id userData, id responseData){
            [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
        }];
        //Get WO list by PoS, covered by WO list of Account
        /*[[AMProtocolManager sharedInstance] getWorkOrderListByType:AM_NWWOLIST_BYPOS timeStamp:nil withIDList:posList completion:^(NSInteger type, NSError * error, id userData, id responseData){
         [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
         }];*/
        //Get WO list by PoS28
        [[AMProtocolManager sharedInstance] getWorkOrderListByType:AM_NWWOLIST_BYPOS28 timeStamp:nil withIDList:posList completion:^(NSInteger type, NSError * error, id userData, id responseData){
            [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
        }];
        //Get WO list by Asset
        [[AMProtocolManager sharedInstance] getWorkOrderListByType:AM_NWWOLIST_BYASSET timeStamp:nil withIDList:assetList completion:^(NSInteger type, NSError * error, id userData, id responseData){
            [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
        }];
        //Get WO list by Case
        [[AMProtocolManager sharedInstance] getWorkOrderListByType:AM_NWWOLIST_BYCASE timeStamp:nil withIDList:caseList completion:^(NSInteger type, NSError * error, id userData, id responseData){
            [self protocolHandlerWithType:type retErro:error userData:userData responseData:responseData];
        }];
    //});
    
}

- (void)protocolHandlerWithType:(NSInteger)type retErro:(NSError *)error userData:(id)userData responseData:(id)responseData
{
    //NSDictionary * userDict = (NSDictionary *)userData;
    NSDictionary * retDict = (NSDictionary *)responseData;
    
    if (error) {
        _hasNetError = YES;
        _netError = error;
    }
    
    switch (type) {
        case AM_REQUEST_GETWOLST:
        {
            NSArray * woList = (NSArray *)[retDict objectForKey:NWRESPDATA];
            //AM_NWWOLIST_Type eType = [[userDict objectForKey:@"type"] intValue];
            BOOL checkExist = YES;
            
            if (woList && woList.count) {//success
                [[AMDBManager sharedInstance] saveAsyncWorkOrderList:woList checkExist:checkExist completion:^(NSInteger type, NSError * error){
                    
                    [self handleWOTypeDBProcess:AM_REQUEST_GETWOLST];
                }];
            }
            else {
                [self handleWOTypeDBProcess:AM_REQUEST_GETWOLST];
            }
        }
            break;
        default:
            break;
    }
}


@end
