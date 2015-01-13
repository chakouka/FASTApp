//
//  AMDetailTabViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/8/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AMTabType) {
    AMTabTypeUnknown = 0,
    AMTabTypeWorkOrder,
    AMTabTypeAccount,
    AMTabTypePOS,
    AMTabTypeLocation,
    AMTabTypeContacts,
    AMTabTypeAssets,
    AMTabTypeCases
};

@protocol AMDetailTabViewControllerDelegate <NSObject>

- (void)didSelectTabAtTabType:(AMTabType)tabType;

@end

@interface AMDetailTabViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *workOrderDetailBtn;
@property (weak, nonatomic) IBOutlet UIButton *accountButton;
@property (weak, nonatomic) IBOutlet UIButton *posButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIButton *assetsButton;
@property (weak, nonatomic) IBOutlet UIButton *casesButton;

@property (nonatomic) NSInteger selectedIndex;

@property (weak, nonatomic) id<AMDetailTabViewControllerDelegate> delegate;

- (void)populateCountNumber:(AMWorkOrder *)workOrder;

@end
