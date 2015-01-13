//
//  AMContactTableViewCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/30/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMContactTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contactNoLabel;
@property (weak, nonatomic) IBOutlet UIButton *collapseButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *roleTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UILabel *labelTContactRole;
@property (weak, nonatomic) IBOutlet UILabel *labelTContactPhone;
@property (weak, nonatomic) IBOutlet UILabel *labelTContactEmail;


@property (strong, nonatomic) AMContact *assignedContact;

@end
