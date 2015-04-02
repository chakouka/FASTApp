//
//  AMLogicCore.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/5/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AMWorkOrder.h"
#import "AMAccount.h"
#import "AMContact.h"
#import "AMCase.h"
#import "AMAsset.h"
#import "AMInvoice.h"
#import "AMPoS.h"
#import "AMLocation.h"
#import "AMUser.h"
#import "AMFileCache.h"
#import "AMBest.h"
#import "AMEvent.h"
#import "AMPartsUsed.h"
#import "AMFilterUsed.h"
#import "AMAssetRequest.h"
#import "AMConstants.h"
#import "AMDBCustomerPrice.h"
#import "AMDBManager.h"
#import "AMDBNewContact.h"

@interface AMLogicCore : NSObject

@property (strong, nonatomic) NSString *selfUId;
@property (strong, nonatomic) AMUser *selfUser;

+ (AMLogicCore *)sharedInstance;

/**
 * Start Initial
 */
- (void)startInitialization:(AMDBOperationCompletionBlock)initCompletionHandler;

/**
 * Start Syncing
 *
 * @return
 */
- (void)startSyncing;

/**
 * Logout
 *
 * @return
 */
- (void)logOut:(AMDBOperationCompletionBlock)completionBlock;

/**
 * NetWork Reachability
 *
 * @return YES = reachable, NO = not reachable
 */
- (BOOL)isNetWorkReachable;

/**
 * Get name of current FT
 *
 * @return              name of current FT
 */
- (AMUser *)getSelfUserInfo;

/**
 * Get photo data by url or ID
 *
 * @return              NSData of photo
 */
- (NSData *)getPhotoDataByName:(NSString *)photoName;

/**
 * Save photo data by url or ID
 *
 * @param signatureData     data of signature image
 * @param woID              work order ID
 * @param completionBlock   
 *
 * @return              void
 */
- (void)saveSignatureData:(NSData *)signatureData byCaseID:(NSString *)caseID completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * Get today's work order list of current FT
 *
 * @return              work order list, each element is AMWorkOrder object
 */
- (NSArray *)getTodayWorkOrderList;

/**
 * Get Event List by WOID
 *
 * @return              event list, each element is AMEvent object
 */
- (NSArray *)getEventListByWOID:(NSString *)woID;

-(AMEvent *)getSelfEventByWOID:(NSString *)woID;

/**
 * Get recent day's work order list of current FT
 *
 * @param
 *
 * @return              work order list, grouped by day,each element is a list contains AMWorkOrder
 */
- (NSArray *)getSummaryWorkOrderList;

- (NSArray *)getSummaryWorkOrderListInPastDaysIncludeToday:(int)numberOfPastDays;

- (NSArray *)getSummaryWorkOrderListInFutureDaysExcludeToday:(int)numberOfFutureDays;

/**
 * Get all pending work order list of account
 *
 * @param   accountID     accountID
 *
 * @return              work order list, each element is AMWorkOrder object
 */
- (NSArray *)getAccountPendingWorkOrderList:(NSString *)accountID;

/**
 * Get all pending work order list of PoS
 *
 * @param    posID      PoS ID
 *
 * @return              work order list, each element is AMWorkOrder object
 */
- (NSArray *)getPoSPendingWorkOrderList:(NSString *)posID;

/**
 * Get all work order list of Case
 *
 * @param    caseID       Case ID
 *
 * @return              work order list, each element is AMWorkOrder object
 */
- (NSArray *)getCaseWorkOrderList:(NSString *)caseID;

/**
 *  Get Work Order status not equals 'Closed' by caseId
 *
 *  @param caseID caseID
 *
 *  @return   work order list, each element is AMWorkOrder object
 */
- (NSArray *)getCaseOpenWorkOrderList:(NSString *)caseID;

/**
 *  Get work order list that status are not equals 'Closed' and type is Filter Exchange
 *
 *  @param caseID caseId
 *
 *  @return work order list, each element is AMWorkOrder object
 */
- (NSArray *)getOpenFilterExchangeWorkOrdersByCaseId:(NSString *)caseID;


/**
 * Get past 6 months' repair work order list of Asset
 *
 * @param    assetID       Asset ID
 *
 * @return              work order list, each element is AMWorkOrder object
 */
- (NSArray *)getAssetPast6MonthsRepairWorkOrderList:(NSString *)assetID;

/**
 * Get past 28 days' repair work order number of PoS
 *
 * @param    posID       PoS ID
 *
 * @return              work order list, each element is AMWorkOrder object
 */
- (NSNumber *)getPoSPast28DaysRepairWorkOrderNumber:(NSString *)posID;

/**
 * Get Invoice detail by WorkOrder ID
 *
 * @param  woID            WorkOrder ID
 *
 * @return              AMInvoice object
 */
- (NSArray *)getInvoiceListByWOID:(NSString *)woID;

/**
 * Get Work Order object by Work Order ID
 *
 * @param woID          work order ID
 *
 * @return              AMWorkOrder object
 */
- (AMWorkOrder *)getWorkOrderInfoByID:(NSString *)woID;

/**
 * Get Work Order object and related objects by Work Order ID
 *
 * @param woID          work order ID
 *
 * @return              AMWorkOrder object with other related objects
 */
- (AMWorkOrder *)getFullWorkOrderInfoByID:(NSString *)woID;

/**
 * Get Account object by Account ID
 *
 * @param accountID          Account ID
 *
 * @return                   AMAccount object
 */
- (AMAccount *)getAccountInfoByID:(NSString *)accountID;

/**
 * Get PoS object by PoS ID
 *
 * @param posID          PoS ID
 *
 * @return               AMPoS object
 */
- (AMPoS *)getPoSInfoByID:(NSString *)posID;

/**
 * Get Case object by Case ID
 *
 * @param caseID          Case ID
 *
 * @return               AMCase object
 */
- (AMCase *)getCaseInfoByID:(NSString *)caseID;

/**
 * Get Asset object by Asset ID
 *
 * @param assetID          Asset ID
 *
 * @return               AMAsset object
 */
- (AMAsset *)getAssetInfoByID:(NSString *)assetID;

/**
 * Get location list by Account ID
 *
 * @param accountID          Account ID
 *
 * @return               location list, each element is AMLocation object
 */
- (NSArray *)getLocationListByAccountID:(NSString *)accountID;

/**
 * Get location info by Account ID
 *
 * @param accountID          Location ID
 *
 * @return               AMLocation object
 */
- (AMLocation *)getLocationByID:(NSString *)locationID;

/**
 * Get contact list by PoS ID
 *
 * @param posID          PoS ID
 *
 * @return               contact list, each element is AMContact object
 */
- (NSArray *)getContactListByPoSID:(NSString *)posID;

/**
 * Get filter list by PoS ID
 *
 * @param accountID          PoS ID
 *
 * @return               filter list, each element is AMFilter object
 */
//- (NSArray *)getFilterListByPoSID:(NSString *)posID;

/**
 * Get parts list by Product ID
 *
 * @param productID          Product ID
 *
 * @return               parts list, each element is AMParts object
 */
- (NSArray *)getPartsListByProductID:(NSString *)productID;

/**
 * Get Invoice list by WO ID list
 *
 * @param woIDList          work order ID list
 *
 * @return               invoice list, each element is AMInvoice object
 */
- (NSArray *)getInvoicesListByWOIDList:(NSArray *)woIDList;

/**
 * Get Invoice list of case by WO
 *
 * @param woID          work order
 *
 * @return               invoice list, each element is AMInvoice object
 */
- (NSArray *)getCaseInvoicesListByWO:(AMWorkOrder *)wo;

/**
 * Get Asset list by PoS ID and accountID
 *
 * @param posID          PoS ID
 * @param accountID          Account ID
 *
 * @return               asset list, each element is AMAsset object
 */
- (NSArray *)getAssetListByPoSID:(NSString *)posID AccountID:(NSString *)accountID;

- (NSArray *)getAssetRequestListByPoSID:(NSString *)posID;

/**
 * Work Order check in
 *
 * @param wo          WorkOrder
 *
 * @return              result
 */
- (void)checkInWorkOrder:(AMWorkOrder *)wo completionBlock:(AMDBOperationCompletionBlock)completionBlock;


- (void)cancelCheckInWorkOrder:(AMWorkOrder *)wo completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * Work Order check out
 *
 * @param wo          WorkOrder
 *
 * @return              result
 */
//- (BOOL)checkOutWorkOrder:(AMWorkOrder *)wo;

/**
 * get current checking workorder
 *
 *
 * @return              workorder
 */
//- (AMWorkOrder *)getCheckingWorkOrder;

/**
 * complete check out status
 *
 *
 * @return              workorder
 */
- (void)finishCheckOutWorkOrder:(AMWorkOrder *)wo completion:(AMDBOperationCompletionBlock)completionBlock;

/**
 * Work Order update
 *
 * @param workorder     AMWorkOrder
 *
 * @return              void
 */
- (void)updateWorkOrder:(AMWorkOrder *)workorder completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * Case update
 *
 * @param amCase     AMCase
 *
 * @return              void
 */
- (void)updateCase:(AMCase *)amCase completionBlock:(AMDBOperationCompletionBlock)completionBlock;

- (void)updateEvent:(AMEvent *)event completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * Work Order update
 *
 * @param workorder     AMWorkOrder
 *
 * @return              void
 */
- (void)assignWorkOrderToSelf:(AMWorkOrder *)workorder completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * PoS update
 *
 * @param pos     AMPoS
 *
 * @return              void
 */
- (void)updatePoS:(AMPoS *)pos completionBlock:(AMDBOperationCompletionBlock)completionBlock;


/**
 * Add Location, need assign account ID before add operation
 *
 * @param
 *
 * @return                   void
 */
- (void)addLocation:(AMLocation *)location completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * Update Location
 *
 * @param
 *
 * @return                   void
 */
- (void)updateLocation:(AMLocation *)location completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * update Asset
 *
 * @param asset             Asset object need to update
 *
 * @return                   void
 */
- (void)updateAsset:(AMAsset *)asset completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * update Asset list
 *
 * @param assetList             each item is AMAsset
 *
 * @return                   void
 */
- (void)updateAssetList:(NSArray *)assetList completionBlock:(AMDBOperationCompletionBlock)completionBlock;

//TODO: work order check out related interface

/**
 * update AMContact
 *
 * @param contact            Contact object need to update
 *
 * @return                   void
 */
- (void)updateContact:(AMContact *)contact shouldDelete:(BOOL)shouldDelete completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * update AMInvoice
 *
 * @param invoice            Invoice object need to update
 *
 * @return                   void
 */
- (void)updateInvoice:(AMInvoice *)invoice completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * save Invoice list, each Invoice object should have asset ID, woID, caseID
 *
 * @param invoiceList            each element is invoice object
 *
 * @return                   void
 */
- (void)saveInvoiceList:(NSArray *)invoiceList completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * save AssetRequest list, each AssetRequest object should have asset ID
 *
 * @param assetReqList            each element is AssetRequest object
 *
 * @return                   void
 */
- (void)saveAssetRequestList:(NSArray *)assetReqList completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * save Filter used when workorder check out
 *
 * @param totalFilters       Each item is AMFilterUsed
 *
 * @return                   void
 */
- (void)saveFiltersUsed:(NSArray *)totalFilters completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * get Filter used list of invoice
 *
 * @param woID       invoice ID
 *
 * @return                   list, each item is AMFilterUsed
 */
- (NSArray *)getFiltersUsedByInvoiceID:(NSString *)invoiceID;

/**
 * save Parts used when workorder check out
 *
 * @param totalParts       Each item is AMPartsUsed
 *
 * @return                   void
 */
- (void)savePartsUsed:(NSArray *)totalParts completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * get Parts used list of invoice
 *
 * @param woID       invoice ID
 *
 * @return                   list, each item is AMPartsUsed
 */
- (NSArray *)getPartsUsedListByInvoiceID:(NSString *)invoiceID;

/**
 * save best Points when workorder check out
 *
 * @param   bestPoint     Object of AMBest
 *
 * @return                   void
 */
//- (void)saveBestPoints:(AMBest *)bestPoint completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 * get best Points by WO ID
 *
 * @param   woID     AMWorkOrder ID
 *
 * @return                   void
 */
//- (AMBest *)getBestPointsByWOID:(NSString *)woID;

/**
 * get FT's own hour rates
 *
 *
 * @return                   float number
 */
- (NSNumber *)getOwnHourRates;

/**
 * if need to show signature page
 *
 *
 * @return                   bool
 */
- (BOOL)shouldShowSignaturePage:(AMWorkOrder *)wo;

/**
 * get server time by loca time
 *
 *
 * @return                   server time with time zone
 */
//- (NSDate *)getCurrentServerTime;

/**
 * update geo location of current user
 *
 * @param   longitude     float NSNumber
 * @param   latitude     float NSNumber
 *
 * @return
 */
- (void)updateUserLocationWithLongitude:(NSNumber *)longitude andLatitude:(NSNumber *)latitude;


#pragma mark - Creation
-(AMDBNewCase *)createNewCaseInDB;

-(void)createNewCaseInDBWithSetupBlock:(void(^)(AMDBNewCase *newCase))setupBlock
                            completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)createNewWorkOrderInDBWithAMWorkOrder:(AMWorkOrder *)workOrder
                        additionalSetupBlock:(void(^)(AMDBNewWorkOrder *newAttachment))setupBlock
                                  completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)createNewContactInDBWithSetupBlock:(void(^)(AMDBNewContact *newContact))setupBlock
                            completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)uploadCreatedCasesWithCompletion:(AMSFRestCompletionBlock)completionBlock;
-(void)uploadCreatedWorkOrdersWithCompletion:(AMSFRestCompletionBlock)completionBlock;

-(AMDBCustomerPrice *)getMaintainanceFeeByWOID:(NSString *)woID;
-(NSArray *)getFilterListByWOID:(NSString *)woID;

- (NSArray *)getCreatedCasesHistoryByDayInRecentDays:(int)numberOfDays;

-(NSArray *)getReportDataArranged;
-(NSArray *)getReportDataRaw;

- (NSArray *)getArrangedSelfWorkOrderInPastDays:(int)numberOfDays;


#pragma mark - Record Type
-(NSString *)getRecordTypeNameById:(NSString *)id forObject:(NSString *)object;;
-(NSString *)getRecordTypeIdByName:(NSString *)name forObject:(NSString *)object;;

-(NSArray *)getAttachmentsByWOID:(NSString *)woID;

-(void)createNewAttachmentInDBWithSetupBlock:(void(^)(AMDBAttachment *newAttachment))block
                                  completion:(AMDBOperationCompletionBlock)completionBlock;

-(NSTimeZone *)timeZoneOnSalesforce;

- (NSArray *)getInvoiceListByCaseID:(NSString *)caseID;

-(void)saveManagedObject:(NSManagedObject *)object completion:(AMDBOperationCompletionBlock)completionBlock;

- (AMContact *)getContactInfoByID:(NSString *)contactID;

- (void)deleteContactById:(NSString *)contactId completion:(AMDBOperationCompletionBlock)completionBlock;

- (void)deleteInvoiceById:(NSString *)invoiceId completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)createNewLeadInDBWithSetupBlock:(void(^)(AMDBNewLead *newLead))block
                            completion:(AMDBOperationCompletionBlock)completionBlock;

- (NSArray *)getCreatedLeadsForUpload;

- (NSArray *)getCreatedLeadsHistoryByDayInRecentDays:(int)numberOfDays;

- (void)deleteAttachment:(AMDBAttachment *)attachment completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)uploadCreatedNewLeadsWithCompletion:(AMSFRestCompletionBlock)completionBlock;

-(NSArray *)getLocalAttachmentsByWOID:(NSString *)woID;
-(NSArray *)getRemoteAttachmentsByWOID:(NSString *)woID;

-(NSArray *)getRecordTypeListForObjectType:(NSString *)objectType;

- (void)resetToInitialization:(AMDBOperationCompletionBlock)initCompletionHandler;

- (NSArray *)getTodayCheckInWorkOrders;
- (NSArray *)getInvoiceListByWOID:(NSString *)woID recordTypeName:(NSString *)recordTypeName;

-(NSArray *)getInvoiceCodeListByWOID:(NSString *)woID;

-(void)moveWorkOrderToToday:(AMWorkOrder *)workOrder completion:(AMDBOperationCompletionBlock)completionBlock;

-(NSArray *)getSelfCreatedAttachmentsByWOID:(NSString *)woID;
-(NSArray *)getOtherCreatedAttachmentsByWOID:(NSString *)woID;

-(NSArray *)getPicklistOfComplaintCodeInWorkOrder;

- (void)setupOfflineData;
- (void)syncingCompletion:(NSError *)error;

/**
 *  Logic Core - Near Me, search the pending Work Orders which type is PM or Filter Exchange, within the specificed radius. online required
 *
 *  @param coordinate      user current location(latitude, longitude)
 *  @param distance        radius
 *  @param completionBlock will be invoked after this request finished
 */
-(void)searchNearByWorkOrders:(CLLocationCoordinate2D)coordinate distance:(float)radius withCompletion:(AMSFRestCompletionBlock)completionBlock;

/**
 *  Assign to myself from Near Me
 *
 *  @param woId            work order ID
 *  @param completionBlock completion block
 */
- (void)assignWorkOrderToSelfInNearMe:(NSString *)woId completionBlock:(AMDBOperationCompletionBlock)completionBlock;

/**
 *  Clean local data if network is available
 *  1. Sync Data
 *  2. Clean local data 
 *  3. Initializing data
 */
- (void)clearCache;

/**
 *  Call SF Rest Service to get work order related info, like Account, POS, Case, Asset, Asset Location etc.
 *
 *  @param woIds           work order id list
 *  @param completionBlock completion block, called after this request is done
 */
- (void)getWorkOrderRequiredInfo:(NSArray *)woIds withCompletionBlock:(AMSFRestCompletionBlock)completionBlock;

@end








