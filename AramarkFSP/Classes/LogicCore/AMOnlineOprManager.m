//
//  AMOnlineOprManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMOnlineOprManager.h"
#import "AMProtocolManager.h"
#import "AMDBManager.h"
#import "AMSyncingManager.h"
#import "AMWOTypeManager.h"

@interface AMOnlineOprManager ()
{
    NSDate * _timeStamp;
    NSString * _selfUId;
    AMWOTypeManager * _woTypeManager;
}
@end

@implementation AMOnlineOprManager

@synthesize timeStamp = _timeStamp;
@synthesize selfUId = _selfUId;

+ (AMOnlineOprManager *)sharedInstance
{
    static AMOnlineOprManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMOnlineOprManager alloc] init];
    });
    
    return sharedInstance;

}

- (id)init
{
    self = [super init];
    
    _woTypeManager = [[AMWOTypeManager alloc] init];
    
    return self;
}

- (void)updateSingleWO:(AMWorkOrder *)wo completion:(AMDBOperationCompletionBlock)syncCompletionHandler
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSMutableArray * woList = [NSMutableArray array];
    
    if (wo) {
        [woList addObject:wo];
    }
    
    if (woList && woList.count) {
        [dict setObject:woList forKey:@"AMWorkOrder"];
    }
    
    if ([[dict allKeys] count]) {
        [[AMProtocolManager sharedInstance] updateObjectWithData:dict completion:^(NSInteger type, NSError * error, id userData, id responseData){
            
            //bkk-item 000662 Checkout Process
            //don't update the local DB to this new state.  We just want to push it to the server
            if(![wo.woType isEqualToString: @"Checked Out"])
            {
                [[AMDBManager sharedInstance] updateLocalModifiedObjectsToDone:userData completion:^(NSInteger type, NSError * error) {
                    if (syncCompletionHandler) {
                        syncCompletionHandler(type,error);
                    }
                }];
            }
        }];
    }
    else {
        if (syncCompletionHandler) {
            syncCompletionHandler(0,nil);
        }
    }

}

- (void)assignWorkOrderToSelf:(AMWorkOrder *)wo completion:(AMDBOperationCompletionBlock)syncCompletionHandler
{
    
    if (wo.woID) {
        [[AMProtocolManager sharedInstance] assignSelfWO:wo.woID completion:^(NSInteger type, NSError * error, id userData, id responseData){
            NSDictionary * retDict = (NSDictionary *)responseData;
            NSNumber * isSuccess = (NSNumber *)[retDict objectForKey:NWRESPRESULT];
            if (!error && [isSuccess intValue]) {
                NSDictionary * dataDict = (NSDictionary *)[retDict objectForKey:NWRESPDATA];
                NSArray * woList = [dataDict objectForKey:@"AMWorkOrder"];
                
                [[AMDBManager sharedInstance] saveAsyncInitialSyncLoadList:dataDict checkExist:YES completion:^(NSInteger type, NSError * error){
                    if (syncCompletionHandler) {
                        syncCompletionHandler(type,error);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{//notify ui to refresh today's wo list
                        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                        
                        [userInfo setObject:TYPE_OF_REFRESH_WORKORDERLIST forKey:KEY_OF_TYPE];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_LOGICCORE object:userInfo];
                    });
                }];
                
                [_woTypeManager getWOListByType:woList completion:^(NSInteger type, NSError * error){
                }];

            }
            else
            {
                NSError * retError = error;
                if (!retError) {
                    retError = [NSError errorWithDomain:@"salesforce" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"Assign to myself failed.")}];
                }
                if (syncCompletionHandler) {
                    syncCompletionHandler(type,retError);
                }
            }

        }];
    }
    else {
        NSError * retError = [[NSError alloc] init];
        if (syncCompletionHandler) {
            syncCompletionHandler(0,retError);
        }
    }

}

- (void)assignWorkOrderToSelfFromNearMe:(NSString *)woId completion:(AMDBOperationCompletionBlock)completionHandler
{
    
    if (woId) {
        [[AMProtocolManager sharedInstance] assignSelfWO:woId completion:^(NSInteger type, NSError * error, id userData, id responseData){
            NSDictionary * retDict = (NSDictionary *)responseData;
            NSNumber * isSuccess = (NSNumber *)[retDict objectForKey:NWRESPRESULT];
            if (!error && [isSuccess intValue]) {
                NSDictionary * dataDict = (NSDictionary *)[retDict objectForKey:NWRESPDATA];
                NSArray * woList = [dataDict objectForKey:@"AMWorkOrder"];
                
                [[AMDBManager sharedInstance] saveAsyncInitialSyncLoadList:dataDict checkExist:YES completion:^(NSInteger type, NSError * error){
                    AMWorkOrder *wo = woList.firstObject;
                    AMWorkOrder *fullWO = [[AMLogicCore sharedInstance] getFullWorkOrderInfoByID:wo.woID];
                    if (!fullWO.woAccount || !fullWO.woPoS) { //Call Rest Request to fetch work order related info, such as Account, POS, Asset, Case etc.
                        [[AMProtocolManager sharedInstance] getWorkOrderRequiredInfo:@[wo.woID] withCompletionBlock:^(NSInteger type, NSError *error, id userData, id responseData) {
                            BOOL isSuccess = ((NSNumber *)[responseData valueForKeyWithNullToNil:@"isSuccess"]).boolValue;
                            if (isSuccess) {
                                NSDictionary *dataDic = [[AMProtocolParser sharedInstance] parseWorkOrderRequiredInfo:responseData];
                                [[AMDBManager sharedInstance] saveAsyncInitialSyncLoadList:dataDic checkExist:YES completion:^(NSInteger type, NSError *error) {
                                    if (completionHandler) {
                                        completionHandler(type,error);
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{//notify ui to refresh today's wo list
                                        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                                        
                                        [userInfo setObject:TYPE_OF_REFRESH_WORKORDERLIST forKey:KEY_OF_TYPE];
                                        
                                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_LOGICCORE object:userInfo];
                                    });
                                }];
                            }
                            
                        }];
                    } else {
                        if (completionHandler) {
                            completionHandler(type,error);
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{//notify ui to refresh today's wo list
                            NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                            
                            [userInfo setObject:TYPE_OF_REFRESH_WORKORDERLIST forKey:KEY_OF_TYPE];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_LOGICCORE object:userInfo];
                        });
                    }
                    
                }];
                
                [_woTypeManager getWOListByType:woList completion:^(NSInteger type, NSError * error){
                }];
                
            } else {
                NSError * retError = error;
                if (!retError) {
                    retError = [NSError errorWithDomain:@"salesforce" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"Assign to myself failed.")}];
                }
                if (completionHandler) {
                    completionHandler(type,retError);
                }
            }
            
        }];
    }
    else {
        NSError * retError = [[NSError alloc] init];
        if (completionHandler) {
            completionHandler(0,retError);
        }
    }
    
}

@end
