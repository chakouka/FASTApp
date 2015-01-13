//
//  AMTitleItemViewController.h
//  AramarkFSP
//
//  Created by PwC on 4/24/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, TitleItemType) {
	TitleItemType_WorkOrder = 0,
	TitleItemType_Account,
	TitleItemType_Location,
	TitleItemType_Pos,
	TitleItemType_Contacts,
	TitleItemType_Assets,
	TitleItemType_Cases,
	TitleItem_Count,
};

@protocol AMTitleItemViewDelegate;

@interface AMTitleItemViewController : UIViewController

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) BOOL isSelected;
@property (weak, nonatomic) id <AMTitleItemViewDelegate> delegate;

- (id)initWithTag:(NSInteger)aTag Selected:(BOOL)aSelected Delegate:(id <AMTitleItemViewDelegate> )aDelegate;
- (void)clickTitleItem:(id)sender;

- (void)showFullScreen;
- (void)hiddenFullScreen;

@end

@protocol AMTitleItemViewDelegate <NSObject>
- (void)clickedTitleItem:(AMTitleItemViewController *)aTitleItem;
@end
