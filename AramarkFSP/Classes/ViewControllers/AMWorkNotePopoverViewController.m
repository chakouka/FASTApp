//
//  AMWorkNotePopoverViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 7/2/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMWorkNotePopoverViewController.h"

@interface AMWorkNotePopoverViewController ()

@end

@implementation AMWorkNotePopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.nameLabel.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Work Order Notes")];
    [self.nameLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.valueTF setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setWorkOrderNotes:(NSString *)workOrderNotes
{
    _workOrderNotes = workOrderNotes;
    self.valueTF.text = workOrderNotes;
}

@end
