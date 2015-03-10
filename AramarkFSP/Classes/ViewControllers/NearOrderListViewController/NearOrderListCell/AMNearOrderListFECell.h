//
//  AMNearOrderListFECell.h
//  AramarkFSP
//
//  Created by FYH on 9/3/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMNearOrderListFECell : UITableViewCell

@property (strong, nonatomic) NSString *strPriority;
@property (weak, nonatomic) IBOutlet UILabel *label_Index;
@property (weak, nonatomic) IBOutlet UILabel *label_Title;
@property (weak, nonatomic) IBOutlet UILabel *label_Type;
@property (weak, nonatomic) IBOutlet UILabel *label_Distance;
@property (weak, nonatomic) IBOutlet UILabel *label_Time;
@property (weak, nonatomic) IBOutlet UILabel *label_Location;
@property (weak, nonatomic) IBOutlet UIView *viewM;
@property (weak, nonatomic) IBOutlet UIView *viewIndex;
@property (weak, nonatomic) IBOutlet UIImageView *imageIndex;
@property (weak, nonatomic) IBOutlet UIImageView *imageM;

@property (weak, nonatomic) IBOutlet UIView *viewShade;
@property (weak, nonatomic) IBOutlet UIView *viewRight;
@property (weak, nonatomic) IBOutlet UIButton *btnMap;
@property (weak, nonatomic) IBOutlet UILabel *labelWONumber;

@property (weak, nonatomic) IBOutlet UILabel *labelEstimatedWorkDate;
@property (weak, nonatomic) IBOutlet UILabel *labelFilterType;
@property (weak, nonatomic) IBOutlet UILabel *labelFilterNumber;

@property (weak, nonatomic) IBOutlet UILabel *labelTWorkorderNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelTEstimatedWorkDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTFilterType;
@property (weak, nonatomic) IBOutlet UILabel *labelTFilterNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelContactName;
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;

- (void)showShadeStatus:(BOOL)isShow;
@end
