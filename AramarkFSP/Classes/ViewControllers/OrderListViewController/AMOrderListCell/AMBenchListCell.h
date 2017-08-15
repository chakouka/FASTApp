//
//  AMBenchListCell.h
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBenchListCell : UITableViewCell
{
    
}

@property (strong, nonatomic) NSString *strPriority;
@property (weak, nonatomic) IBOutlet UILabel *label_AssetNumberTitle;
@property (weak, nonatomic) IBOutlet UILabel *label_AssetNumber;
@property (weak, nonatomic) IBOutlet UILabel *label_SerialNumberTitle;
@property (weak, nonatomic) IBOutlet UILabel *label_SerialNumber;
@property (weak, nonatomic) IBOutlet UILabel *label_MachineTypeTitle;
@property (weak, nonatomic) IBOutlet UILabel *label_MachineType;
@property (weak, nonatomic) IBOutlet UILabel *label_MachineGroupTitle;
@property (weak, nonatomic) IBOutlet UILabel *label_MachineGroup;


@property (weak, nonatomic) IBOutlet UIView *viewShade;
@property (weak, nonatomic) IBOutlet UIView *viewRight;


- (void)showShadeStatus:(BOOL)isShow;

@end
