//
//  AMCheckoutTabViewController.h
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AMCheckoutTabType) {
    AMCheckoutTabType_Checkout = 0,
    AMCheckoutTabType_Verification,
    AMCheckoutTabType_Points,
    AMCheckoutTabType_Invoice
};

@protocol AMCheckoutTabViewControllerDelegate <NSObject>

- (void)didSelectCheckoutTabAtTabType:(AMCheckoutTabType)tabType;

@end

@interface AMCheckoutTabViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UIButton *assetsButton;
@property (weak, nonatomic) IBOutlet UIButton *pointsButton;
@property (weak, nonatomic) IBOutlet UIButton *invoiceButton;
@property (assign, nonatomic) AMCheckoutTabType checkOutSetp;
@property (nonatomic) NSInteger selectedIndex;
@property (weak, nonatomic) id<AMCheckoutTabViewControllerDelegate> delegate;

@end