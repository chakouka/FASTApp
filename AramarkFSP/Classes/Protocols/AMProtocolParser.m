//
//  AMProtocolParser.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/6/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMProtocolParser.h"
#import "AMDBManager.h"

@interface AMProtocolParser ()
{
    NSDateFormatter * _dateTimeFormatter;
    NSDateFormatter * _dateFormatter;
    NSString * _timeZone;
}
@end

@implementation AMProtocolParser

+ (AMProtocolParser *)sharedInstance
{
    static AMProtocolParser *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMProtocolParser alloc] init];
    });
    
    return sharedInstance;
}

-(NSDate *)dateFromSalesforceDateString: (NSString *)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    NSDate *date = [formatter dateFromString:dateString];
//    NSDate *date = [self getTZTimeByGMT:dateString];
    return date;
}

-(NSString *)dateStringForSalesforceFromDate:(NSDate *)date
{
    NSString *dateString = nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    formatter.timeZone = [self timeZoneOnSalesforce];
    dateString = [formatter stringFromDate:date];
    
    return dateString;
}

-(NSTimeZone *)timeZoneOnSalesforce
{
    NSTimeZone *timeZone = nil;
    
    timeZone = [NSTimeZone timeZoneWithName:_timeZone];
    if (!timeZone) {
        timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];    // default value to avoid crash
    }
    return timeZone;
}

//- (NSDate *)getTZTimeByGMT:(NSString *)timeStamp
//{
//    NSTimeZone * tzone = [NSTimeZone timeZoneWithName:_timeZone];
//    NSDate * localDate = [_dateTimeFormatter dateFromString:timeStamp];
//    NSInteger localOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
//    NSInteger tzOffset = [tzone secondsFromGMT];
//    NSDate * tzDate = [[localDate dateByAddingTimeInterval:-localOffset] dateByAddingTimeInterval:tzOffset];
//
//    return tzDate;
//}
//
//- (NSDate *)getTZTimeByLocalTime:(NSDate *)localDate
//{
//    NSTimeZone * tzone = [NSTimeZone timeZoneWithName:_timeZone];
//    NSInteger localOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
//    NSInteger tzOffset = [tzone secondsFromGMT];
//    NSDate * tzDate = [[localDate dateByAddingTimeInterval:-localOffset] dateByAddingTimeInterval:tzOffset];
//    
//    return tzDate;
//}

- (id)init
{
    self = [super init];
    
    _dateTimeFormatter = [[NSDateFormatter alloc] init];
    [_dateTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return self;
}

- (id)objectByTransfingNullToNil:(id)object
{
    return [object isKindOfClass:[NSNull class]] ? nil : object;
}

- (id)objectByTransfingNullToNilWithDict:(NSDictionary *)dict allKeys:(NSArray *)allKeys andKey:(id)key
{
    id object = nil;
    if ([allKeys containsObject:key]) {
        object = [dict objectForKey:key];
        return [self objectByTransfingNullToNil:object];
    }
    return nil;
}

- (NSNumber *)getBoolNumberWithDict:(NSDictionary *)dict Key:(NSString *)key
{
    NSNumber * boolNumber = [NSNumber numberWithInt:0];
    
    /*if ([[dict allKeys] containsObject:key]) {
        if ([dict objectForKey:key] != [NSNull null]) {
            if ([[[dict objectForKey:key] substringToIndex:1] isEqualToString:@"Y"]) {
                boolNumber = [NSNumber numberWithInt:1];
            }
        }
    }*/
    if ([[dict allKeys] containsObject:key]) {
        if ([dict objectForKey:key] != [NSNull null]) {
            boolNumber = [NSNumber numberWithInt:[[dict objectForKey:key] intValue]];
        }
    }
    
    return boolNumber;
}

- (AMUser *)parseUserInfo:(NSDictionary *)dict
{
    NSString * username = [dict objectForKey:@"Name"];
    NSString * userid = [dict objectForKey:@"Id"];
    NSString * photoUrl = [dict objectForKey:@"SmallPhotoUrl"];
    
    AMUser * parsedUser = [[AMUser alloc] init];
    
    parsedUser.userID = userid;
    parsedUser.displayName = username;
    parsedUser.photoUrl = photoUrl;
    parsedUser.workingHourFrom = [dict valueForKeyWithNullToNil:@"Working_Hour_From__c"];
    parsedUser.workingHourTo = [dict valueForKeyWithNullToNil:@"Working_Hour_To__c"];
    parsedUser.lunchBreakFrom = [dict valueForKeyWithNullToNil:@"Lunch_Break_From__c"];
    parsedUser.lunchBreakTo = [dict valueForKeyWithNullToNil:@"Lunch_Break_To__c"];
    
    return parsedUser;
}

- (NSDictionary *)parseSelfUserInfo:(NSDictionary *)dict
{
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSDictionary * dataDict = [dict objectForKey:@"data"];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
 
    [retDict setObject:[self parseUserInfo:dataDict] forKey:NWRESPDATA];
    
    return retDict;

}

- (NSDictionary *)parseUserInfoList:(NSDictionary *)dict
{
    NSMutableArray * parsedArray = [NSMutableArray array];
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSDictionary * mainDict = [dict objectForKey:@"dataListMap"];
    NSDictionary * addDict = [mainDict objectForKey:@"Add"];
    NSArray * dataArray = [addDict objectForKey:@"User"];
    
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"hourRate"]) {
        NSString * hourRate = [self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"hourRate"];
        [retDict setObject:[NSNumber numberWithFloat:[hourRate floatValue]] forKey:NWHOURRATE];
    }
    if ([dict objectForKey:@"isSuccess"]) {
        [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"timeZone"]) {
        _timeZone = [dict objectForKey:@"timeZone"];
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"timeStamp"]) {
        NSDate * ts = [self dateFromSalesforceDateString:[dict objectForKey:@"timeStamp"]];
        
        if (ts) {
            [retDict setObject:ts forKey:NWTIMESTAMP];
        }
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"strMarketCenterEmail"]) {
        NSString *mcEmail = [self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"strMarketCenterEmail"];
        
        if (mcEmail) {
            [retDict setObject:mcEmail forKey:NWMARKETCENTEREMAIL];
        }
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"language"]) {
        NSString *userLanguage = [self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"language"];
        
        if (userLanguage) {
            [retDict setObject:userLanguage forKey:USER_LANGUAGE];
        }
    }
    for (NSDictionary * dataDict in dataArray) {
        AMUser *user = [self parseUserInfo:dataDict];
//        if ([retDict objectForKey:NWMARKETCENTEREMAIL]) {
//            user.marketCenterEmail = [retDict objectForKey:NWMARKETCENTEREMAIL];
//        }
        [parsedArray addObject:user];
    }
    [retDict setObject:parsedArray forKey:NWRESPDATA];
    
    return retDict;
}

- (AMAccount *)parseAccountInfo:(NSDictionary *)dict
{
    AMAccount * parsedAccount = [[AMAccount alloc] init];
    
    /*
     NSString * accountID;
     NSDate * atRisk;
     NSNumber * isNationalAccount;
     NSString * kam;
     NSString * nam;
     NSString * name;
     NSString * nationalAccount;
     NSString * parentAccount;
     NSString * salesConsultant;
     */
    NSArray * allKeys = [dict allKeys];
    NSDictionary * subDict = nil;
    
    parsedAccount.accountID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Id"];
    parsedAccount.atRisk = [_dateFormatter dateFromString:[dict objectForKey:@"Account_at_Risk__c"]];
    parsedAccount.isNationalAccount = [self getBoolNumberWithDict:dict Key:@"National_Account__c"];
    parsedAccount.name = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Name"];
    parsedAccount.fspSalesConsultant = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"FSP_Sales_Consultant__c"];
    parsedAccount.naNumber = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"NA_Number__c"];
    parsedAccount.keyAccount = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Key_Account__c"];
    parsedAccount.atRiskReason = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"At_Risk_Reason__c"];

    subDict = [dict objectForKey:@"Parent"];
    if (subDict) {
        parsedAccount.parentAccount = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    }
    
    //TODO: need to add these fields
    parsedAccount.nationalAccount = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"National_Account_Name__c"]; //replace NA_Number__c as National_Account_Name__c - Aaron
    parsedAccount.salesConsultant = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"salesConsultant"];
    
    return parsedAccount;
    
}

- (AMAsset *)parseAssetInfo:(NSDictionary *)dict
{
    AMAsset * parsedAsset = [[AMAsset alloc] init];
    
    /*
     NSString * assetID;
     NSDate * installDate;
     NSString * lastModifiedBy;
     NSDate * lastModifiedDate;
     NSDate * lastVerifiedDate;
     NSString * locationID;
     NSString * machineNumber;
     NSString * machineType;
     NSDate * nextPMDate;
     NSString * posID;
     NSString * serialNumber;
     NSString * vendKey;
     NSString * notes;
     NSString * userID;
     */
    NSArray * allKeys = [dict allKeys];
    NSDictionary * subDict = nil;
    
    parsedAsset.assetName = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Name"];
    parsedAsset.assetID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Id"];
    parsedAsset.serialNumber = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"SerialNumber"];
    parsedAsset.lastModifiedDate = [self dateFromSalesforceDateString:[dict objectForKey:@"LastModifiedDate"]];
    parsedAsset.locationID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Asset_Location__c"];
    parsedAsset.machineType = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Machine_Group_Name__c"];
    parsedAsset.machineNumber = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Machine_Number__c"];
    parsedAsset.posID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Service_Point__c"];
    parsedAsset.lastVerifiedDate = [_dateFormatter dateFromString:[self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Verified_Date__c"]];
    parsedAsset.installDate = [_dateFormatter dateFromString:[self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"InstallDate"]];
    parsedAsset.notes = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Notes__c"];
    
//    subDict = [dict objectForKey:@"Product2"];
//    if (subDict) {
//        parsedAsset.productID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"ID"];
//    }
    
//    parsedAsset.productID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Product2Id"];

    parsedAsset.productID = [dict valueForKeyPathWithNullToNil:@"Product2.Id"];
    parsedAsset.productName = [dict valueForKeyPathWithNullToNil:@"Product2.Name"];
    
    // 14-8-25 next PMDate path changed
//    subDict = [dict objectForKey:@"Service_Schedule__r"];
//    if (subDict) {
//        parsedAsset.nextPMDate = [_dateFormatter dateFromString:[self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Next_Scheduled_Date__c"]];
//    }
    
    NSArray *tmpArray = [dict valueForKeyPathWithNullToNil:@"Service_Schedules__r.records.Next_Scheduled_Date__c"];
    id tempDate = tmpArray.firstObject;
    if (tempDate && ![tempDate isKindOfClass:[NSNull class]]) {
        parsedAsset.nextPMDate = [_dateFormatter dateFromString:tmpArray.firstObject];
    }
    subDict = [dict objectForKey:@"Asset_Location__r"];
    if (subDict) {
        parsedAsset.locationName = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    }
    
    
    parsedAsset.vendKey = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Vend_Key__c"];
    //Updated asset number, updated asset serial number
    
    parsedAsset.verificationStatus = [dict valueForKeyPathWithNullToNil:@"Verification_Status__c"];
    parsedAsset.manufacturerWebsite = [dict valueForKeyPathWithNullToNil:@"Product2.Manufacturer_Website__c"];
    
    return parsedAsset;
}

- (AMLocation *)parseLocationInfo:(NSDictionary *)dict
{
    AMLocation * parsedLocation = [[AMLocation alloc] init];
    
    /*
     NSString * name;
     NSString * accountID;
     NSString * locationID;
     NSString * createdBy;
     NSDate * createdDate;
     NSString * lastModifiedBy;
     NSString * location;
     NSString * country;
     NSString * state;
     NSString * city;
     NSString * street;
     NSDate * lastModifiedDate;
     NSString * userID;
     NSString * addtionalNotes;
     NSNumber * badgeNeeded;
     NSNumber * cabinetHeight;
     NSNumber * dockAvailable;
     NSNumber * doorsRemoved;
     NSNumber * doorwayWidth;
     NSString * electricOutlet;
     NSNumber * electricity3ft;
     NSString * elevatorStairs;
     NSNumber * elevatorSize;
     NSNumber * freightElevator;
     NSNumber * personalProtection;
     NSNumber * electricalInPlace;
     NSNumber * visitByServiceDep;
     NSNumber * roomMeasurement;
     NSNumber * siteLevel;
     NSDate * siteSurveyDate;
     NSString * specialNotes;
     NSNumber * safetyTraining;
     NSString * typeFlooring;
     NSNumber * waterSource;
     */
    NSArray * allKeys = [dict allKeys];
    
    parsedLocation.locationID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Id"];
    parsedLocation.accountID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Account__c"];
    parsedLocation.city = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"City__c"];
    parsedLocation.country = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Country__c"];
    parsedLocation.state = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"State__c"];
    parsedLocation.street = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Street__c"];
    parsedLocation.location = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Name"];
    parsedLocation.name = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Name"];
    
    //TODO: need add theses fields
    parsedLocation.createdBy = nil;
    parsedLocation.createdDate = nil;
    parsedLocation.lastModifiedBy = nil;
    parsedLocation.lastModifiedDate = nil;
    parsedLocation.addtionalNotes = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Additional_Notes__c"];
    parsedLocation.badgeNeeded = [self getBoolNumberWithDict:dict Key:@"Badge_Needed_for_Access__c"];
    parsedLocation.cabinetHeight = [NSNumber numberWithFloat:[[dict objectForKey:@"Cabinet_Height_inches__c"] floatValue]];
    parsedLocation.dockAvailable = [self getBoolNumberWithDict:dict Key:@"Dock_Available__c"];
    parsedLocation.doorsRemoved = [self getBoolNumberWithDict:dict Key:@"Doors_to_be_Removed_for_Vending_Equip__c"];
    parsedLocation.doorwayWidth = [NSNumber numberWithFloat:[[dict objectForKey:@"Doorway_Width_inches__c"] floatValue]];
    parsedLocation.electricOutlet = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Electric_Outlet_Type__c"];
    parsedLocation.electricity3ft = [self getBoolNumberWithDict:dict Key:@"Electricity_Within_3ft__c"];
    parsedLocation.elevatorStairs = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Elevator_or_Stairs__c"];
    parsedLocation.elevatorSize = [NSNumber numberWithFloat:[[dict objectForKey:@"Elevator_Size_feet__c"] floatValue]];
    parsedLocation.freightElevator = [self getBoolNumberWithDict:dict Key:@"Freight_Elevator_Available__c"];
    parsedLocation.personalProtection = [self getBoolNumberWithDict:dict Key:@"Personal_Protection_Equipment_Required__c"];
    parsedLocation.electricalInPlace = [self getBoolNumberWithDict:dict Key:@"Required_Electrical_in_Place__c"];
    parsedLocation.visitByServiceDep = [self getBoolNumberWithDict:dict Key:@"Requires_Visit_by_Service_Department__c"];
    parsedLocation.roomMeasurement = [NSNumber numberWithFloat:[[dict objectForKey:@"Room_Measurement_for_Equipment_sq_ft__c"] floatValue]];
    parsedLocation.siteLevel = [self getBoolNumberWithDict:dict Key:@"Site_Level_and_Lighted__c"];
    parsedLocation.siteSurveyDate = [self dateFromSalesforceDateString:[dict objectForKey:@"Site_Survey_Date__c"]];
    parsedLocation.specialNotes = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Special_Instructions_Notes__c"];
    parsedLocation.safetyTraining = [self getBoolNumberWithDict:dict Key:@"Specific_Safety_Training_Required__c"];
    parsedLocation.typeFlooring = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Type_of_Flooring__c"];
    parsedLocation.waterSource = [self getBoolNumberWithDict:dict Key:@"Water_Source_within_10ft__c"];
    
    parsedLocation.dataStatus = @(EntityStatusFromSalesforce);
    
    return parsedLocation;
}

- (AMInvoice *)parseInvoiceInfo:(NSDictionary *)dict
{
    AMInvoice * parsedInvoice = [[AMInvoice alloc] init];
    
    /*
     NSString * assetID;
     NSString * createdBy;
     NSString * invoiceNumber;
     NSString * lastModifiedBy;
     NSString * posID;
     NSString * woID;
     NSString * invoiceID;
     NSString * userID;
     NSNumber * price;     */
    NSArray * allKeys = [dict allKeys];
    NSDictionary * subDict = nil;
    
    parsedInvoice.invoiceID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Id"];
    parsedInvoice.invoiceNumber = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Name"];
    parsedInvoice.woID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Work_Order__c"];
    parsedInvoice.hoursRate = [NSNumber numberWithFloat:[[dict objectForKey:@"Hours_Rate__c"] floatValue]];
    parsedInvoice.hoursWorked = [NSNumber numberWithFloat:[[dict objectForKey:@"Hours_Worked__c"] floatValue]];
//    parsedInvoice.workPerformed = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Work_Performed__c"];
    parsedInvoice.maintenanceFee = [NSNumber numberWithFloat:[[dict objectForKey:@"Maintenance_Fee__c"] floatValue]];
    parsedInvoice.quantity = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Quantity__c"];
    
    subDict = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Filters__r"];
    if (subDict) {
        parsedInvoice.filterID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Id"];
        parsedInvoice.filterName = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    }
    subDict = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Product_Part__r"];
    if (subDict) {
        parsedInvoice.filterID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Id"];
        parsedInvoice.filterName = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    }
    subDict = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"RecordType"];
    if (subDict) {
        parsedInvoice.recordTypeName = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
        parsedInvoice.recordTypeID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Id"];
    }

    parsedInvoice.price = [NSNumber numberWithFloat:[[self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Estimated_Price__c"] floatValue]];
    parsedInvoice.unitPrice = [NSNumber numberWithFloat:[[self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Filter_Price__c"] floatValue]];
    parsedInvoice.quantity = [dict valueForKeyWithNullToNil:@"Quantity__c"];
    parsedInvoice.filterID = [dict valueForKeyPathWithNullToNil:@"Filters__r.Id"];
    parsedInvoice.filterName = [dict valueForKeyPathWithNullToNil:@"Filters__r.Name"];
    parsedInvoice.invoiceCodeId = [dict valueForKeyPathWithNullToNil:@"Invoice_Code__r.Id"];
    parsedInvoice.invoiceCodeName = [dict valueForKeyPathWithNullToNil:@"Invoice_Code__r.Name"];
    parsedInvoice.posID = [dict valueForKeyPathWithNullToNil:@"Point_of_Service__r.Id"];
    parsedInvoice.posName = [dict valueForKeyPathWithNullToNil:@"Point_of_Service__r.Name"];
    parsedInvoice.caseId = [dict valueForKeyPathWithNullToNil:@"Work_Order__r.Case__c"];
    
    return parsedInvoice;
}

- (AMFilter *)parseFilterInfo:(NSDictionary *)dict
{
    AMFilter * parsedFilter = [[AMFilter alloc] init];
    /*
     NSString * posID;
     NSString * filterID;
     NSString * filterName;
     NSNumber * price;
     */
    
    NSArray * allKeys = [dict allKeys];
    NSDictionary * subDict = nil;
    
    parsedFilter.posID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Point_of_Service__c"];
    parsedFilter.price = [NSNumber numberWithFloat:[[dict objectForKey:@"Price__c"] floatValue]];
    
    subDict = [dict objectForKey:@"Product__r"];
    if (subDict) {
        parsedFilter.filterID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Id"];
        parsedFilter.filterName = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    }
    
    return parsedFilter;
}

- (AMPoS *)parsePoSInfo:(NSDictionary *)dict
{
    AMPoS * parsedPoS = [[AMPoS alloc] init];
    
    /*
     NSString * posID;
     NSString * segment;
     NSString * bdm;
     NSNumber * routeNumber;
     NSString * driverName;
     NSString * name;
     */
    NSArray * allKeys = [dict allKeys];
    NSDictionary * subDict = nil;
    
    parsedPoS.posID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Id"];
    parsedPoS.name = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Name"];
    parsedPoS.segment = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Segment__c"];
    parsedPoS.routeNumber = [NSNumber numberWithInt:[[dict objectForKey:@"Route_Number__c"] intValue]];
    parsedPoS.parkingDetail = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"FSP_Parking_Detail__c"];
    
    subDict = [dict objectForKey:@"BDM__r"];
    if (subDict) {
        parsedPoS.bdm = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    }
    
    subDict = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"KAM__r"];
    if (subDict) {
        parsedPoS.kam = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    }
    
    subDict = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"NAM__r"];
    if (subDict) {
        parsedPoS.nam = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    }

    //TODO: need add theses fields
    parsedPoS.driverName = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Driver_Name__c"];
    
    parsedPoS.meiNumber = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"MEI_Customer__c"];
    parsedPoS.naBillingType = [dict valueForKeyWithNullToNil:@"NA_Billing_Type__c"];
    parsedPoS.routeLookupID = [dict valueForKeyPathWithNullToNil:@"Route_Lookup__r.Id"];
    parsedPoS.routeLookupName = [dict valueForKeyPathWithNullToNil:@"Route_Lookup__r.Name"];

    return parsedPoS;
}

- (AMContact *)parsePoSContactInfo:(NSDictionary *)dict
{
    AMContact * parsedPoSContact = [[AMContact alloc] init];
    
    /*
     NSString * name;
     NSString * role;
     NSString * phone;
     NSString * email;
     NSString * posID;
     NSString * accountID;
     NSString * contactID;
     */
    NSArray * allKeys = [dict allKeys];
    NSDictionary * subDict = nil;
    
    subDict = [dict objectForKey:@"Contact__r"];
    if (subDict) {
        parsedPoSContact.name = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
        parsedPoSContact.accountID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"AccountId"];
        parsedPoSContact.contactID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Id"];
    }
    parsedPoSContact.phone = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Contact_Phone__c"];
    parsedPoSContact.email = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Contact_Email__c"];
    
    parsedPoSContact.posID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Service_Point__c"];
    parsedPoSContact.role = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Role__c"];
    
    parsedPoSContact.firstName = [dict valueForKeyPathWithNullToNil:@"Contact__r.FirstName"];
    parsedPoSContact.lastName = [dict valueForKeyPathWithNullToNil:@"Contact__r.LastName"];
    parsedPoSContact.title = [dict valueForKeyPathWithNullToNil:@"Contact__r.Title"];
    
    return parsedPoSContact;
}

- (AMParts *)parsePartsInfo:(NSDictionary *)dict
{
    AMParts * parsedPart = [[AMParts alloc] init];
    
    /*
     NSString * partID;
     NSString * productID;
     NSString * name;
     */
    NSArray * allKeys = [dict allKeys];
    
    parsedPart.partID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Id"];
    parsedPart.name = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Name__c"];
    parsedPart.productID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Product__c"];
    parsedPart.partDescription = [dict valueForKeyWithNullToNil:@"Part_Description__c"];
    
    return parsedPart;
}

- (AMCase *)parseCaseInfo:(NSDictionary *)dict
{
    AMCase * parsedCase = [[AMCase alloc] init];
    
    /*
     NSString * owner;
     NSString * caseNumber;
     NSString * subject;
     NSString * caseDescription;
     NSString * priority;
     NSString * status;
     NSDate * closedDate;
     NSString * closedBy;
     NSString * lastModifiedBy;
     NSDate * lastModifiedDate;
     NSString * caseID;
     NSString * accountID;
     */
    NSArray * allKeys = [dict allKeys];
    
    parsedCase.caseID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Id"];
    parsedCase.caseNumber = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"CaseNumber"];
    parsedCase.caseDescription = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Description"];
    parsedCase.priority = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Priority"];
    parsedCase.status = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Status"];
    parsedCase.lastModifiedDate = [self dateFromSalesforceDateString:[dict objectForKey:@"LastModifiedDate"]];
    parsedCase.subject = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Subject"];
    
    NSDictionary * subDict = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Owner"];
    if (subDict) {
        parsedCase.owner = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    }
    
    //TODO: need add these fields
    
    parsedCase.accountID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"accountID"];
    parsedCase.meiCustomer = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"MEI_Customer__c"];
    parsedCase.createdDate = [self dateFromSalesforceDateString:[dict valueForKeyWithNullToNil:@"CreatedDate"]];
    parsedCase.contactId = [dict valueForKeyPathWithNullToNil:@"Contact.Id"];
    parsedCase.contactName = [dict valueForKeyPathWithNullToNil:@"Contact.Name"];
    
    return parsedCase;
}

- (AMWorkOrder *)parseWorkOrderInfo:(NSDictionary *)dict
{
    AMWorkOrder * parsedWO = [[AMWorkOrder alloc] init];
    /*
     NSString * accessoriesRequired;
     NSString * assetID;
     NSNumber * callAhead;
     NSString * caseID;
     NSString * complaintCode;
     NSString * contact;
     NSString * createdBy;
     NSDate * createdDate;
     NSDate * estimatedTimeEnd;
     NSDate * estimatedTimeStart;
     NSNumber * filterCount;
     NSString * filterType;
     NSString * fromLocation;
     NSString * lastModifiedBy;
     NSDate * lastModifiedDate;
     NSNumber * latitude;
     NSNumber * longitude;
     NSString * machineType;
     NSString * notes;
     NSString * ownerID;
     NSString * parkingDetail;
     NSString * posID;
     NSDate * preferrTimeFrom;
     NSDate * preferrTimeTo;
     NSString * priority;
     NSString * repairCode;
     NSString * status;
     NSString * toLocation;
     NSString * vendKey;
     NSNumber * warranty;
     NSString * woID;
     NSString * woNumber;
     NSString * workLocation;
     NSString * woType;
     */
    NSArray * allKeys = [dict allKeys];
    NSDictionary * subDict = nil;
    NSArray * subArray = nil;
    
    parsedWO.accessoriesRequired = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Accessories_Required__c"];
    parsedWO.assetID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Asset__c"];
    parsedWO.callAhead = [self getBoolNumberWithDict:dict Key:@"Call_Ahead__c"];
    parsedWO.caseID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Case__c"];
    parsedWO.caseNumber = [dict valueForKeyPathWithNullToNil:@"Case__r.CaseNumber"];
    parsedWO.complaintCode = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Complaint_Code__c"];
    
    subDict = [dict objectForKey:@"Point_of_Service__r"];
    if (subDict) {
        parsedWO.accountID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Account__c"];
        NSDictionary * accountDict = [subDict objectForKey:@"Account__r"];
        if (accountDict) {
            parsedWO.accountName = [self objectByTransfingNullToNilWithDict:accountDict allKeys:[accountDict allKeys] andKey:@"Name"];
        }
        
        // ITEM000155 - If Account name is null, use POS name
        if(parsedWO.accountName == nil) {  //  accountName is nil
            parsedWO.accountName = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
        }
    
    
    }
    
    subDict = (NSDictionary *)[self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"CreatedBy"];
    if (subDict) {
        parsedWO.createdByName = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    }
    
    parsedWO.createdDate = [self dateFromSalesforceDateString:[dict objectForKey:@"CreatedDate"]];
    
    NSString *lastServiceDate = [dict valueForKeyPathWithNullToNil:@"Last_Service_Date__c"];
    if ([lastServiceDate length] > 0) {
        parsedWO.lastServiceDate = [_dateFormatter dateFromString:lastServiceDate];
    }
    subDict = [dict objectForKey:@"Events"];
    if (subDict) {
        subArray = [subDict objectForKey:@"records"];
        if (subArray) {
            NSMutableArray * eventList = [NSMutableArray array];
            
            for (NSDictionary * eventDict in subArray) {
                AMEvent * event = [[AMEvent alloc] init];
                
                event.eventID = [self objectByTransfingNullToNilWithDict:eventDict allKeys:[eventDict allKeys] andKey:@"Id"];
                event.ownerID = [self objectByTransfingNullToNilWithDict:eventDict allKeys:[eventDict allKeys] andKey:@"OwnerId"];
                event.woID = [self objectByTransfingNullToNilWithDict:eventDict allKeys:[eventDict allKeys] andKey:@"WhatId"];
                event.estimatedTimeStart = [self dateFromSalesforceDateString:[eventDict objectForKey:@"StartDateTime"]];
                event.estimatedTimeEnd = [self dateFromSalesforceDateString:[eventDict objectForKey:@"EndDateTime"]];
                event.actualTimeStart = [self dateFromSalesforceDateString:[eventDict objectForKey:@"Actual_Start_Time__c"]];
                event.actualTimeEnd = [self dateFromSalesforceDateString:[eventDict objectForKey:@"Actual_End_Time__c"]];
                
                [eventList addObject:event];
            }
            parsedWO.eventList = eventList;
        }
    }
    

    parsedWO.filterCount = @([[dict objectForKey:@"Total_Number_of_Filters__c"] intValue]);
    parsedWO.notes = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Work_Order_Notes__c"];
    parsedWO.caseDescription = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Description__c"];
//    parsedWO.filterType = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Filter_Type__c"];
    parsedWO.filterType = [dict valueForKeyPathWithNullToNil:@"Filter_Type__r.Id"];
    parsedWO.filterTypeName = [dict valueForKeyPathWithNullToNil:@"Filter_Type__r.Name"];
    
    parsedWO.fromLocation = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"From_location__c"];
    //parsedWO.lastModifiedBy = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"LastModifiedById"];
    parsedWO.lastModifiedDate = [self dateFromSalesforceDateString:[dict objectForKey:@"LastModifiedDate"]];
    parsedWO.latitude = [NSNumber numberWithFloat:[[dict objectForKey:@"Geolocation_Latitude__c"] floatValue]];
    parsedWO.longitude = [NSNumber numberWithFloat:[[dict objectForKey:@"Geolocation_Longitude__c"] floatValue]];
    parsedWO.age = [NSNumber numberWithInt:[[dict objectForKey:@"Timestamp__c"] intValue]];
    parsedWO.machineType = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Machine_Type__c"];
    parsedWO.parkingDetail = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Parking_Detail__c"];
    parsedWO.posID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Point_of_Service__c"];
    parsedWO.preferrTimeFrom = [self objectByTransfingNullToNil:[dict objectForKey:@"Preferred_Schedule_Time_From__c"]];
    parsedWO.preferrTimeTo = [self objectByTransfingNullToNil:[dict objectForKey:@"Preferred_Schedule_Time_To__c"]];
    parsedWO.priority = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Priority__c"];
    parsedWO.repairCode = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Repair_Code__c"];
    parsedWO.status = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Status__c"];
    parsedWO.vendKey = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Vend_Key__c"];
    parsedWO.warranty = [self getBoolNumberWithDict:dict Key:@"Under_Warranty__c"];
    parsedWO.woID = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Id"];
    parsedWO.woNumber = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Name"];
    parsedWO.workLocation = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Work_Location__c"];
    parsedWO.toWorkLocation = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"New_Location__c"];

    subDict = (NSDictionary *)[dict objectForKey:@"RecordType"];
    parsedWO.woType = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    parsedWO.recordTypeID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Id"];
    parsedWO.recordTypeName = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];

    subDict = (NSDictionary *)[dict objectForKey:@"Contact__r"];
    parsedWO.contact = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];
    parsedWO.contactID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Id"];

    subDict = (NSDictionary *)[dict objectForKey:@"Owner"];
    parsedWO.ownerID = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Id"];
    parsedWO.ownerName = [self objectByTransfingNullToNilWithDict:subDict allKeys:[subDict allKeys] andKey:@"Name"];

    parsedWO.leftInOrderlyManner = [self getBoolNumberWithDict:dict Key:@"Break_Room_Left_In_An_Orderly_Manner__c"];
    parsedWO.inspectedTubing = [self getBoolNumberWithDict:dict Key:@"Inspected_Tubing_For_Any_Potential_Leaks__c"];
    parsedWO.testedAll = [self getBoolNumberWithDict:dict Key:@"Tested_All_Equipment__c"];
    parsedWO.subject = [self objectByTransfingNullToNilWithDict:dict allKeys:allKeys andKey:@"Subject__c"];
    
//    subArray = [dict valueForKeyPathWithNullToNil:@"Attachments.records"];
//    if (subArray.count) {
//        [[AMDBManager sharedInstance] saveAsyncAttachmentArrayFromSalesforce:subArray completion:^(NSInteger type, NSError *error) {
//            if (error) {
//                DLog(@"save attachments error: %@", error.localizedDescription);
//            }
//        }];
//    }
    parsedWO.workOrderDescription = [dict valueForKeyPathWithNullToNil:@"Work_Order_Description__c"];
    parsedWO.machineTypeName = [dict valueForKeyPathWithNullToNil:@"Machine_Type__r.Name"];
    parsedWO.toLocationID = [dict valueForKeyPathWithNullToNil:@"To_Location__r.Id"];
    parsedWO.toLocationName = [dict valueForKeyPathWithNullToNil:@"To_Location__r.Name"];
    parsedWO.productName = [dict valueForKeyPathWithNullToNil:@"Product__r.Name"];
    
    NSString *estimatedWorkDateStr = [dict valueForKeyPathWithNullToNil:@"Estimated_Work_Date__c"];
    if ([estimatedWorkDateStr length] > 0) {
        parsedWO.estimatedDate = [_dateFormatter dateFromString:estimatedWorkDateStr];
    }
    
    return parsedWO;
}

-(AMEvent *)parseEventInfo:(NSDictionary *)eventDict
{
    AMEvent *parsedEvent = [[AMEvent alloc] init];
    
    parsedEvent.eventID = [self objectByTransfingNullToNilWithDict:eventDict allKeys:[eventDict allKeys] andKey:@"Id"];
    parsedEvent.ownerID = [self objectByTransfingNullToNilWithDict:eventDict allKeys:[eventDict allKeys] andKey:@"OwnerId"];
    parsedEvent.woID = [self objectByTransfingNullToNilWithDict:eventDict allKeys:[eventDict allKeys] andKey:@"WhatId"];
    parsedEvent.estimatedTimeStart = [self dateFromSalesforceDateString:[eventDict objectForKey:@"StartDateTime"]];
    parsedEvent.estimatedTimeEnd = [self dateFromSalesforceDateString:[eventDict objectForKey:@"EndDateTime"]];
    parsedEvent.actualTimeStart = [self dateFromSalesforceDateString:[eventDict objectForKey:@"Actual_Start_Time__c"]];
    parsedEvent.actualTimeEnd = [self dateFromSalesforceDateString:[eventDict objectForKey:@"Actual_End_Time__c"]];
    
    return parsedEvent;
}

- (NSDictionary *)parseWorkOrderInfoList:(NSDictionary *)dict
{
    NSMutableArray * parsedArray = [NSMutableArray array];
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSDictionary * mainDict = [dict objectForKey:@"dataListMap"];
    NSDictionary * subDict = [mainDict objectForKey:@"Add"];
    NSArray * dataArray = [subDict objectForKey:@"Work_Order__c"];
    
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"isSuccess"]) {
        [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"errorMessage"]) {
        [retDict setObject:[dict objectForKey:@"errorMessage"] forKey:NWERRORMSG];
    }

    for (NSDictionary * dataDict in dataArray) {
        [parsedArray addObject:[self parseWorkOrderInfo:dataDict]];
    }
    [retDict setObject:parsedArray forKey:NWRESPDATA];
    
    return retDict;
}

- (NSDictionary *)parseAccountList:(NSDictionary *)dict
{
    NSMutableArray * parsedArray = [NSMutableArray array];
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSArray * dataArray = [dict objectForKey:@"dataList"];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    for (NSDictionary * dataDict in dataArray) {
        [parsedArray addObject:[self parseAccountInfo:dataDict]];
    }
    [retDict setObject:parsedArray forKey:NWRESPDATA];
    
    return retDict;

}

- (NSDictionary *)parseAssetList:(NSDictionary *)dict
{
    NSMutableArray * parsedArray = [NSMutableArray array];
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSArray * dataArray = [dict objectForKey:@"dataList"];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    for (NSDictionary * dataDict in dataArray) {
        [parsedArray addObject:[self parseAssetInfo:dataDict]];
    }
    [retDict setObject:parsedArray forKey:NWRESPDATA];
    
    return retDict;
    
}

- (NSDictionary *)parseLocationList:(NSDictionary *)dict
{
    NSMutableArray * parsedArray = [NSMutableArray array];
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSArray * dataArray = [dict objectForKey:@"dataList"];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    for (NSDictionary * dataDict in dataArray) {
        [parsedArray addObject:[self parseLocationInfo:dataDict]];
    }
    [retDict setObject:parsedArray forKey:NWRESPDATA];
    
    return retDict;

}

- (NSDictionary *)parseInvoiceList:(NSDictionary *)dict
{
    NSMutableArray * parsedArray = [NSMutableArray array];
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSArray * dataArray = [dict objectForKey:@"dataList"];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    for (NSDictionary * dataDict in dataArray) {
        [parsedArray addObject:[self parseInvoiceInfo:dataDict]];
    }
    [retDict setObject:parsedArray forKey:NWRESPDATA];
    
    return retDict;

}

- (NSDictionary *)parsePoSList:(NSDictionary *)dict
{
    NSMutableArray * parsedArray = [NSMutableArray array];
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSArray * dataArray = [dict objectForKey:@"dataList"];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    for (NSDictionary * dataDict in dataArray) {
        [parsedArray addObject:[self parsePoSInfo:dataDict]];
    }
    [retDict setObject:parsedArray forKey:NWRESPDATA];
    
    return retDict;

}

- (NSDictionary *)parsePoSContactList:(NSDictionary *)dict
{
    NSMutableArray * parsedArray = [NSMutableArray array];
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSArray * dataArray = [dict objectForKey:@"dataList"];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    for (NSDictionary * dataDict in dataArray) {
        [parsedArray addObject:[self parsePoSContactInfo:dataDict]];
    }
    [retDict setObject:parsedArray forKey:NWRESPDATA];
    
    return retDict;

}

- (NSDictionary *)parsePartsList:(NSDictionary *)dict
{
    NSMutableArray * parsedArray = [NSMutableArray array];
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSArray * dataArray = [dict objectForKey:@"dataList"];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    for (NSDictionary * dataDict in dataArray) {
        [parsedArray addObject:[self parsePartsInfo:dataDict]];
    }
    [retDict setObject:parsedArray forKey:NWRESPDATA];
    
    return retDict;
}

- (NSDictionary *)parseCaseList:(NSDictionary *)dict
{
    NSMutableArray * parsedArray = [NSMutableArray array];
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSArray * dataArray = [dict objectForKey:@"dataList"];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    for (NSDictionary * dataDict in dataArray) {
        [parsedArray addObject:[self parseCaseInfo:dataDict]];
    }
    [retDict setObject:parsedArray forKey:NWRESPDATA];
    
    return retDict;
}

- (NSDictionary *)parseAssignWOToSelf:(NSDictionary *)dict
{
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"isSuccess"]) {
        [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"errorMessage"]) {
        [retDict setObject:[dict objectForKey:@"errorMessage"] forKey:NWERRORMSG];
    }

    
    return retDict;
}

- (NSDictionary *)parseUploadPhoto:(NSDictionary *)dict
{
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"isSuccess"]) {
        [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"errorMessage"]) {
        [retDict setObject:[dict objectForKey:@"errorMessage"] forKey:NWERRORMSG];
    }

    
    return retDict;
}

- (NSDictionary *)parseAssetToPoS:(NSDictionary *)dict
{
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"isSuccess"]) {
        [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"errorMessage"]) {
        [retDict setObject:[dict objectForKey:@"errorMessage"] forKey:NWERRORMSG];
    }
    
    return retDict;
}

- (NSDictionary *)parseAddEditObjects:(NSDictionary *)objSubDicts
{
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
        
    if (objSubDicts) {
        if ([objSubDicts objectForKey:@"Work_Order__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Work_Order__c"];
            NSMutableArray * parsedArray = [NSMutableArray array];
            
            for (NSDictionary * dataDict in dataArray) {
                [parsedArray addObject:[self parseWorkOrderInfo:dataDict]];
            }
            
            [dataDict setObject:parsedArray forKey:@"AMWorkOrder"];
        }
        if ([objSubDicts objectForKey:@"Event"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Event"];
            NSMutableArray * parsedArray = [NSMutableArray array];
            
            for (NSDictionary * dataDict in dataArray) {
                [parsedArray addObject:[self parseEventInfo:dataDict]];
            }
            
            [dataDict setObject:parsedArray forKey:@"AMEvent"];
        }
        if ([objSubDicts objectForKey:@"Account"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Account"];
            NSMutableArray * parsedArray = [NSMutableArray array];
            
            for (NSDictionary * dataDict in dataArray) {
                [parsedArray addObject:[self parseAccountInfo:dataDict]];
            }
            
            [dataDict setObject:parsedArray forKey:@"AMAccount"];
            
        }
        if ([objSubDicts objectForKey:@"Asset"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Asset"];
            NSMutableArray * parsedArray = [NSMutableArray array];
            
            for (NSDictionary * dataDict in dataArray) {
                [parsedArray addObject:[self parseAssetInfo:dataDict]];
            }
            
            [dataDict setObject:parsedArray forKey:@"AMAsset"];
            
        }
        if ([objSubDicts objectForKey:@"Case"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Case"];
            NSMutableArray * parsedArray = [NSMutableArray array];
            
            for (NSDictionary * dataDict in dataArray) {
                [parsedArray addObject:[self parseCaseInfo:dataDict]];
            }
            
            [dataDict setObject:parsedArray forKey:@"AMCase"];
            
        }
        if ([objSubDicts objectForKey:@"Invoice__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Invoice__c"];
            NSMutableArray * parsedArray = [NSMutableArray array];
            
            for (NSDictionary * dataDict in dataArray) {
                [parsedArray addObject:[self parseInvoiceInfo:dataDict]];
            }
            
            [dataDict setObject:parsedArray forKey:@"AMInvoice"];
            
        }
        if ([objSubDicts objectForKey:@"ServicePoint__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"ServicePoint__c"];
            NSMutableArray * parsedArray = [NSMutableArray array];
            
            for (NSDictionary * dataDict in dataArray) {
                [parsedArray addObject:[self parsePoSInfo:dataDict]];
            }
            
            [dataDict setObject:parsedArray forKey:@"AMPoS"];
            
        }
        if ([objSubDicts objectForKey:@"Product_Part__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Product_Part__c"];
            NSMutableArray * parsedArray = [NSMutableArray array];
            
            for (NSDictionary * dataDict in dataArray) {
                [parsedArray addObject:[self parsePartsInfo:dataDict]];
            }
            
            [dataDict setObject:parsedArray forKey:@"AMParts"];
            
        }
        if ([objSubDicts objectForKey:@"Customer_Price__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Customer_Price__c"];
//            NSMutableArray * parsedArray = [NSMutableArray array];
//            
//            for (NSDictionary * dataDict in dataArray) {
//                [parsedArray addObject:[self parseFilterInfo:dataDict]];
//            }
//            
//            [dataDict setObject:parsedArray forKey:@"AMFilter"];
            
            [[AMDBManager sharedInstance] saveAsyncCustomerPriceArray:dataArray completion:^(NSInteger type, NSError *error) {
                if (error) {
                    DLog(@"parse customer price error: %@", error.localizedDescription);
                }
            }];

        }
        if ([objSubDicts objectForKey:@"RecordType"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"RecordType"];
            [[AMDBManager sharedInstance] saveAsyncRecordTypeArrayFromSalesforce:dataArray completion:^(NSInteger type, NSError *error) {
                if (error) {
                    DLog(@"parse customer price error: %@", error.localizedDescription);
                }
            }];

        }
        if ([objSubDicts objectForKey:@"Asset_Location__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Asset_Location__c"];
            NSMutableArray * parsedArray = [NSMutableArray array];
            
            for (NSDictionary * dataDict in dataArray) {
                [parsedArray addObject:[self parseLocationInfo:dataDict]];
            }
            
            [dataDict setObject:parsedArray forKey:@"AMLocation"];
            
        }
        if ([objSubDicts objectForKey:@"Service_Point_Contacts__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Service_Point_Contacts__c"];
            NSMutableArray * parsedArray = [NSMutableArray array];
            
            for (NSDictionary * dataDict in dataArray) {
                [parsedArray addObject:[self parsePoSContactInfo:dataDict]];
            }
            
            [dataDict setObject:parsedArray forKey:@"AMContact"];
        }
        if ([objSubDicts objectForKey:@"Attachment"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Attachment"];
            [[AMDBManager sharedInstance] saveAsyncAttachmentArrayFromSalesforce:dataArray completion:^(NSInteger type, NSError *error) {
                if (error) {
                    DLog(@"parse attachment error: %@", error.localizedDescription);
                }
            }];
        }
    }
    return dataDict;
}

- (NSDictionary *)parseDelObjects:(NSDictionary *)objSubDicts
{
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    
    if (objSubDicts) {
        if ([objSubDicts objectForKey:@"Work_Order__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Work_Order__c"];
            
            [dataDict setObject:dataArray forKey:@"AMWorkOrder"];
        }
        if ([objSubDicts objectForKey:@"Account"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Account"];
            
            [dataDict setObject:dataArray forKey:@"AMAccount"];
            
        }
        if ([objSubDicts objectForKey:@"Asset"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Asset"];
            
            [dataDict setObject:dataArray forKey:@"AMAsset"];
            
        }
        if ([objSubDicts objectForKey:@"Case"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Case"];
            
            [dataDict setObject:dataArray forKey:@"AMCase"];
            
        }
        if ([objSubDicts objectForKey:@"Invoice__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Invoice__c"];
            
            [dataDict setObject:dataArray forKey:@"AMInvoice"];
            
        }
        if ([objSubDicts objectForKey:@"ServicePoint__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"ServicePoint__c"];
            
            [dataDict setObject:dataArray forKey:@"AMPoS"];
            
        }
        if ([objSubDicts objectForKey:@"Product_Part__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Product_Part__c"];
            
            [dataDict setObject:dataArray forKey:@"AMParts"];
            
        }
        if ([objSubDicts objectForKey:@"Asset_Location__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Asset_Location__c"];
            
            [dataDict setObject:dataArray forKey:@"AMLocation"];
            
        }
        if ([objSubDicts objectForKey:@"Event"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Event"];
            
            [dataDict setObject:dataArray forKey:@"AMEvent"];

        }
        //TODO:Filter parse
        if ([objSubDicts objectForKey:@"Filter__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Filter__c"];
            
            [dataDict setObject:dataArray forKey:@"AMFilter"];
        }
        if ([objSubDicts objectForKey:@"Service_Point_Contacts__c"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Service_Point_Contacts__c"];
            
            [dataDict setObject:dataArray forKey:@"AMContact"];
        }
        if ([objSubDicts objectForKey:@"Attachment"]) {
            NSArray * dataArray = [objSubDicts objectForKey:@"Attachment"];
            NSArray *attachmentIds = [NSArray array];
            attachmentIds = [dataArray valueForKey:@"Id"];
            [[AMDBManager sharedInstance] deleteAttachmentsByIDs:attachmentIds completion:^(NSInteger type, NSError *error) {
                if (error) {
                    DLog(@"delete local attachment error: %@", error.localizedDescription);
                }
            }];
            
        }
    }
    return dataDict;
}

/**
 * Initial Load parser
 *
 */
- (NSDictionary *)parseInitialLoad:(NSDictionary *)dict
{
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSDictionary * dataDict = nil;
    NSDictionary * objMainDicts = [self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"dataListMap"];
    
    if ([dict objectForKey:@"isSuccess"]) {
        [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"timeZone"]) {
        _timeZone = [dict objectForKey:@"timeZone"];
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"timeStamp"]) {
        NSDate * ts = [self dateFromSalesforceDateString:[dict objectForKey:@"timeStamp"]];
        
        if (ts) {
            [retDict setObject:ts forKey:NWTIMESTAMP];
        }
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"errorMessage"]) {
        [retDict setObject:[dict objectForKey:@"errorMessage"] forKey:NWERRORMSG];
    }
    
    if (objMainDicts) {
        NSDictionary * objSubDicts = [objMainDicts objectForKey:@"Add"];
        dataDict = [self parseAddEditObjects:objSubDicts];
        if (dataDict) {
            [retDict setObject:dataDict forKey:NWRESPDATA];
        }
    }
    
    // additional data for pick list
    NSDictionary *pickListDict = [dict valueForKeyWithNullToNil:@"mapSobj2Picklist"];
    if (pickListDict) {
        [[AMDBManager sharedInstance] saveAsyncPicklistDictionaryFromSalesforce:pickListDict completion:^(NSInteger type, NSError *error) {
            if (error) {
                DLog(@"%@", error.localizedDescription);
            }
        }];
    }
    
    return retDict;

}

- (NSDictionary *)parseCreateObjectList:(NSDictionary *)dict
{
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    NSDictionary * mapDict = [self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"idMap"];
    NSDictionary * locationMapArray = [mapDict objectForKey:@"Asset_Location__c"];
    NSDictionary * filterUsedMapArray = [mapDict objectForKey:@"Invoice_Filter__c"];
    NSDictionary * partsUsedMapArray = [mapDict objectForKey:@"Invoice_Part__c"];
    NSDictionary * invoiceMapArray = [mapDict objectForKey:@"Invoice__c"];
    NSDictionary * assetReqMapArray = [mapDict objectForKey:@"Asset_Verification__c"];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];

    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"timeStamp"]) {
        NSDate * ts = [self dateFromSalesforceDateString:[dict objectForKey:@"timeStamp"]];
        
        if (ts) {
            [retDict setObject:ts forKey:NWTIMESTAMP];
        }
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"errorMessage"]) {
        [retDict setObject:[dict objectForKey:@"errorMessage"] forKey:NWERRORMSG];
    }

    if (locationMapArray) {
        [dataDict setObject:locationMapArray forKey:@"AMLocation"];
    }
    if (filterUsedMapArray) {
        [dataDict setObject:filterUsedMapArray forKey:@"AMFilterUsed"];
    }
    if (partsUsedMapArray) {
        [dataDict setObject:partsUsedMapArray forKey:@"AMPartsUsed"];
    }
    if (invoiceMapArray) {
        [dataDict setObject:invoiceMapArray forKey:@"AMInvoice"];
    }
    if (assetReqMapArray) {
        [dataDict setObject:assetReqMapArray forKey:@"AMAssetRequest"];
    }
    
    [retDict setObject:dataDict forKey:NWRESPDATA];
    
    return retDict;
}

- (NSDictionary *)parseUpdateObjectList:(NSDictionary *)dict
{
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    
    [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"timeStamp"]) {
        NSDate * ts = [self dateFromSalesforceDateString:[dict objectForKey:@"timeStamp"]];
        
        if (ts) {
            [retDict setObject:ts forKey:NWTIMESTAMP];
        }
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"errorMessage"]) {
        [retDict setObject:[dict objectForKey:@"errorMessage"] forKey:NWERRORMSG];
    }
    
    return retDict;
}

- (NSDictionary *)parseSyncObjectList:(NSDictionary *)dict
{
    NSMutableDictionary * retDict = [NSMutableDictionary dictionary];
    NSDictionary * dataDict = nil;
    NSDictionary * objMainDicts = [self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"dataListMap"];
    NSMutableDictionary * objOpDicts = [NSMutableDictionary dictionary];
    NSDictionary * objSubDicts = nil;
    
    if ([dict objectForKey:@"isSuccess"]) {
        [retDict setObject:[dict objectForKey:@"isSuccess"] forKey:NWRESPRESULT];
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"timeStamp"]) {
        NSDate * ts = [self dateFromSalesforceDateString:[dict objectForKey:@"timeStamp"]];
        
        if (ts) {
            [retDict setObject:ts forKey:NWTIMESTAMP];
        }
    }
    if ([self objectByTransfingNullToNilWithDict:dict allKeys:[dict allKeys] andKey:@"errorMessage"]) {
        [retDict setObject:[dict objectForKey:@"errorMessage"] forKey:NWERRORMSG];
    }

    if (objMainDicts) {
        objSubDicts = [objMainDicts objectForKey:@"Add"];
        if (objSubDicts) {
            dataDict = [self parseAddEditObjects:objSubDicts];
            if (dataDict) {
                [objOpDicts setObject:dataDict forKey:@"Add"];
            }
        }
        objSubDicts = [objMainDicts objectForKey:@"Edit"];
        if (objSubDicts) {
            dataDict = [self parseAddEditObjects:objSubDicts];
            if (dataDict) {
                [objOpDicts setObject:dataDict forKey:@"Edit"];
            }
        }
        objSubDicts = [objMainDicts objectForKey:@"Del"];
        if (objSubDicts) {
            dataDict = [self parseDelObjects:objSubDicts];
            if (dataDict) {
                [objOpDicts setObject:dataDict forKey:@"Delete"];
            }
        }

    }
    
    [retDict setObject:objOpDicts forKey:NWRESPDATA];
    
    return retDict;
}

- (NSDictionary *)parseWorkOrderRequiredInfo:(NSDictionary *)dict
{
    NSDictionary *returnedDict = [NSMutableDictionary dictionary];
    NSDictionary *addDic = [dict valueForKeyPathWithNullToNil:@"dataListMap.Add"];
    if (addDic) {
        returnedDict = [self parseAddEditObjects:addDic];
    }
    return returnedDict;
    
}


@end
