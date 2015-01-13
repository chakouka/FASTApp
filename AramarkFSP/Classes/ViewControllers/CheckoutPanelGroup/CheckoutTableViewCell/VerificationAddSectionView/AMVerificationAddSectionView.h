//
//  AMVerificationAddSectionView.h
//  AramarkFSP
//
//  Created by PwC on 5/30/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMVerificationAddSectionViewDelegate;

@interface AMVerificationAddSectionView : UIView
{
    BOOL isAdd;
}

@property (assign, nonatomic) BOOL isAdd;
@property (weak, nonatomic) IBOutlet UIView *viewAdd;
@property (weak, nonatomic) IBOutlet UIView *viewCancel;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus;
@property (weak, nonatomic) id<AMVerificationAddSectionViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *labelTCancel;
@property (weak, nonatomic) IBOutlet UILabel *labelTStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTAdd;

- (void)setAdd:(BOOL)add;
- (IBAction)clickAddBtn:(UIButton *)sender;
- (IBAction)clickCancelBtn:(UIButton *)sender;

@end

@protocol AMVerificationAddSectionViewDelegate <NSObject>
- (void)verificationSectionViewDidClickAddBtn:(AMVerificationAddSectionView *)aVerificationAddSectionView;
- (void)verificationSectionViewDidClickCancelBtn:(AMVerificationAddSectionView *)aVerificationAddSectionView;
@end
