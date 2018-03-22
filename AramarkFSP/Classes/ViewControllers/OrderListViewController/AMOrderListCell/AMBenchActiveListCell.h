//
//  AMBenchActiveListCell.h
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBenchActiveListCell : UITableViewCell
{
    
}
@property (assign, nonatomic) BOOL isTimerRunning;
@property (strong, nonatomic) NSString *strPriority;
@property (weak, nonatomic) IBOutlet UILabel *label_AssetNumber;
@property (weak, nonatomic) IBOutlet UILabel *label_AssetNumberTitle;

@property (weak, nonatomic) IBOutlet UILabel *label_SerialNumber;
@property (weak, nonatomic) IBOutlet UILabel *label_SerialNumberTitle;

@property (weak, nonatomic) IBOutlet UILabel *label_MachineType;
@property (weak, nonatomic) IBOutlet UILabel *label_MachineTypeTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnGetAssetInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckout;
@property (strong, nonatomic) NSDictionary *fullAssetInfoDict;
@property (strong, nonatomic) NSString *strAssetID;
@property (strong, nonatomic) NSString *strWOID; //bkk I&E 001231 20180322
@property (weak, nonatomic) IBOutlet UIView *viewShade;
@property (weak, nonatomic) IBOutlet UIView *viewRight;


- (void)showShadeStatus:(BOOL)isShow;

@end
