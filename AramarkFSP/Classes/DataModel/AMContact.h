//
//  AMContact.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/4/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMContact : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * role;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * posID;
@property (nonatomic, strong) NSString * accountID;
@property (nonatomic, strong) NSString * contactID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * title;

@end
