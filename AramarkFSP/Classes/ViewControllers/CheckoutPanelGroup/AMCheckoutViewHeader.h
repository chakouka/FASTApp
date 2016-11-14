//
//  AMCheckoutViewHeader.h
//  AramarkFSP
//
//  Created by PwC on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#ifndef AramarkFSP_AMCheckoutViewHeader_h
#define AramarkFSP_AMCheckoutViewHeader_h

#define COLOR_GREEN         [UIColor colorWithRed:58.0 / 255 green:200.0 / 255 blue:9.0 / 255 alpha:1]
#define COLOR_DEEP_GREEN    [UIColor colorWithRed:0.0 / 255 green:166.0 / 255 blue:81.0 / 255 alpha:1]
#define COLOR_RED           [UIColor colorWithRed:224.0 / 255 green:53.0 / 255 blue:53.0 / 255 alpha:1]
#define COLOR_BLUE          [UIColor colorWithRed:21.0 / 255 green:125.0 / 255 blue:250.0 / 255 alpha:1]
#define COLOR_GRAY          [UIColor colorWithRed:184.0 / 255 green:184.0 / 255 blue:184.0 / 255 alpha:1]

#define KEY_OF_REPAIR_CODE              @"REPAIR_CODE"

#define KEY_OF_WORKORDER_NOTES          @"WORKORDER_NOTES"
#define KEY_OF_WORKORDER_TOTAL_PRICE    @"WORKORDER_TOTAL_PRICE"
#define KEY_OF_WORKORDER_TITLE          @"WORKORDER_TITLE"
#define KEY_OF_WORKORDER_ID             @"KEY_OF_WORKORDER_ID"
#define KEY_OF_WORKORDER_END_TIME       @"KEY_OF_WORKORDER_END_TIME"

#define KEY_OF_HOURS_WORKED             @"HOURS_WORKED"
#define KEY_OF_HOURS_RATE               @"HOURS_RATE"
#define KEY_OF_WORK_PERFORMED           @"WORK_PERFORMED"
#define KEY_OF_INVOICE_DATA             @"KEY_OF_INVOICE_DATA"

#define KEY_OF_MAINTENANCE_FEE          @"MAINTENANCE_FEE"
#define KEY_OF_MAINTENANCE_TYPE         @"MAINTENANCE_TYPE"

#define KEY_OF_CELL_TYPE                @"TYPE"
#define KEY_OF_CELL_DATA                @"DATA"

#define KEY_OF_FILTER_INFO              @"FILTER_INFO"
#define KEY_OF_FILTER_QUANTITY          @"FILTER_QUANTITY"
#define KEY_OF_FILTER_PRICE             @"FILTER_PRICE"
#define KEY_OF_FILTER_NAME              @"FILTER_NAME"

#define KEY_OF_PART_INFO                @"PART_INFO"
#define KEY_OF_PART_QUANTITY            @"PART_QUANTITY"

#define KEY_OF_ADD_HEAD_TITLE           @"TITLE"
#define KEY_OF_ADD_HEAD_INFO            @"ADD_INFO"

#define KEY_OF_ASSET_INFO               @"ASSET_INFO"
#define KEY_OF_ASSETREQUEST_INFO        @"ASSETREQUEST_INFO"

#define KEY_OF_NEEDSHOW                 @"NEEDSHOW"
#define KEY_OF_SELECT                   @"SELECT"
#define KEY_OF_INFOTYPE                 @"INFOTYPE"
#define KEY_OF_ADD_ASSETREQUEST_INFO    @"ADDINFO"
#define KEY_OF_UPDATE                   @"UPDATE"
#define KEY_OF_INITIAL_DATE             @"INITIAL_DATE"
#define KEY_OF_EDITABLE                 @"KEY_OF_EDITABLE"
#define KEY_OF_LOCATION                   @"KEY_OF_LOCATION"
#define KEY_OF_MOVE_TO_WAREHOUSE          @"MOVE_TO_WAREHOUSE"

#define KEY_OF_CHECK_STATUS             @"CHECK_STATUS"
#define KEY_OF_QUESTION                 @"QUESTION"

#define KEY_OF_CASE                     @"CASE"
#define KEY_OF_CASE_DATE                @"CASE_DATE"
#define KEY_OF_COMPLETED_BY             @"COMPLETED_BY"
#define KEY_OF_REQUEST_BY               @"REQUESTEDBY"

#define TEXT_OF_NONE                    @"None"
#define TEXT_OF_NULL_PREFIX             @"_ _ _"
#define TEXT_OF_NULL                    @"_ _ _ _"

#define TEXT_OF_VERIFED                 @"Verified"
#define TEXT_OF_MISSING                 @"Missing"
#define TEXT_OF_NOTWORKING              @"Not Working"
#define TEXT_OF_WRONG_MACHINE_TYPE      @"Wrong Machine Type"
#define TEXT_OF_WRONG_SERIAL_NUMBER     @"Wrong Serial Number"
#define TEXT_OF_WRONG_ASSET_NUMBER      @"Wrong Asset Number"
#define TEXT_OF_MOVE_TO_WAREHOUSE       @"Move to Warehouse"
#define TEXT_OF_NEED_TO_VERIFY          @"Need to Verify"

#define TEXT_OF_ADD_NEW_LOCATION        MyLocal(@"+ New Location")
#define TEXT_OF_WRITE_NOTE              MyLocal(@"Write note")

#define TEXT_OF_DEFAULT_SIGNIMAGE_NAME  @"DefalutTestID"

//For New Lead Page
#define KEY_OF_LEAD_FIRSTNAME_PR            @"KEY_OF_LEAD_FIRSTNAME_PR"
#define KEY_OF_LEAD_FIRSTNAME               @"KEY_OF_LEAD_FIRSTNAME"
#define KEY_OF_LEAD_LASTNAME                @"KEY_OF_LEAD_LASTNAME"
#define KEY_OF_LEAD_COMPANYNAME             @"KEY_OF_LEAD_COMPANYNAME"
#define KEY_OF_LEAD_COMPANYSIZE             @"KEY_OF_LEAD_COMPANYSIZE"
#define KEY_OF_LEAD_TITLE                   @"KEY_OF_LEAD_TITLE"
#define KEY_OF_LEAD_CURRENTPROVIDER         @"KEY_OF_LEAD_CURRENTPROVIDER"
#define KEY_OF_LEAD_EMAILADDRESS            @"KEY_OF_LEAD_EMAILADDRESS"
#define KEY_OF_LEAD_REFERINGEMPLOYEE        @"KEY_OF_LEAD_REFERINGEMPLOYEE"
#define KEY_OF_LEAD_PHONENUMBER             @"KEY_OF_LEAD_PHONENUMBER"

#define KEY_OF_LEAD_STREET                  @"KEY_OF_LEAD_STREET"
#define KEY_OF_LEAD_ZIPCODE                 @"KEY_OF_LEAD_ZIPCODE"
#define KEY_OF_LEAD_CITY                    @"KEY_OF_LEAD_CITY"
#define KEY_OF_LEAD_STATE                   @"KEY_OF_LEAD_STATE"
#define KEY_OF_LEAD_COUNTRY                 @"KEY_OF_LEAD_COUNTRY"
#define KEY_OF_LEAD_STATEPROVINCE           @"KEY_OF_LEAD_STATEPROVINCE"
#define KEY_OF_LEAD_COMMENTS                @"KEY_OF_LEAD_COMMENTS"

#define KEY_OF_LEAD_CHECK_STATUS            @"KEY_OF_LEAD_CHECK_STATUS"
#define KEY_OF_LEAD_CHECK_TITLE             @"KEY_OF_LEAD_CHECK_TITLE"

//For New Case Page
#define KEY_OF_CASE_RECORD_TYPE             @"KEY_OF_CASE_RECORD_TYPE"
#define KEY_OF_CASE_ASSET_NO                @"KEY_OF_ASSEET_NO"
#define KEY_OF_CASE_TYPE                    @"KEY_OF_CASE_TYPE"
#define KEY_OF_CASE_SERIAL_NO               @"KEY_OF_CASE_SERIAL_NO"
#define KEY_OF_CASE_POINT_OF_SERVICE        @"KEY_OF_CASE_POINT_OF_SERVICE"
#define KEY_OF_CASE_CONTACT_NAME            @"KEY_OF_CASE_CONTACT_NAME"
#define KEY_OF_CASE_ACCOUNT                 @"KEY_OF_CASE_ACCOUNT"
#define KEY_OF_CASE_MEI_CUSTOMER_NO         @"KEY_OF_CASE_MEI_CUSTOMER_NO"
#define KEY_OF_CASE_SUBJECT                 @"KEY_OF_CASE_SUBJECT"
#define KEY_OF_CASE_DESCRIPTION             @"KEY_OF_CASE_DESCRIPTION"
#define KEY_OF_CASE_PRIORITY                @"KEY_OF_CASE_PRIORITY"
#define KEY_OF_CASE_FIRST_NAME              @"KEY_OF_CASE_FIRST_NAME"
#define KEY_OF_CASE_EMAIL                   @"KEY_OF_CASE_EMAIL"
#define KEY_OF_CASE_LAST_NAME               @"KEY_OF_CASE_LAST_NAME"
#define KEY_OF_CASE_CHOOSE_CONTACT          @"KEY_OF_CASE_CHOOSE_CONTACT"
#define KEY_OF_CASE_CHOOSE_ASSET            @"KEY_OF_CASE_CHOOSE_ASSET"
#define KEY_OF_CASE_COMPLAINT_CODE          @"KEY_OF_CASE_COMPLAINT_CODE"

//For New Contact Page
#define KEY_OF_CONTACT_FIRST_NAME              @"KEY_OF_CONTACT_FIRST_NAME"
#define KEY_OF_CONTACT_EMAIL                   @"KEY_OF_CONTACT_EMAIL"
#define KEY_OF_CONTACT_LAST_NAME               @"KEY_OF_CONTACT_LAST_NAME"
#define KEY_OF_CONTACT_TITLE                   @"KEY_OF_CONTACT_TITLE"
#define KEY_OF_CONTACT_PHONE                  @"KEY_OF_CONTACT_PHONE"
#define KEY_OF_CONTACT_CHOOSE_CONTACT          @"KEY_OF_CONTACT_CHOOSE_CONTACT"
#define KEY_OF_CONTACT_ROLE                     @"KEY_OF_CONTACT_ROLE"

#define KEY_OF_CUSTOMER_PRICE   @"KEY_OF_CUSTOMER_PRICE"


#endif
