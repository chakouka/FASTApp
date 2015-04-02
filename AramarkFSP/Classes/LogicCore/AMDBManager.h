//
//  AMDBManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/9/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMUser.h"
#import "AMWorkOrder.h"
#import "AMConstants.h"
#import "AMAccount.h"
#import "AMPoS.h"
#import "AMCase.h"
#import "AMDBNewContact.h"
#import "AMAsset.h"
#import "AMContact.h"
#import "AMLocation.h"
#import "AMParts.h"
#import "AMFilter.h"
#import "AMInvoice.h"
#import "AMBest.h"
#import "AMAssetRequest.h"
#import "AMDBNewCase+AddOn.h"
#import "AMDBNewWorkOrder+AddOn.h"
#import "AMDBCustomerPrice.h"
#import "AMEvent.h"
#import "AMDBReport+AddOn.h"
#import "AMDBRecordType+AddOn.h"
#import "AMDBAttachment+AddOn.h"
#import "AMDBNewLead+Addition.h"
#import "AMDBPicklist+Addition.h"
#import "AMDBNewContact+AddOn.h"

@interface AMDBManager : NSObject

@property (nonatomic, strong) NSString * selfId;
@property (nonatomic, strong) NSDate * timeStamp;

+ (AMDBManager *)sharedInstance;

- (void)clearAllData:(AMDBOperationCompletionBlock)completionBlock;
- (NSArray *)getTodayWorkOrder;
- (NSArray *)getTodayWorkOrderIncludeClosed;
- (NSArray *)getSelfOwnedWorkOrderInPastDays:(int)numberOfDays;
- (NSArray *)getSelfWorkOrderListInPastDaysIncludeToday:(int)numberOfPastDays;
- (NSArray *)getSelfWorkOrderListInFutureDaysExcludeToday:(int)numberOfFutureDays;

- (NSArray *)getAccountPendingWorkOrderList:(NSString *)accountID;
- (NSArray *)getPoSPendingWorkOrderList:(NSString *)posID;
- (NSArray *)getCaseWorkOrderList:(NSString *)caseID;
- (NSArray *)getCaseOpenWorkOrderList:(NSString *)caseID;
- (NSArray *)getOpenFilterExchangeWorkOrdersByCaseId:(NSString *)caseID;
- (NSArray *)getAssetPast6MonthsRepairWorkOrderList:(NSString *)assetID;
- (NSNumber *)getPoSPast28DaysRepairWorkOrderNumber:(NSString *)posID;
- (AMWorkOrder *)getWorkOrderByWOID:(NSString *)woID;
- (void)saveAsyncWorkOrderList:(NSArray *)woList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncInitialSyncLoadList:(NSDictionary *)initialLoad checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
//- (void)saveSyncWorkOrderList:(NSArray *)woList checkExist:(BOOL)check;
- (AMUser *)getUserInfoByUserID:(NSString *)userID;
- (void)updateUser:(NSString *)userID timeStamp:(NSDate *)timeStamp;
- (void)saveAsyncUserList:(NSArray *)userList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (NSArray *)getEventListByWOID:(NSString *)woID;
- (void)saveAsyncEventList:(NSArray *)eventList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncAccountList:(NSArray *)accountList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncContactList:(NSArray *)contactList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncPoSList:(NSArray *)posList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncAssetList:(NSArray *)assetList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncCaseList:(NSArray *)caseList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncLocationList:(NSArray *)locationList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncFilterList:(NSArray *)filterList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncPartsList:(NSArray *)partsList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncInvoiceList:(NSArray *)invoiceList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncAssetRequestList:(NSArray *)assetReqList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncFilterUsedList:(NSArray *)filterList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncPartsUsedList:(NSArray *)partsList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)saveAsyncBestList:(NSArray *)bestList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock;


- (AMAccount *)getAccountInfoByID:(NSString *)accountID;
- (AMPoS *)getPoSInfoByID:(NSString *)posID;
- (AMCase *)getCaseInfoByID:(NSString *)caseID;
- (AMAsset *)getAssetInfoByID:(NSString *)assetID;
- (AMContact *)getContactInfoByID:(NSString *)contactID;
- (AMLocation *)getLocationInfoByID:(NSString *)locationID;
- (AMParts *)getPartsInfoByID:(NSString *)partsID;
- (AMFilter *)getFilterInfoByID:(NSString *)filterID;
- (NSArray *)getInvoiceListByWOID:(NSString *)invoiceID;
- (AMBest *)getBestPointByWOID:(NSString *)woID;
-(AMDBCustomerPrice *)getMaintainanceFeeByWOID:(NSString *)woID;
-(AMEvent *)getSelfEventByWOID:(NSString *)woID;

- (NSArray *)getLocationListByAccountID:(NSString *)accountID;
- (NSArray *)getContactListByPoSID:(NSString *)posID;
//- (NSArray *)getFilterListByPoSID:(NSString *)posID;
-(NSArray *)getFilterListByWOID:(NSString *)woID;
-(NSArray *)getInvoiceCodeListByWOID:(NSString *)woID;

- (NSArray *)getPartsListByProductID:(NSString *)productID;
- (NSArray *)getInvoiceListByWOIDList:(NSArray *)woIDList;
- (NSArray *)getAssetListByPoSID:(NSString *)posID;
- (NSArray *)getAssetRequestListByPoSID:(NSString *)posID;

- (NSArray *)getFilterUsedListByInvoiceID:(NSString *)invoiceID;
- (NSArray *)getPartsUsedListByInvoiceID:(NSString *)invoiceID;
- (NSArray *)getBestListByWOID:(NSString *)woID;
-(NSArray *)getAllReportData;

- (NSArray *)getCreatedLocation;
- (NSArray *)getCreatedEvent;
- (NSArray *)getCreatedFilterUsed;
- (NSArray *)getCreatedPartsUsed;
- (NSArray *)getCreatedInvoices;
- (NSArray *)getCreatedAssetRequests;
- (NSArray *)getCreatedWorkOrders;
- (NSArray *)getCreatedCases;
- (NSArray *)getCreatedCasesHistoryInRecentDays:(int)numberOfDays;
- (NSArray *)getCreatedWorkOrderHistory;
- (NSArray *)getCreatedContacts;


- (NSArray *)getNewAddedAsset;
- (void)updateAddLocationWithIdMap:(NSDictionary *)idMap completion:(AMDBOperationCompletionBlock)completionBlock;
- (void)updateAddObjectsWithIdMap:(NSDictionary *)idMap completion:(AMDBOperationCompletionBlock)completionBlock;

- (NSArray *)getModifiedWorkOrder;
- (NSArray *)getModifiedAsset;
- (NSArray *)getModifiedInvoice;
- (NSArray *)getModifiedCase;
- (NSArray *)getDeletedContacts;
- (NSArray *)getModifiedContacts;
- (NSArray *)getModifiedLocation;
- (NSArray *)getModifiedPoS;
- (void)updateLocalModifiedObjectsToDone:(NSDictionary *)modifiedObjects completion:(AMDBOperationCompletionBlock)completionBlock;

- (void)deleteLocalObjects:(NSDictionary *)delteIDs completion:(AMDBOperationCompletionBlock)completionBlock;


#pragma mark - Fetch
-(AMDBNewCase *)getNewCaseByFakeID:(NSString *)fakeID;
-(AMDBNewWorkOrder *)getNewWorkOrderByFakeID:(NSString *)fakeID;
-(AMDBReport *)getReportByDate:(NSDate *)date;
-(AMDBReport *)getReportByDate:(NSDate *)date andRecordType:(NSString *)recordType;

- (NSArray *)getInvoiceListByCaseID:(NSString *)caseID;


#pragma mark - Creation

-(AMDBNewCase *)createNewCaseInDB;


-(void)createNewCaseInDBWithSetupBlock:(void(^)(AMDBNewCase *newCase))setupBlock
                            completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)createNewWorkOrderInDBWithSetupBlock:(void(^)(AMDBNewWorkOrder *newWorkOrder))setupBlock
                                 completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)createNewWorkOrderInDBWithAMWorkOrder:(AMWorkOrder *)workOrder
                        additionalSetupBlock:(void(^)(AMDBNewWorkOrder *newWorkOrder))setupBlock
                                  completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)createNewContactInDBWithSetupBlock:(void(^)(AMDBNewContact *newContact))setupBlock
                            completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)saveAsyncCustomerPriceArray:(NSArray *)array completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)saveAsyncReportDictionaryFromSalesforce:(NSDictionary *)dictionary completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)saveAsyncRecordTypeArrayFromSalesforce:(NSArray *)array completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)saveAsyncAttachmentArrayFromSalesforce:(NSArray *)array completion:(AMDBOperationCompletionBlock)completionBlock;

-(AMDBAttachment *)getAttachmentById:(NSString *)id;

-(NSArray *)getUnfetchedAttachments;

-(NSArray *)getAttachmentsByWOID:(NSString *)woID;
-(NSArray *)getLocalAttachmentsByWOID:(NSString *)woID;
-(NSArray *)getRemoteAttachmentsByWOID:(NSString *)woID;



-(void)saveManagedObject:(NSManagedObject *)object completion:(AMDBOperationCompletionBlock)completionBlock;

#pragma mark - Record Type
-(NSString *)getRecordTypeNameById:(NSString *)id forObject:(NSString *)object;
-(NSString *)getRecordTypeIdByName:(NSString *)name forObject:(NSString *)object;
-(NSArray *)getRecordTypeListForObjectType:(NSString *)objectType;

-(void)createNewAttachmentInDBWithSetupBlock:(void(^)(AMDBAttachment *newAttachment))block
                                  completion:(AMDBOperationCompletionBlock)completionBlock;

-(NSArray *)getAttachmentsForUpload;

-(AMDBCustomerPrice *)getCustomerPriceByID:(NSString *)customerPriceID;

-(AMDBRecordType *)getRecordTypeByID:(NSString *)recordTypeID;

-(void)updateAttachmentWithID:(NSString *)attachmentID
                   setupBlock:(void(^)(AMDBAttachment *attachment))setupBlock
                   completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)deleteDBObject:(id)object completion:(AMDBOperationCompletionBlock)completionBlock;

- (void)deleteContactById:(NSString *)contactId completion:(AMDBOperationCompletionBlock)completionBlock;

- (void)deleteInvoiceById:(NSString *)invoiceId completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)createNewLeadInDBWithSetupBlock:(void(^)(AMDBNewLead *newLead))block
                            completion:(AMDBOperationCompletionBlock)completionBlock;
- (NSArray *)getCreatedLeadsForUpload;
- (NSArray *)getCreatedLeadsHistoryInRecentDays:(int)numberOfDays;


- (void)deleteAttachment:(AMDBAttachment *)attachment completion:(AMDBOperationCompletionBlock)completionBlock;
- (NSArray *)getAllPendingWorkOrderList;

-(AMDBReport *)createNewReportInDB;
- (void)markDeleteAttachment:(AMDBAttachment *)attachment completion:(AMDBOperationCompletionBlock)completionBlock;
-(NSArray *)getAttachmentsForDeletion;
- (NSArray *)getTodayCheckInWorkOrders;
- (NSArray *)getInvoiceListByWOID:(NSString *)woID recordTypeName:(NSString *)recordTypeName;
-(void)deleteAttachmentsByIDs:(NSArray *)ids completion:(AMDBOperationCompletionBlock)completionBlock;

-(void)moveWorkOrderToToday:(AMWorkOrder *)workOrder completion:(AMDBOperationCompletionBlock)completionBlock;

-(NSArray *)getSelfCreatedAttachmentsByWOID:(NSString *)woID;
-(NSArray *)getOtherCreatedAttachmentsByWOID:(NSString *)woID;

- (NSArray *)getWorkOrderListAfterTodayBegin;

-(void)updateCaseTotalInvoicePriceWithCompletion:(AMDBOperationCompletionBlock)completionBlock;

-(AMDBPicklist *)getPicklistWithObjectName:(NSString *)objName
                                 fieldName:(NSString *)fieldName
                                fieldValue:(NSString *)fieldValue;

-(void)saveAsyncPicklistDictionaryFromSalesforce:(NSDictionary *)dictionary completion:(AMDBOperationCompletionBlock)completionBlock;

-(NSArray *)getPicklistOfComplaintCodeInWorkOrder;
- (NSArray *)getSelfInvolvedWorkOrderInPastDays:(int)numberOfDays;
- (NSArray *)getAllEventList;
- (NSArray *)getEventListAfterTodayBegin;
-(void)updateCaseTotalInvoicePriceByCaseID:(NSString *)caseID
                            withCompletion:(AMDBOperationCompletionBlock)completionBlock;

- (NSArray *)getAllInvoiceList;
- (NSArray *)getAllAccountList;
- (NSArray *)getAllAssetList;
- (NSArray *)getAllAttachmentList;
- (NSArray *)getAllCaseList;
- (NSArray *)getAllContactList;
- (NSArray *)getAllCustomerPriceList;
- (NSArray *)getAllLocationList;
- (NSArray *)getAllPartsList;
- (NSArray *)getAllPoSList;
- (NSArray *)getAllExceptPendingWorkOrderList;
- (NSArray *)getAllWorkOrderList;
- (NSArray *)getSelfOwnedTodayCheckInWorkOrders;

@end









