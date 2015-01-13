//
//  AMDatePickerViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 7/9/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDatePickerViewController.h"

@interface AMDatePickerViewController ()
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation AMDatePickerViewController

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
    
    MyButtonTitle(self.okButton, MyLocal(@"OK"));
    MyButtonTitle(self.cancelButton, MyLocal(@"Cancel"));
    
    self.datePicker.timeZone = [[AMLogicCore sharedInstance] timeZoneOnSalesforce];
    [self.datePicker setMinimumDate:[NSDate date]];
    [self.okButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:17.0]];
    [self.cancelButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:17.0]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)okButtonTapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnOKButton:)]) {
        [self.delegate performSelector:@selector(didTappedOnOKButton:) withObject:self.datePicker.date];
    }
}

- (IBAction)cancelButtonTapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnCancelButton)]) {
        [self.delegate performSelector:@selector(didTappedOnCancelButton) withObject:nil];
    }
}

@end
