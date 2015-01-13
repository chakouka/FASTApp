//
//  ColumnViewController.m
//  ChartTest
//
//  Created by PwC on 5/28/14.
//  Copyright (c) 2014 PwC. All rights reserved.
//

#import "ColumnViewController.h"
#import "ColumnInfo.h"
#import <QuartzCore/QuartzCore.h>

@interface ColumnViewController ()
{
    ColumnInfo *currentInfo;
}

@property (strong, nonatomic) ColumnInfo *currentInfo;

@end

@implementation ColumnViewController
@synthesize currentInfo;
@synthesize delegate;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickColumnBtn:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(columnViewControllerClickedWithInfo:)]) {
        [delegate columnViewControllerClickedWithInfo:currentInfo];
    }
}

- (void)refreshWithInfo:(ColumnInfo *)aInfo
{
    NSLog(@"refreshWithInfo : %@",aInfo);
    self.currentInfo = aInfo;
    self.labelInfo.text = aInfo.strBottomInfo;
    CGFloat fItem = 35.0;
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(5, 384 - aInfo.iHeight*fItem, 50, fItem * aInfo.iHeight)];
    aView.backgroundColor = [UIColor colorWithRed:224.0/255 green:53.0/255 blue:53.0/255 alpha:1];

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:aView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = aView.bounds;
    maskLayer.path = maskPath.CGPath;
    aView.layer.mask = maskLayer;
    
    [self.view addSubview:aView];
}

@end
