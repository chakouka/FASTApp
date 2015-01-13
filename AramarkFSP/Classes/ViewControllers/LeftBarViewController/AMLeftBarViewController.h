//
//  AMLeftBarViewController.h
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LeftViewButtonType) {
    LeftViewButtonType_Sync = 0,
    LeftViewButtonType_Home,
    LeftViewButtonType_Summary,
    LeftViewButtonType_Reports,
    LeftViewButtonType_NewCase,
    LeftViewButtonType_NewLead,
    LeftViewButtonType_NearMe,
};

typedef NS_ENUM(NSInteger, SYNCType) {
    SYNCType_1 = 0,
    SYNCType_2,
    SYNCType_3,
    SYNCType_Finished,
};

@interface AMLeftBarViewController : UIViewController
{
        SYNCType syncType;
}

@property (assign, nonatomic) SYNCType syncType;

- (void)selectItemWithType:(LeftViewButtonType)aType;

- (void)startSyncCloud;
- (void)stopSyncCloud;
- (void)resetAllBtns;

- (void)userInteractionEnabled:(BOOL)enable;

@end

