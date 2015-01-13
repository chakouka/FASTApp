//
//  AMProtocolManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/6/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AMConstants.h"

@interface AMProtocolManager : NSObject

+ (AMProtocolManager *)sharedInstance;

//- (NSDate *)getTZTimeByLocalTime:(NSDate *)localDate;

/**
 * get FT's own user information on Salesforce
 *
 */
- (void)getSelfUserInfo:(AMSFRestCompletionBlock)completionBlock;

- (void)getUserList:(AMSFRestCompletionBlock)completionBlock;
/**
 * get FT's own recent WO list on Salesforce
 *
 */
- (void)getOwnRecentWorkOrderList:(AMSFRestCompletionBlock)completionBlock;

- (void)getWorkOrderListByType:(AM_NWWOLIST_Type)type timeStamp:(NSDate *)timeStamp withIDList:(NSArray *)idList completion:(AMSFRestCompletionBlock)completionBlock;

- (void)getAccountsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock;
- (void)getAssetsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock;
- (void)getLocationsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock;
- (void)getInvoicesWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock;
- (void)getPoSsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock;
- (void)getPoSContactsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock;
- (void)getCasesWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock;
- (void)getPartsWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock;
- (void)getFiltersWithIDList:(NSArray *)idList timeStamp:(NSDate *)timeStamp  completion:(AMSFRestCompletionBlock)completionBlock;

- (void)downloadPhotoWithUrl:(NSString *)urlString completion:(AMSFRestCompletionBlock)completionBlock;
- (void)uploadPhotos:(NSArray *)photoArray completion:(AMSFRestCompletionBlock)completionBlock;

- (void)getInitialLoad:(AMSFRestCompletionBlock)completionBlock;

- (void)createObjectsWithData:(NSDictionary *)createObj oprationType:(NSInteger)oprType completion:(AMSFRestCompletionBlock)completionBlock;

- (void)updateObjectWithData:(NSDictionary *)createObj completion:(AMSFRestCompletionBlock)completionBlock;

- (void)syncDataWithTimeStamp:(NSDate *)timeStamp completion:(AMSFRestCompletionBlock)completionBlock;

- (void)assignSelfWO:(NSString *)woID completion:(AMSFRestCompletionBlock)completionBlock;
- (void)setAssetPoS:(NSArray *)assetList completion:(AMSFRestCompletionBlock)completionBlock;

- (void)getTestList:(AMSFRestCompletionBlock)completionBlock;
- (void)getTestPostList:(AMSFRestCompletionBlock)completionBlock;

- (void)createObjectsWithManagedObjects:(NSArray *)managedObjects operationType:(NSInteger)oprType completion:(AMSFRestCompletionBlock)completionBlock;


-(void)uploadCreatedCasesWithCompletion:(AMSFRestCompletionBlock)completionBlock;
-(void)uploadCreatedWorkOrdersWithCompletion:(AMSFRestCompletionBlock)completionBlock;

- (void)getReportDataWithCompletion:(AMSFRestCompletionBlock)completionBlock;

-(NSURL *)getAttachmentEndpoint;

-(void)downloadUnfetchedAttachments;

- (void)uploadAttachments:(NSArray *)attachments completion:(AMSFRestCompletionBlock)completionBlock;

- (void)uploadNewLeads:(NSArray *)newLeads operationType:(NSInteger)oprType completion:(AMSFRestCompletionBlock)completionBlock;

-(void)deleteAttachmentsOnSalesforce:(NSArray *)attachments completion:(AMSFRestCompletionBlock)completionBlock;

-(void)checkReadinessForInitializationWithCompletion:(AMSFRestCompletionBlock)completionBlock;

/**
 *  Near Me, search the pending Work Orders which type is PM or Filter Exchange, within the specificed radius. online required
 *
 *  @param coordinate      user current location(latitude, longitude)
 *  @param distance        radius
 *  @param completionBlock will be invoked after this request finished
 */
- (void)searchNearByWOs:(CLLocationCoordinate2D)coordinate distance:(float)radius withCompletion:(AMSFRestCompletionBlock)completionBlock;

/**
 *  Call SF Rest Service to get work order related info, like Account, POS, Case, Asset, Asset Location etc.
 *
 *  @param woIds           work order id list
 *  @param completionBlock completion block, called after this request is done
 */
- (void)getWorkOrderRequiredInfo:(NSArray *)woIds withCompletionBlock:(AMSFRestCompletionBlock)completionBlock;

@end





