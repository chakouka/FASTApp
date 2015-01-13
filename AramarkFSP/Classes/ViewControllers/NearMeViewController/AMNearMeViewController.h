//
//  AMNearMeViewController.h
//  AramarkFSP
//
//  Created by FYH on 9/1/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface AMNearMeViewController : GAITrackedViewController
{
	BOOL show;
}

@property (assign, nonatomic) BOOL show;
@property (weak, nonatomic) IBOutlet UIView *viewMainPanel;
@property (weak, nonatomic) IBOutlet UIView *viewLeftListPanel;

- (void)refreshdata;
- (void)changeLeftListPanelHidden:(BOOL)isHidden animation:(BOOL)aAnimation;
@end
