//
//  AMSignViewController.h
//  AramarkFSP
//
//  Created by PwC on 5/2/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMSignViewControllerDelegate;

@interface AMSignViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewSign;
@property (nonatomic, weak)id <AMSignViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *strFileName;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

- (IBAction)clickConfirmBtn:(id)sender;
- (IBAction)clickResetBtn:(id)sender;
- (IBAction)clickCancelBtn:(id)sender;
@end


@protocol AMSignViewControllerDelegate <NSObject>

- (void)AMSignViewController:(AMSignViewController *)aAMSignViewController confirmWith:(UIImage *)aSignImage;
- (void)AMSignViewController:(AMSignViewController *)aAMSignViewController resetWith:(UIImage *)aSignImage;
- (void)AMSignViewController:(AMSignViewController *)aAMSignViewController cancelWith:(UIImage *)aSignImage;

@end