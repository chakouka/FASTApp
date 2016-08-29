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

@property (strong, nonatomic) NSString *strPriority;
@property (weak, nonatomic) IBOutlet UILabel *label_AssetNumber;
@property (weak, nonatomic) IBOutlet UILabel *label_SerialNumber;
@property (weak, nonatomic) IBOutlet UILabel *label_MachineType;
@property (weak, nonatomic) IBOutlet UIButton *btnGetAssetInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckout;


@property (weak, nonatomic) IBOutlet UIView *viewShade;
@property (weak, nonatomic) IBOutlet UIView *viewRight;


- (void)showShadeStatus:(BOOL)isShow;

@end
