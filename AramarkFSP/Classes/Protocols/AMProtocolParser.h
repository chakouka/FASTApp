//
//  AMProtocolParser.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/6/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMUser.h"
#import "AMWorkOrder.h"
#import "AMEvent.h"
#import "AMAccount.h"
#import "AMAsset.h"
#import "AMLocation.h"
#import "AMInvoice.h"
#import "AMPoS.h"
#import "AMContact.h"
#import "AMParts.h"
#import "AMCase.h"
#import "AMFilter.h"
#import "AMContact.h"

@interface AMProtocolParser : NSObject

+ (AMProtocolParser *)sharedInstance;

-(NSDate *)dateFromSalesforceDateString: (NSString *)dateString;

-(NSString *)dateStringForSalesforceFromDate:(NSDate *)date;

-(NSTimeZone *)timeZoneOnSalesforce;

//- (NSDate *)getTZTimeByLocalTime:(NSDate *)localDate;
/**
 * AMUser parser
 *
 */
- (AMUser *)parseUserInfo:(NSDictionary *)dict;

/**
 * Self User info parser
 *
 */
- (NSDictionary *)parseSelfUserInfo:(NSDictionary *)dict;

/**
 * AMUser List parser
 *
 */
- (NSDictionary *)parseUserInfoList:(NSDictionary *)dict;

/**
 * AMWorkOrder parser
 *
 */
- (AMWorkOrder *)parseWorkOrderInfo:(NSDictionary *)dict;

/**
 * AMWorkOrder List parser
 *
 */
- (NSDictionary *)parseWorkOrderInfoList:(NSDictionary *)dict;

/**
 * AMAccount List parser
 *
 */
- (NSDictionary *)parseAccountList:(NSDictionary *)dict;

/**
 * AMAsset List parser
 *
 */
- (NSDictionary *)parseAssetList:(NSDictionary *)dict;

/**
 * AMLocation List parser
 *
 */
- (NSDictionary *)parseLocationList:(NSDictionary *)dict;

/**
 * AMInvoice List parser
 *
 */
- (NSDictionary *)parseInvoiceList:(NSDictionary *)dict;

/**
 * AMPoS List parser
 *
 */
- (NSDictionary *)parsePoSList:(NSDictionary *)dict;

/**
 * AMPoSContact List parser
 *
 */
- (NSDictionary *)parsePoSContactList:(NSDictionary *)dict;

/**
 * AMParts List parser
 *
 */
- (NSDictionary *)parsePartsList:(NSDictionary *)dict;

/**
 * AMCase List parser
 *
 */
- (AMCase *)parseCaseInfo:(NSDictionary *)dict;
/**
 * AMContact List parser
 *
 */
- (AMContact *)parseContactInfo:(NSDictionary *)dict;

- (NSDictionary *)parseCaseList:(NSDictionary *)dict;

- (NSDictionary *)parseAssignWOToSelf:(NSDictionary *)dict;
- (NSDictionary *)parseUploadPhoto:(NSDictionary *)dict;

- (NSDictionary *)parseAssetToPoS:(NSDictionary *)dict;
/**
 * Initial Load parser
 *
 */
- (NSDictionary *)parseInitialLoad:(NSDictionary *)dict;

/**
 * create object response parser
 *
 */
- (NSDictionary *)parseCreateObjectList:(NSDictionary *)dict;

- (NSDictionary *)parseUpdateObjectList:(NSDictionary *)dict;

- (NSDictionary *)parseSyncObjectList:(NSDictionary *)dict;

- (NSDictionary *)parseWorkOrderRequiredInfo:(NSDictionary *)dict;

@end
