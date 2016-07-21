//
//  AMConstants.h
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//


/**************SALESFORCE CONNECTED APP CONSUME KEY START*********************/
#define kSF_CONNECTED_APP_CONSUMER_KEY @"3MVG9dPGzpc3kWycUXdKas4WWw2IJbKCyi6oq29CHbQcDcmwgomA9zKO0YWfnffv_qYQNIwlx3oVaS3PHL.XK"
#define kSF_CONNECTED_APP_SUCCESS_CALLBACK @"sfdc://success"

/***************SALESFORCE CONNECTED APP CONSUME KEY END**********************/

/***************GOOGLE ANALYTICS APPLICATION SETTING START**********************/
#define kAMGOOGLE_AYALYTICS_TRACKING_ID @"UA-55666830-1"
#define kAMGOOGLE_AYALYTICS_ALLOWING_TRACKING @"AllowTracking"
/***************GOOGLE ANALYTICS APPLICATION SETTING END**********************/

#define kAMAPPLICATION_CURRENT_LANGUAGE_KEY @"KEY_OF_CURRENT_LANGUAGE"
#define kAMAPPLICATION_LANGUAGE_KEY @"application_language" //This is from Setting bundle
#define kAMAPPLICATION_LANGUAGE_ENGLISH_KEY @"English"
#define kAMAPPLICATION_LANGUAGE_FRENCH_KEY @"French"

#define kAMCommonViewsXibName @"AMCommonViews"

#define kAMBOOL_STRING_YES @"YES"
#define kAMBOOL_STRING_NO @"NO"

#define kAMPROPERTY_NAME @"propertyName"
#define kAMPROPERTY_VALUE @"propertyValue"

#define kAMWORK_ORDER_TYPE_REPAIR @"Repair"
#define kAMWORK_ORDER_TYPE_SWAP @"Swap"
#define kAMWORK_ORDER_TYPE_SITESURVEY @"Administrative"//change as Administrative, previous is SiteSurvey
#define kAMWORK_ORDER_TYPE_REMOVAL @"Removal"
#define kAMWORK_ORDER_TYPE_PM @"Preventative Maintenance"
#define kAMWORK_ORDER_TYPE_MOVE @"Move"
#define kAMWORK_ORDER_TYPE_INSTALL @"Install"
#define kAMWORK_ORDER_TYPE_EXCHANGE @"Filter Exchange"
#define kAMWORK_ORDER_TYPE_ASSETVERIFICATION @"Asset Verification"

#define KEY_OF_CURRENT_LOCATION    @"KEY_OF_CURRENT_LOCATION"


#define kAMCellIdentifierEdit @"EditCell"
#define kAMCellIdentifierCheckBox @"CheckBoxCell"
#define kAMCellIdentifierDropdown @"DropdownCell"
#define kAMCellIdentifierTextArea @"TextAreaCell"

#define kAMCellIdentifierTitleCell  @"TitleCell"

#ifndef AramarkFSP_AMConstants_h
#define AramarkFSP_AMConstants_h

#define RECORD_TYPE_OF_ACCOUNT      @"Account"
#define RECORD_TYPE_OF_ASSET        @"Asset_Verification__c"
#define RECORD_TYPE_OF_CASE         @"Case"
#define RECORD_TYPE_OF_EVENT        @"Event"
#define RECORD_TYPE_OF_INVOICE      @"Invoice__c"
#define RECORD_TYPE_OF_PRODUCT      @"Product2"
#define RECORD_TYPE_OF_SERVICE_SCHEDULE     @"Service_Schedule__c"
#define RECORD_TYPE_OF_WORK_ORDER           @"Work_Order__c"
#define RECORD_TYPE_OF_WORK_PACKAGE         @"Work_Package__c"

//Message
#define kAM_MESSAGE_SYNC_IN_PROCESS MyLocal(@"Already in syncing process")

/**
 *  Some constants of View
 */
#define SCREEN_WIDTH            ([UIScreen  mainScreen].bounds.size.width)
#define SCREEN_HEIGHT           ([UIScreen mainScreen].bounds.size.height)

#define LOGIN_BTN_WIDTH          189.0 / 2
#define LOGIN_BTN_HEIGHT         104.0 / 2

#define TITLE_WIDTH_             1861.0 / 2
#define TITLE_HEIGHT             LOGIN_BTN_WIDTH

#define LEFT_PANEL_WIDTH         LOGIN_BTN_WIDTH
#define LEFT_PANEL_HEIGH         (SCREEN_HEIGHT - LOGIN_BTN_HEIGHT)

#define MAIN_PANEL_WIDTH         TITLE_WIDTH_
#define MAIN_PANEL_HEIGH         (SCREEN_HEIGHT - TITLE_HEIGHT)

#define DEFAULT_DURATION         0.5

/**
 *  Some Defines of Function
 */

#define kMile      1609.344

//NSLog
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"[%s] [Line %d] " fmt),__FUNCTION__ ,__LINE__, ## __VA_ARGS__);
#else
#   define DLog(...)
#endif

//System Version
#define IOS_VERSION                         [[[UIDevice currentDevice] systemVersion] floatValue]
#define IOS_VERSION_8_OR_ABOVE              (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)? (YES):(NO))

#define CurrentSystemVersion                [[UIDevice currentDevice] systemVersion]

//Language
#define CurrentLanguage                     ([[NSLocale preferredLanguages] objectAtIndex:0])

//#16 -> RGB
#define UIColorFromRGB(rgbValue)            [UIColor colorWithRed : ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green : ((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue : ((float)(rgbValue & 0xFF)) / 255.0 alpha : 1.0]

#define UIColor_ON_SATE                     UIColorFromRGB(0xe9e9e9)
#define UIColor_OFF_SATE                    UIColorFromRGB(0xc5c5c5)

#define UIColor_LIGHT                       UIColorFromRGB(0xa6a6a6)

#define UIColor_BACKGROUND                  UIColorFromRGB(0xfcfcfc)
#define UIColor_RED                         UIColorFromRGB(0xcc373f)
#define UIColor_BLACK                       UIColorFromRGB(0x343c3f)

#define UIColor_LIGHT_GRAY                  UIColorFromRGB(0xeeeeee)
#define UIColor_DARK_GRAY                   UIColorFromRGB(0xd0d0d0)

#define UIColor_Global                      [UIColor colorWithRed:229.0 / 255.0 green:230.0 / 255.0 blue:225.0 / 255.0 alpha:1.0]

//Font
#define FONT(F)                             [UIFont fontWithName : @"Ropa Sans" size : F]

#define FONT_REGULAR                        FONT(30.0)
#define FONT_UPPER                          FONT(36.0)

#define AMDATE_FORMATTER_STRING_DEFAULT @"yyyy-MM-dd HH:mm"
#define AMDATE_FORMATTER_STRING_STANDARD @"yyyy-MM-dd"

//Localized
//#define MyLocal(x, ...)                     NSLocalizedString(x, nil)

//G－C－D
#define BACK(block)                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block)                         dispatch_async(dispatch_get_main_queue(), block)

//NSUserDefaults
#define USER_DEFAULT                        [NSUserDefaults standardUserDefaults]

//#define kAMLoggedUserIdKey @"kAMLoggedUserIdKey"
#define kAMLoggedUserNameKey @"kAMLoggedUserNameKey"

//AMRestRequest Blocks
// Block types
typedef void (^AMSFRestCompletionBlock) (NSInteger type, NSError *error, id userData, id responseData);

//AMRestful NetWork Operation Type
typedef enum AM_REQUEST_t {
	AM_REQUEST_GETUSERINFO = 0,
	AM_REQUEST_GETUSERLIST,
	AM_REQUEST_GETWOLST,
	AM_REQUEST_GETACCOUNTLST,
	AM_REQUEST_GETCONTACTLST,
	AM_REQUEST_GETASSETLST,
	AM_REQUEST_GETCASELST,
	AM_REQUEST_GETLOCATIONLST,
	AM_REQUEST_GETINVOICELST,
	AM_REQUEST_GETPOSLST,
	AM_REQUEST_GETPARTLST,
	AM_REQUEST_GETFILTERLST,
	AM_REQUEST_GETPHOTO,
    AM_REQUEST_GETREPORTDATA,
	AM_REQUEST_GETINITIALLOAD,
	AM_REQUEST_ADDOBJECTSSTEP1,
	AM_REQUEST_ADDOBJECTSSTEP2,
	AM_REQUEST_ADDLOCATION,
	AM_REQUEST_ADDCASE,
	AM_REQUEST_ADDWORKORDER,
	AM_REQUEST_ADDLEAD,
	AM_REQUEST_UPDATEOBJECTS,
	AM_REQUEST_SYNCOBJECTS,
	AM_REQUEST_UPLOADSIGNATURE,
	AM_REQUEST_ASSIGNSELFWO,
	AM_REQUEST_SETASSETPOS,
    AM_REQUEST_DELETE,
    AM_REQUEST_GET_INIT_CODE,
    AM_REQUEST_NEARBY,
    AM_REQUEST_WORKORDERDETAIL,
    AM_REQUEST_ADDCONTACTS,
    AM_REQUEST_DELETECONTACTS
}AM_REQUEST_Type;

typedef enum {
	AMPopoverTypeElectricOutletType,
	AMPopoverTypeElevatorOrStair
}AMPopoverType;


typedef enum {
	AMRelatedWOTypeAccount,
	AMRelatedWOTypePOS,
	AMRelatedWOTypeAsset,
	AMRelatedWOTypeCase
} AMRelatedWOType;

typedef NS_ENUM (NSInteger, WORKORDERType) {
	WORKORDERType_Repair = 0,
	WORKORDERType_Swap,
	WORKORDERType_SiteSurvey, //Administrative
	WORKORDERType_Removal,
	WORKORDERType_PM,
	WORKORDERType_Move,
	WORKORDERType_Install,
	WORKORDERType_Exchange,
	WORKORDERType_AssetVerification
};

typedef enum {
	AnimationDirectionUp = 0,
	AnimationDirectionDown,
	AnimationDirectionLeft,
	AnimationDirectionRight
}AnimationDirection;

//AMRestful NetWork WorkOrder List Operation Type
typedef enum AM_NWWOLIST_t {
	AM_NWWOLIST_RECENT = 0,
	AM_NWWOLIST_BYACCOUNT,
	AM_NWWOLIST_BYPOS,
	AM_NWWOLIST_BYPOS28,
	AM_NWWOLIST_BYASSET,
	AM_NWWOLIST_BYCASE
}AM_NWWOLIST_Type;

static const float kAMFontSizeSmall = 12.0;

static const float kAMFontSizeCommon = 15.0;

static const float kAMFontSizeBigger = 18.0;

#define NWRESPRESULT        @"result"
#define NWERRORMSG          @"erroMsg"
#define NWRESPDATA          @"data"
#define NWTIMESTAMP         @"timestamp"
#define NWHOURRATE         @"hourrate"
#define NWMARKETCENTEREMAIL @"mcemail"
#define USER_LANGUAGE       @"User_Language"

#define SIGNATUREFILEPREFIX @"AMSign"

#define USRDFTSELFUID       @"USRDFTSELFUID"
#define USRDFTHOURRATE      @"USRDFTHOURRATE"
#define USRLOGINTIMESTAMP      @"USRLOGINTIMESTAMP"
#define USRLASTSYNCTIMESTAMP      @"USRLASTSYNCTIMESTAMP"
#define USER_DEFAULT_IN_INITIALIZATION       @"USER_DEFAULT_IN_INITIALIZATION"

//AMDBManger Blocks
#define DBWorkOrderTable        @"AMDBWorkOrder"

//AMRestRequest Blocks
// Block types, if error is nil means success
typedef void (^AMDBOperationCompletionBlock) (NSInteger type, NSError *error);

//AMRestful NetWork Operation Type
typedef enum AM_DBOPR_t {
	AM_DBOPR_CLEARALL = 0,
	AM_DBOPR_SAVEWOLIST,
	AM_DBOPR_SAVEACCOUNTLIST,
	AM_DBOPR_SAVECONTACTLIST,
	AM_DBOPR_SAVEPOSLIST,
	AM_DBOPR_SAVEASSETLIST,
	AM_DBOPR_SAVECASELIST,
	AM_DBOPR_SAVELOCATIONLIST,
	AM_DBOPR_SAVEUSERLIST,
	AM_DBOPR_SAVEFILTERLIST,
	AM_DBOPR_SAVEPARTSLIST,
	AM_DBOPR_SAVEINVOICELIST,
	AM_DBOPR_SAVEEVENTLIST,
	AM_DBOPR_SAVEFILTERUSEDLIST,
	AM_DBOPR_SAVEPARTSUSEDLIST,
	AM_DBOPR_SAVEBESTPOINTLIST,
	AM_DBOPR_SAVEFILE,
	AM_DBOPR_SAVEBINITIALLOAD,
	AM_DBOPR_SAVESFDCLATEST,
	AM_DBOPR_UPDATENEWOBJECTS,
	AM_DBOPR_UPDATEMODIFIEDTODONE,
    AM_DBOPR_SAVE,
	AM_DBOPR_DEL
}AM_DBOPR_Type;

//Type for Checkout View Cell
typedef NS_ENUM (NSInteger, AMCheckoutCellType) {
	AMCheckoutCellType_Checkout_Title = 0,
	AMCheckoutCellType_Checkout_RepairCode,
	AMCheckoutCellType_Checkout_WorkOrderNotes,
	AMCheckoutCellType_Checkout_WorkPerformed,
    AMCheckoutCellType_Checkout_Maintenance,
	AMCheckoutCellType_Checkout_InvoiceCode,
	AMCheckoutCellType_Checkout_FilterName,
	AMCheckoutCellType_Checkout_Add,
	AMCheckoutCellType_Checkout_Parts,

	AMCheckoutCellType_Verification_Title,
	AMCheckoutCellType_Verification_MachineType,
	AMCheckoutCellType_Verification_Asset,
	AMCheckoutCellType_Verification_Location,
	AMCheckoutCellType_Verification_Notes,

	AMCheckoutCellType_Points_Title,
	AMCheckoutCellType_Points_Check_0,
	AMCheckoutCellType_Points_Check_1,
	AMCheckoutCellType_Points_Check_2,

	AMCheckoutCellType_Invoice_Case,
	AMCheckoutCellType_Invoice_WorkOrder_Work_Performed,
	AMCheckoutCellType_Invoice_WorkOrder_MaintenceFee,
	AMCheckoutCellType_Invoice_WorkOrder_Filter_Name,

    AMCheckoutCellType_Checkout_InvoiceCode_Title,
	AMCheckoutCellType_Checkout_Filter_Title,
	AMCheckoutCellType_Checkout_Part_Title,

    AMCheckoutCellType_Checkout_InvoiceCode_Item,
	AMCheckoutCellType_Checkout_Filter_Item,
	AMCheckoutCellType_Checkout_Part_Item,
};

//Type for Detail View and Checkout View Frame
typedef NS_ENUM (NSInteger, FrameType) {
	FrameType_Normal = 0,
	FrameType_Top,
	FrameType_Full,
};


// create Object status
typedef enum {
	EntityStatusNew = 0,
	EntityStatusCreated,
    EntityStatusModified,
    EntityStatusDeleted,
	EntityStatusSyncSuccess,
	EntityStatusSyncFail,
    EntityStatusFromSalesforce
} EntityStatus;

#endif




