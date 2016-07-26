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
@property (weak, nonatomic) IBOutlet UILabel *label_Index;
@property (weak, nonatomic) IBOutlet UILabel *label_Title;
@property (weak, nonatomic) IBOutlet UILabel *label_Type;
@property (weak, nonatomic) IBOutlet UILabel *label_Contact;
@property (weak, nonatomic) IBOutlet UILabel *label_OpenSince;
@property (weak, nonatomic) IBOutlet UILabel *label_Distance;
@property (weak, nonatomic) IBOutlet UILabel *label_Time;
@property (weak, nonatomic) IBOutlet UILabel *label_Location;
@property (weak, nonatomic) IBOutlet UILabel *label_EstimationDuration;
@property (weak, nonatomic) IBOutlet UIView *viewM;
@property (weak, nonatomic) IBOutlet UIView *viewIndex;
@property (weak, nonatomic) IBOutlet UIImageView *imageIndex;
@property (weak, nonatomic) IBOutlet UIImageView *imageM;

@property (weak, nonatomic) IBOutlet UIView *viewShade;
@property (weak, nonatomic) IBOutlet UIView *viewRight;
@property (weak, nonatomic) IBOutlet UIButton *btnMap;

@property (weak, nonatomic) IBOutlet UILabel *lableTContact;
@property (weak, nonatomic) IBOutlet UILabel *lableTOpenSince;

- (void)showShadeStatus:(BOOL)isShow;

@end
