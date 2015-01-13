//
//  AMVerificationSectionView.h
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMAsset;
@protocol AMVerificationSectionViewDelegate;

@interface AMVerificationSectionView : UIView

@property (strong, nonatomic) NSString *strFlag;;
@property (assign, nonatomic) NSInteger section;
@property (weak, nonatomic) IBOutlet UIView *viewBottomLineGreen;
@property (weak, nonatomic) IBOutlet UIView *viewBottomLineRed;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelStatusTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imageDrop;
@property (weak, nonatomic) IBOutlet UIButton *btnDrop;
@property (weak, nonatomic) id <AMVerificationSectionViewDelegate> delegate;

- (IBAction)clickStatusBtn:(id)sender;
- (IBAction)clickDropBtn:(id)sender;

//- (void)refreshData:(AMAsset *)aInfo;
- (void)setVerified:(BOOL)aVerified;
- (void)setDrop:(BOOL)aDrop;

@end

@protocol AMVerificationSectionViewDelegate <NSObject>
- (void)verificationSectionViewDidClickDropBtn:(AMVerificationSectionView *)aVerificationSectionView;
@optional
- (void)AMVerificationSectionViewDidClickStatusBtn:(AMVerificationSectionView *)aVerificationSectionView;
@end
