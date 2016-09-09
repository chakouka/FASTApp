//
//  AMNotificationSet.h
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#ifndef AramarkFSP_AMNotificationSet_h
#define AramarkFSP_AMNotificationSet_h

/**
 *  Notification Type
 */
#define NOTIFICATION_FROM_AMMAINVIEWCONTROLLER                  @"NOTIFICATION_FROM_AMMAINVIEWCONTROLLER"
#define NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER               @"NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER"
#define NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER             @"NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER"
#define NOTIFICATION_FROM_AMBENCHLISTVIEWCONTROLLER             @"NOTIFICATION_FROM_AMBENCHLISTVIEWCONTROLLER"
#define NOTIFICATION_FROM_AMBENCHACTIVELISTVIEWCONTROLLER       @"NOTIFICATION_FROM_AMBENCHACTIVELISTVIEWCONTROLLER"
#define NOTIFICATION_FROM_AMBENCHCHECKOUTVIEWCONTROLLER       @"NOTIFICATION_FROM_AMBENCHCHECKOUTVIEWCONTROLLER"
#define NOTIFICATION_FROM_AMNEARMEORDERLISTVIEWCONTROLLER       @"NOTIFICATION_FROM_AMNEARMEORDERLISTVIEWCONTROLLER"
#define NOTIFICATION_FROM_AMDETAILPANELVIEWCONTROLLER           @"NOTIFICATION_FROM_AMDETAILPANELVIEWCONTROLLER"
#define NOTIFICATION_FROM_CHECKOUTPANELVIEWCONTROLLER           @"NOTIFICATION_FROM_CHECKOUTPANELVIEWCONTROLLER"
#define NOTIFICATION_FROM_MAPVIEW                               @"NOTIFICATION_FROM_MAPVIEW"
#define NOTIFICATION_FROM_LOGICCORE                             @"NOTIFICATION_FROM_LOGICCORE"

#define NOTIFICATION_SHOW_SUMMARY   @"Notification to Show Summary"
#define NOTIFICATION_SHOW_REPORTS   @"Notification to Show Reports"
#define NOTIFICATION_SHOW_CASE      @"Notification to Show Case"
#define NOTIFICATION_SHOW_LEAD      @"Notification to Show Lead"
#define NOTIFICATION_SHOW_NEAR      @"Notification to Show Near"
#define NOTIFICATION_SHOW_BENCH     @"Notification to Show Bench"
#define NOTIFICATION_SHOW_ACTIVEBENCH @"Notification to Show Active Bench"
#define NOTIFICATION_SHOW_ACTIVEDETAILBENCH @"Notification to Show Active Detail Bench"
#define NOTIFICATION_SHOW_BENCHCHECKOUT     @"Notification to Show Bench Checkout"
//Notification Type for Operation Online
#define NOTIFICATION_LOGIN_INITIALDATADONE              @"NOTIFICATION_LOGIN_INITIALDATADONE"
#define NOTIFICATION_LOGOUT_DONE                        @"NOTIFICATION_LOGOUT_DONE"
#define NOTIFICATION_SYNCING_START                      @"NOTIFICATION_SYNCING_START"
#define NOTIFICATION_SYNCING_DONE                       @"NOTIFICATION_SYNCING_DONE"
#define NOTIFICATION_ATTACHMENT_DOWNLOADED              @"NOTIFICATION_ATTACHMENT_DOWNLOADED"

#define NOTIFICATION_DID_SWITCH_LANGUAGE                @"NOTIFICATION_DID_SWITCH_LANGUAGE"


//Move Up Detail View if editing mode
#define NOTIFICATION_STARTING_EDITING_MODE              @"NOTIFICATION_STARTING_EDITING"

//Assign to Self Notification
#define NOTIFICATION_RELOAD_RELATED_WORKORDER_LIST      @"RELOAD_RELATED_WORKORDER_LIST"

#define NOTIFICATION_RELOAD_CASE_HISTORY_LIST   @"NOTIFICATION_RELOAD_CASE_HISTORY_LIST"
#define NOTIFICATION_RELOAD_LEAD_HISTORY_LIST   @"NOTIFICATION_RELOAD_LEAD_HISTORY_LIST"

#define NOTIFICATION_WORK_ORDER_STATUS_CHANGED  @"NOTIFICATION_WORK_ORDER_STATUS_CHANGED"
#define NOTIFICATION_WORK_ORDER_NEED_REFRESH    @"NOTIFICATION_WORK_ORDER_NEED_REFRESH"


#define KEY_OF_TYPE                                 @"KEY_OF_TYPE"
#define KEY_OF_INFO                                 @"KEY_OF_INFO"
#define KEY_OF_FLAG                                 @"KEY_OF_FLAG"

/**
 *  Type of Operations from MainViewController
 */

#define TYPE_OF_DETAILPANEL_MOVED    @"TYPE_OF_DETAILPANEL_MOVED"

/**
 *  Type of Operations from LeftViewController
 */

#define TYPE_OF_BTN_ITEM_CLICKED    @"TYPE_OF_BTN_ITEM_CLICKED"

/**
 *  Type of Operations from OrderListViewController
 */

#define TYPE_OF_CELL_SELECTED                   @"TYPE_OF_CELL_SELECTED"
#define TYPE_OF_WORK_ORDER_LIST_CHANGE          @"TYPE_OF_WORK_ORDER_LIST_CHANGE"
#define TYPE_OF_SEARCH_BAR_CHANGE               @"TYPE_OF_SEARCH_BAR_CHANGE"
#define TYPE_OF_RADIUS_SELECTED                 @"TYPE_OF_RADIUS_SELECTED"

/**
 *  Type of Operations from DetailPanelViewController
 */

#define TYPE_OF_SCREEN_FRAME        @"TYPE_OF_SCREEN_FRAME" //  YES - Show Full Screen; No - Hidden Full Screen
#define TYPE_OF_SIGNATURE           @"TYPE_OF_SIGNATURE"

/**
 *  Type of Operations from AMMainViewController
 */

#define TYPE_OF_CLICK_SCREEN        @"TYPE_OF_CLICK_SCREEN"

/**
 *  Type of Operations from MapView
 */

#define TYPE_OF_ROUTES_RESULT        @"TYPE_OF_ROUTES_RESULT" //  YES - Show Full Screen; No - Hidden Full Screen
#define TYPE_OF_ROUTES_REFRESH       @"TYPE_OF_ROUTES_REFRESH"
#define TYPE_OF_LIST_REFRESH         @"TYPE_OF_LIST_REFRESH"
#define TYPE_OF_ASSIGN_NEAR_WORKORDER   @"TYPE_OF_ASSIGN_NEAR_WORKORDER"

/**
 *  Type of Operations from Logiccore
 */
#define TYPE_OF_REFRESH_WORKORDERLIST           @"TYPE_OF_REFRESH_WORKORDERLIST"
#define TYPE_OF_SHOW_ALERT                      @"TYPE_OF_SHOW_ALERT"

#endif
